//
//  AddReservoirView.swift
//  CatchVault
//

import SwiftUI
import SwiftData
import CoreLocation

public struct AddReservoirView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Reservoir.name) private var existingReservoirs: [Reservoir]
    
    @State private var name: String = ""
    @State private var latitudeString: String = ""
    @State private var longitudeString: String = ""
    
    @State private var validationError: String? = nil
    @State private var isCapturingLocation: Bool = false
    
    public init() {}
    
    private var isFormValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.count >= 2
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Validation Error Banner (if triggered)
                        if let error = validationError {
                            CVCardContainer {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(Color.brandAccent)
                                    Text(error)
                                        .cvFont(CVFont.metadata)
                                        .foregroundStyle(Color.textOnCardPrimary)
                                    Spacer()
                                }
                            }
                        }
                        
                        // Reservoir Details Card
                        CVCardContainer {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Reservoir Details")
                                    .cvFont(CVFont.sectionHeader)
                                    .foregroundStyle(Color.textOnCardPrimary)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Name *")
                                        .cvFont(CVFont.metadata)
                                        .foregroundStyle(Color.textOnCardSecondary)
                                    
                                    TextField(
                                        "",
                                        text: $name,
                                        prompt: Text("Enter reservoir name...").foregroundStyle(Color.textOnCardSecondary.opacity(0.6))
                                    )
                                    .foregroundStyle(Color.textOnCardPrimary)
                                    .cvFont(CVFont.primaryBody)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                    .background(Color.surfaceSecondary.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .onChange(of: name) { _, _ in
                                        if validationError != nil {
                                            validationError = nil
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Optional Spatial Coordinates Card
                        CVCardContainer {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Location Coordinates")
                                        .cvFont(CVFont.sectionHeader)
                                        .foregroundStyle(Color.textOnCardPrimary)
                                    
                                    Spacer()
                                    
                                    Text("(Optional)")
                                        .cvFont(CVFont.metadata)
                                        .foregroundStyle(Color.textOnCardSecondary)
                                }
                                
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Latitude")
                                            .cvFont(CVFont.metadata)
                                            .foregroundStyle(Color.textOnCardSecondary)
                                        
                                        TextField(
                                            "",
                                            text: $latitudeString,
                                            prompt: Text("e.g. 41.1234").foregroundStyle(Color.textOnCardSecondary.opacity(0.6))
                                        )
                                        .keyboardType(.decimalPad)
                                        .foregroundStyle(Color.textOnCardPrimary)
                                        .cvFont(CVFont.primaryBody)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                        .background(Color.surfaceSecondary.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Longitude")
                                            .cvFont(CVFont.metadata)
                                            .foregroundStyle(Color.textOnCardSecondary)
                                        
                                        TextField(
                                            "",
                                            text: $longitudeString,
                                            prompt: Text("e.g. -73.5678").foregroundStyle(Color.textOnCardSecondary.opacity(0.6))
                                        )
                                        .keyboardType(.decimalPad)
                                        .foregroundStyle(Color.textOnCardPrimary)
                                        .cvFont(CVFont.primaryBody)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                        .background(Color.surfaceSecondary.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    }
                                }
                                
                                Button(action: captureCurrentLocation) {
                                    HStack {
                                        if isCapturingLocation {
                                            ProgressView()
                                                .tint(Color.textOnCardPrimary)
                                                .padding(.trailing, 6)
                                        } else {
                                            Image(systemName: "location.fill")
                                                .foregroundStyle(Color.brandPrimary)
                                        }
                                        Text(isCapturingLocation ? "Acquiring GPS..." : "Use Current Location")
                                            .cvFont(CVFont.metadata)
                                            .foregroundStyle(Color.textOnCardPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.surfaceSecondary.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                                .disabled(isCapturingLocation)
                            }
                        }
                        
                        // Primary Terminal Action
                        Button(action: saveReservoir) {
                            Text("Save Reservoir")
                                .cvFont(CVFont.sectionHeader)
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(isFormValid ? Color.brandAccent : Color.surfaceSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 8)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add Reservoir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.white)
                }
            }
        }
    }
    
    // MARK: - Actions & Persistence Logic
    
    private func captureCurrentLocation() {
        isCapturingLocation = true
        Task {
            do {
                let location = try await LocationService.shared.requestCurrentLocation()
                await MainActor.run {
                    self.latitudeString = String(format: "%.6f", location.coordinate.latitude)
                    self.longitudeString = String(format: "%.6f", location.coordinate.longitude)
                    self.isCapturingLocation = false
                }
            } catch {
                await MainActor.run {
                    self.isCapturingLocation = false
                    self.validationError = "Unable to acquire GPS fix: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func saveReservoir() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Case-insensitive deduplication check
        let nameExists = existingReservoirs.contains { existing in
            existing.name.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
        
        if nameExists {
            validationError = "A reservoir with the name '\(trimmedName)' already exists."
            return
        }
        
        // 1. Instantiate Reservoir using constructor init(name: String)
        let newReservoir = Reservoir(name: trimmedName)
        
        // 2. Assign optional spatial coordinates directly on stored properties
        if let latDouble = Double(latitudeString) {
            newReservoir.latitude = latDouble
        }
        if let longDouble = Double(longitudeString) {
            newReservoir.longitude = longDouble
        }
        
        // 3. Insert and persist
        modelContext.insert(newReservoir)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            validationError = "Failed to save reservoir: \(error.localizedDescription)"
        }
    }
}
