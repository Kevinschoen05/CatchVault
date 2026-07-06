import Foundation
import SwiftData

/// An execution facility serving as the system's Anti-Corruption Layer (ACL).
/// Materializes a normalized relational object graph from clean design-time JSON.
public final class MigrationManager {
    private let context: ModelContext
    
    // Efficient in-memory maps to guarantee deduplication and identity truth
    private var anglerMap: [String: Angler] = [:]
    private var speciesMap: [String: Species] = [:]
    private var reservoirMap: [String: Reservoir] = [:]
    private var tripMap: [String: Trip] = [:] // Key format: YYYY-MM-DD-ReservoirName (Case-Insensitive)
    
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    private let tokenFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Enforce absolute UTC boundaries
        return formatter
    }()
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    /// Entrypoint invoking the transactional ingestion loop.
    public func migrate(from records: [LegacyFishRecord]) throws {
        // Clear any residual lookups to maintain deterministic integrity per run
        anglerMap.removeAll()
        speciesMap.removeAll()
        reservoirMap.removeAll()
        tripMap.removeAll()
        
        for record in records {
            // 1. Resolve exact primitive timestamp boundaries safely
            guard let timestamp = isoFormatter.date(from: record.date) else { continue }
            
            // 2. Resolve or create unique Lookup Dimension Objects
            let angler = resolveAngler(named: record.angler)
            let reservoir = resolveReservoir(named: record.reservoir)
            let species = resolveSpecies(named: record.species)
            
            // 3. Resolve or create the parent Synthetic Trip domain session
            let dateToken = tokenFormatter.string(from: timestamp)
            let trip = resolveTrip(dateToken: dateToken, timestamp: timestamp, reservoir: reservoir, angler: angler)
            
            // 4. Safely handle optional geometric coordinates from blank text strings
            let latValue = Double(record.latitude.trimmingCharacters(in: .whitespacesAndNewlines))
            let lonValue = Double(record.longitude.trimmingCharacters(in: .whitespacesAndNewlines))
            
            // 5. Build and persist child FishCatch instance using its designated initializer
            let newCatch = FishCatch(
                id: UUID(),
                timestamp: timestamp,
                weight: record.weight,
                latitude: latValue,
                longitude: lonValue,
                imagePath: record.image.isEmpty ? nil : record.image,
                comment: record.comment.isEmpty ? nil : record.comment
            )
            
            // 6. Hook up formal relational paths matching macro inverse configurations
            newCatch.trip = trip
            newCatch.angler = angler
            newCatch.species = species
            
            // Update relationships explicitly on collections to prevent structural relationship faults
            trip.catches.append(newCatch)
            
            context.insert(newCatch)
        }
        
        // Save at transaction completion point to avoid partial state corruption
        try context.save()
    }
    
    // MARK: - Dimension Resolvers
    
    private func resolveAngler(named name: String) -> Angler {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let lookupKey = cleanName.lowercased()
        if let existing = anglerMap[lookupKey] { return existing }
        
        // Pass the required name property directly into the designated constructor
        let newAngler = Angler(id: UUID(), name: cleanName)
        context.insert(newAngler)
        anglerMap[lookupKey] = newAngler
        return newAngler
    }
    
    private func resolveReservoir(named name: String) -> Reservoir {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let lookupKey = cleanName.lowercased()
        if let existing = reservoirMap[lookupKey] { return existing }
        
        // Pass the required name property directly into the designated constructor
        let newReservoir = Reservoir(id: UUID(), name: cleanName)
        context.insert(newReservoir)
        reservoirMap[lookupKey] = newReservoir
        return newReservoir
    }
    
    private func resolveSpecies(named name: String) -> Species {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let lookupKey = cleanName.lowercased()
        if let existing = speciesMap[lookupKey] { return existing }
        
        // Pass the required name property directly into the designated constructor
        let newSpecies = Species(id: UUID(), name: cleanName)
        context.insert(newSpecies)
        speciesMap[lookupKey] = newSpecies
        return newSpecies
    }
    
    private func resolveTrip(dateToken: String, timestamp: Date, reservoir: Reservoir, angler: Angler) -> Trip {
        let compositeKey = "\(dateToken)-\(reservoir.name.lowercased())"
        
        if let existingTrip = tripMap[compositeKey] {
            // Ensure the angler is recorded as a participant in the shared daily trip session
            if !existingTrip.anglers.contains(where: { $0.id == angler.id }) {
                existingTrip.anglers.append(angler)
            }
            return existingTrip
        }
        
        // Create a parent trip bound to the start of that day's absolute UTC boundary
        let tripStart = tokenFormatter.date(from: dateToken) ?? timestamp
        
        let newTrip = Trip(id: UUID(), startTime: tripStart, migrated: true, dataVersion: 1)
        newTrip.reservoir = reservoir
        newTrip.anglers.append(angler)
        
        context.insert(newTrip)
        tripMap[compositeKey] = newTrip
        return newTrip
    }
}
