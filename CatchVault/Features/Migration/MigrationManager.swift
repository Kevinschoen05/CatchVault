//
//  MigrationManager.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/2/26.
//
import Foundation
import SwiftData

/// An execution facility serving as the system's Anti-Corruption Layer (ACL).
/// Parses flat, historical records from a production MongoDB export and materializes
/// a normalized relational object graph within SwiftData.
public final class MigrationManager {
    private let context: ModelContext
    
    // In-memory lookups to preserve identity uniqueness and minimize query pollution
    private var anglerMap: [String: Angler] = [:]
    private var speciesMap: [String: Species] = [:]
    private var reservoirMap: [String: Reservoir] = [:]
    private var tripMap: [String: Trip] = [:] // Key format: YYYY-MM-DD-ReservoirNormalizedName
    
    /// Date formatter to interpret standard historical MongoDB $date extended variants.
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    /// Fallback formatter for secondary legacy string variations (e.g., M/d/yyyy format specs).
    private let legacyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    /// String formatter used to synthesize deterministic calendar tokens relative to UTC.
    private let tokenDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    /// Ingests a JSON data payload from an embedded source asset, maps relationships,
    /// logs diagnostic invariants, and commits the mutation graph to the storage database.
    /// - Parameter data: Raw data bytes containing the JSON historical collection array.
    /// - Throws: Core execution or database persistence failures.
    public func migrate(from data: Data) throws {
        let decoder = JSONDecoder()
        let payloads: [LegacyPayload]
        
        do {
            payloads = try decoder.decode([LegacyPayload].self, from: data)
        } catch {
            print("[CRITICAL MIGRATION ERROR] Root payload decoding failed structurally: \(error)")
            throw error
        }
        
        print("[MIGRATION ADVANCEMENT] Extracted \(payloads.count) payload lines from source snapshot data. Processing pipeline running...")
        
        var successfulIngestionCount = 0
        var telemetrySkippedCoordinateCount = 0
        
        for (index, payload) in payloads.enumerated() {
            let recordID = payload.id.oid
            
            // --- Constraint Check 1: Polymorphic Timestamp Translation ---
            guard let catchTimestamp = parseLegacyDate(payload.date.dateString) else {
                print("[DIAGNOSTIC ERROR] Line index \(index) | Document ID: \(recordID) -> Flag: Unparseable date token value ('\(payload.date.dateString)'). Skipping sequence.")
                continue
            }
            
            // --- Constraint Check 2: Core Identifier Validation ---
            let rawAngler = payload.angler.trimmingCharacters(in: .whitespacesAndNewlines)
            let rawReservoir = payload.reservoir.trimmingCharacters(in: .whitespacesAndNewlines)
            let rawSpecies = payload.species.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if rawAngler.isEmpty || rawReservoir.isEmpty || rawSpecies.isEmpty {
                print("[DIAGNOSTIC ERROR] Line index \(index) | Document ID: \(recordID) -> Flag: Incomplete structural definitions (Angler: '\(rawAngler)', Reservoir: '\(rawReservoir)', Species: '\(rawSpecies)'). Skipping sequence.")
                continue
            }
            
            // --- Constraint Check 3: Polymorphic Weight Extraction ---
            guard let parsedWeight = payload.weight.parsedDouble, parsedWeight > 0 else {
                print("[DIAGNOSTIC ERROR] Line index \(index) | Document ID: \(recordID) -> Flag: Weight metric violation format. Skipping sequence.")
                continue
            }
            
            // --- Normalization Phase: Case-Insensitive Deduplication ---
            let normalizedAnglerKey = rawAngler.lowercased()
            let normalizedReservoirKey = rawReservoir.lowercased()
            let normalizedSpeciesKey = rawSpecies.lowercased()
            
            let targetAngler = fetchOrInitializeAngler(named: rawAngler, key: normalizedAnglerKey)
            let targetReservoir = fetchOrInitializeReservoir(named: rawReservoir, key: normalizedReservoirKey)
            let targetSpecies = fetchOrInitializeSpecies(named: rawSpecies, key: normalizedSpeciesKey)
            
            // --- Synthetic Relationship Structuring: Trip Cluster Bridge ---
            let calendarToken = tokenDateFormatter.string(from: catchTimestamp)
            let tripCompositeKey = "\(calendarToken)-\(normalizedReservoirKey)"
            
            let targetTrip = fetchOrInitializeTrip(
                compositeKey: tripCompositeKey,
                dateToken: calendarToken,
                timestamp: catchTimestamp,
                reservoir: targetReservoir,
                angler: targetAngler
            )
            
            // --- Telemetry Invariants Check: Coordinates Processing ---
            var finalLatitude: Double? = nil
            var finalLongitude: Double? = nil
            
            if let latStr = payload.latitude?.trimmingCharacters(in: .whitespacesAndNewlines),
               let lonStr = payload.longitude?.trimmingCharacters(in: .whitespacesAndNewlines),
               !latStr.isEmpty, !lonStr.isEmpty {
                if let latVal = Double(latStr), let lonVal = Double(lonStr) {
                    finalLatitude = latVal
                    finalLongitude = lonVal
                } else {
                    telemetrySkippedCoordinateCount += 1
                }
            }
            
            // --- Footprint Minimization: Optional Parameter Refinement ---
            let finalComment = payload.comment?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? payload.comment : nil
            let finalImagePath = payload.image?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? payload.image : nil
            
            // --- Instantiation & Relational Insertion Graph Execution ---
            let newCatch = FishCatch(
                timestamp: catchTimestamp,
                weight: parsedWeight,
                latitude: finalLatitude,
                longitude: finalLongitude,
                imagePath: finalImagePath,
                comment: finalComment
            )
            
            // Establish explicit macro ownership mappings
            newCatch.angler = targetAngler
            newCatch.species = targetSpecies
            newCatch.trip = targetTrip
            
            context.insert(newCatch)
            successfulIngestionCount += 1
        }
        
        // --- Structural Database Finalization Block ---
        do {
            try context.save()
            print("[MIGRATION PIPELINE SUCCESS] Committed transaction. recordsLoaded: \(successfulIngestionCount) | telemetryMismatchesDropped: \(telemetrySkippedCoordinateCount) | totalAttempted: \(payloads.count)")
        } catch {
            print("[CRITICAL WRITE ERROR] SwiftData transaction checkpoint execution context failed to persist to SQLite storage disk: \(error)")
            throw error
        }
    }
    
