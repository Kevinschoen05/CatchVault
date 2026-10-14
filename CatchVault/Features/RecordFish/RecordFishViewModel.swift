//
//  RecordFishViewModel.swift
//  CatchVault
//

import Foundation
import SwiftData
import CoreLocation
import SwiftUI

@Observable
final class RecordFishViewModel {
    // MARK: - Form Inputs
    var selectedAngler: Angler?
    var selectedSpecies: Species?
    var weightInput: String = ""
    var comment: String = ""
    var selectedImageData: Data?
    
    // MARK: - Inline Species Creation State
    var speciesSearchText: String = ""
    var isAddingNewSpecies: Bool = false
    var newSpeciesName: String = ""
    var speciesValidationError: String?
    
    // MARK: - Hardware Telemetry State
    var capturedLatitude: Double?
    var capturedLongitude: Double?
    var isFetchingLocation: Bool = false
    var locationAccuracyDescription: String?
    
    // MARK: - Presentation & Persistence State
    var isSaving: Bool = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    let trip: Trip
    private let locationService: LocationServiceProtocol
    
    init(trip: Trip, locationService: LocationServiceProtocol = LocationService.shared) {
        self.trip = trip
        self.locationService = locationService
        
        // Default angler selection to the first angler on the trip roster if available
        self.selectedAngler = trip.anglers.first
    }
    
    // MARK: - Hardware Telemetry Triggers
    
    /// Requests instantaneous GPS coordinates at the moment of landing.
    @MainActor
    func captureLocation() async {
        isFetchingLocation = true
        locationAccuracyDescription = "Acquiring GPS fix..."
        defer { isFetchingLocation = false }
        
        do {
            let location = try await locationService.requestCurrentLocation()
            self.capturedLatitude = location.coordinate.latitude
            self.capturedLongitude = location.coordinate.longitude
            self.locationAccuracyDescription = String(format: "GPS Captured (±%.0fm)", location.horizontalAccuracy)
        } catch {
            // Location acquisition is optional; gracefully fail and retain nil coordinates
            self.capturedLatitude = nil
            self.capturedLongitude = nil
            self.locationAccuracyDescription = "Location unavailable"
        }
    }
    
    // MARK: - Inline Species Creation & Deduplication
    
    /// Sanitizes and validates inline new species entry against established guardrails:
    /// Whitespace trimming, 2-character minimum, and case-insensitive deduplication.
    func createAndSelectSpecies(allExistingSpecies: [Species], context: ModelContext) -> Bool {
        speciesValidationError = nil
        let sanitizedName = newSpeciesName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard sanitizedName.count >= 2 else {
            speciesValidationError = "Species name must be at least 2 characters."
            return false
        }
        
        // Case-insensitive deduplication check against existing species in context
        if let existing = allExistingSpecies.first(where: { $0.name.localizedCaseInsensitiveCompare(sanitizedName) == .orderedSame }) {
            // Re-use existing entity if found
            self.selectedSpecies = existing
            self.newSpeciesName = ""
            self.isAddingNewSpecies = false
            return true
        }
        
        // Instantiate and persist new Species entry
        let newSpecies = Species(name: sanitizedName)
        context.insert(newSpecies)
        
        self.selectedSpecies = newSpecies
        self.newSpeciesName = ""
        self.isAddingNewSpecies = false
        return true
    }
    
    // MARK: - Form Validation & Save Execution
    
    var isValid: Bool {
        guard selectedAngler != nil,
              selectedSpecies != nil,
              let weightValue = Double(weightInput.trimmingCharacters(in: .whitespacesAndNewlines)),
              weightValue > 0 else {
            return false
        }
        return true
    }
    
    /// Atomically creates and persists the FishCatch instance and connects relational contexts.
    @MainActor
    func saveCatch(context: ModelContext) -> Bool {
        guard isValid,
              let angler = selectedAngler,
              let species = selectedSpecies,
              let weightValue = Double(weightInput.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            errorMessage = "Please complete all required fields with valid values."
            return false
        }
        
        isSaving = true
        defer { isSaving = false }
        
        // Handle image disk persistence if photo payload exists
        var savedImagePath: String? = nil
        if let imageData = selectedImageData {
            savedImagePath = saveImageToDisk(imageData: imageData)
        }
        
        let catchTimestamp = Date()
        
        // 1. Instantiate new FishCatch entity
        let newCatch = FishCatch(
            timestamp: catchTimestamp,
            weight: weightValue,
            latitude: capturedLatitude,
            longitude: capturedLongitude,
            imagePath: savedImagePath,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : comment.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        // 2. Establish relational pointers
        newCatch.angler = angler
        newCatch.species = species
        newCatch.trip = trip
        
        // 3. Append to parent collection and ModelContext
        context.insert(newCatch)
        if trip.catches.contains(where: { $0.id == newCatch.id }) == false {
            trip.catches.append(newCatch)
        }
        
        // 4. Commit atomic transaction
        do {
            try context.save()
            return true
        } catch {
            errorMessage = "Failed to save catch: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Sandboxed Storage Operations
    
    private func saveImageToDisk(imageData: Data) -> String? {
        let fileName = "\(UUID().uuidString).jpg"
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL, options: .atomic)
            return fileName
        } catch {
            return nil
        }
    }
}
