//
//  EndTripViewModel.swift
//  CatchVault
//
//  Created by Kevin Schoen on 10/6/26.
//
import Foundation
import SwiftData
import SwiftUI

@Observable
final class EndTripViewModel {
    // MARK: - Local Editable State
    var tripNotes: String = ""
    var isSaving: Bool = false
    var errorMessage: String?
    
    // MARK: - Context Dependencies
    let trip: Trip
    
    // MARK: - Initializer
    init(trip: Trip) {
        self.trip = trip
        self.tripNotes = trip.notes ?? ""
    }
    
    // MARK: - Computed Summary Readouts
    
    /// Final elapsed trip duration formatted as HH:mm:ss
    var formattedFinalDuration: String {
        let end = trip.endTime ?? Date()
        let elapsed = max(0, end.timeIntervalSince(trip.startTime))
        
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// Total fish landed count derived from trip.catches
    var totalCatchesCount: Int {
        trip.catches.count
    }
    
    /// Cumulative weight landed sum in pounds
    var totalWeight: Double {
        trip.catches.reduce(0.0) { $0 + $1.weight }
    }
    
    /// Formatted comma-separated list of participating anglers
    var anglersFormattedString: String {
        guard !trip.anglers.isEmpty else { return "No Anglers Assigned" }
        return trip.anglers.map { $0.name }.sorted().joined(separator: ", ")
    }
    
    /// Breakdown of catches count per species for the session summary
    var speciesSummary: [(speciesName: String, count: Int)] {
        var counts: [String: Int] = [:]
        for catchItem in trip.catches {
            let name = catchItem.species?.name ?? "Unknown Species"
            counts[name, default: 0] += 1
        }
        return counts.map { (speciesName: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })
    }
    
    // MARK: - Atomic Session Closing Operation
    
    /// Concludes and locks the active trip session by stamping endTime, persisting notes, and saving context.
    @MainActor
    func saveAndEndTrip(context: ModelContext) -> Bool {
        isSaving = true
        defer { isSaving = false }
        
        let trimmedNotes = tripNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Lock trip state with endTime and notes
        trip.endTime = Date()
        trip.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        
        // 2. Commit atomic transaction
        do {
            try context.save()
            return true
        } catch {
            errorMessage = "Failed to complete and save trip: \(error.localizedDescription)"
            return false
        }
    }
}
