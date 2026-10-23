import SwiftUI
import SwiftData

@Observable
class EditTripViewModel {
    /// The core persistent entity being edited
    let trip: Trip
    
    // MARK: - Draft State
    var draftStartTime: Date
    var draftEndTime: Date
    var draftNotes: String
    
    var errorMessage: String? = nil
    
    init(trip: Trip) {
        self.trip = trip
        // Initialize draft state with existing entity data
        self.draftStartTime = trip.startTime
        self.draftEndTime = trip.endTime ?? Date()
        self.draftNotes = trip.notes ?? ""
    }
    
    // MARK: - Invariants & Validation
    
    /// Ensures temporal boundaries remain logical
    var isValid: Bool {
        draftStartTime <= draftEndTime
    }
    
    // MARK: - Commit Phase
    
    /// Pushes draft state back to the core entity and commits the context
    func saveChanges(context: ModelContext) -> Bool {
        guard isValid else {
            errorMessage = "Trip end time cannot precede the start time."
            return false
        }
        
        // Re-assign draft values to the persistent model
        trip.startTime = draftStartTime
        trip.endTime = draftEndTime
        
        let trimmedNotes = draftNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        trip.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        
        do {
            try context.save()
            return true
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            return false
        }
    }
}