    // MARK: - Internal Domain Helper Resolvers
    
    private func parseLegacyDate(_ sourceString: String) -> Date? {
        let cleanToken = sourceString.trimimmingCharacters(in: .whitespacesAndNewlines)
        if let parsedISO = isoFormatter.date(from: cleanToken) {
            return parsedISO
        }
        return legacyDateFormatter.date(from: cleanToken)
    }
    
    private func fetchOrInitializeAngler(named name: String, key: String) -> Angler {
        if let activeRef = anglerMap[key] { return activeRef }
        
        let newAngler = Angler(name: name)
        context.insert(newAngler)
        anglerMap[key] = newAngler
        return newAngler
    }
    
    private func fetchOrInitializeReservoir(named name: String, key: String) -> Reservoir {
        if let activeRef = reservoirMap[key] { return activeRef }
        
        let newReservoir = Reservoir(name: name)
        context.insert(newReservoir)
        reservoirMap[key] = newReservoir
        return newReservoir
    }
    
    private func fetchOrInitializeSpecies(named name: String, key: String) -> Species {
        if let activeRef = speciesMap[key] { return activeRef }
        
        let newSpecies = Species(name: name)
        context.insert(newSpecies)
        speciesMap[key] = newSpecies
        return newSpecies
    }
    
    private func fetchOrInitializeTrip(compositeKey: String, dateToken: String, timestamp: Date, reservoir: Reservoir, angler: Angler) -> Trip {
        if let activeRef = tripMap[compositeKey] {
            // Append missing participant links if an alternate angler shares the group session window
            if !activeRef.anglers.contains(where: { $0.id == angler.id }) {
                activeRef.anglers.append(angler)
            }
            return activeRef
        }
        
        // Form a standalone Trip window bound strictly to the target calendar group day window
        guard let groupBaseStart = legacyDateFormatter.date(from: dateToken) else {
            // Safe fallback configuration using historical extraction point timestamps
            let newTrip = Trip(id: UUID(), startTime: timestamp, migrated: true, dataVersion: 1)
            newTrip.reservoir = reservoir
            newTrip.anglers.append(angler)
            context.insert(newTrip)
            tripMap[compositeKey] = newTrip
            return newTrip
        }
        
        let newTrip = Trip(id: UUID(), startTime: groupBaseStart, migrated: true, dataVersion: 1)
        newTrip.reservoir = reservoir
        newTrip.anglers.append(angler)
        
        context.insert(newTrip)
        tripMap[compositeKey] = newTrip
        return newTrip
    }
}

// Private expansion to provide clean string sanitation helpers
private extension String {
    func trimimmingCharacters(in set: CharacterSet) -> String {
        return self.trimmingCharacters(in: set)
    }
}
