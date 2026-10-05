import SwiftUI
import SwiftData
import PhotosUI

struct RecordFishView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Fetch all existing species for inline selector and deduplication
    @Query(sort: \Species.name) private var allSpecies: [Species]
    
    @State private var viewModel: RecordFishViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    init(trip: Trip) {
        _viewModel = State(initialValue: RecordFishViewModel(trip: trip))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Layer 0 Base Canvas Background (Standardized app-wide backdrop)
                Color.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // MARK: - Angler Selection (Roster Scoped)
                        anglerSectionCard
                        
                        // MARK: - Species Selection & Inline Creation
                        speciesSectionCard
                        
                        // MARK: - Weight Input Metric
                        weightSectionCard
                        
                        // MARK: - Hardware Telemetry & Media
                        telemetrySectionCard
                        
                        // MARK: - Optional Commentary
                        notesSectionCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Record Catch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.backgroundMain, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Catch") {
                        if viewModel.saveCatch(context: modelContext) {
                            dismiss()
                        }
                    }
                    .bold()
                    .foregroundStyle(viewModel.isValid ? Color.brandAccent : Color.secondary)
                    .disabled(!viewModel.isValid || viewModel.isSaving)
                }
            }
            .task {
                viewModel.captureLocation()
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Subview Cards
    
    private var anglerSectionCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Text("Angler")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                HStack {
                    Picker("Select Angler", selection: $viewModel.selectedAngler) {
                        Text("Select Angler").tag(Optional<Angler>.none)
                        ForEach(viewModel.trip.anglers) { angler in
                            Text(angler.name).tag(Optional(angler))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.brandAccent)
                    Spacer()
                }
                .frame(minHeight: 44)
            }
        }
    }
    
    private var speciesSectionCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 10) {
                Text("Species")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                HStack {
                    Picker("Select Species", selection: $viewModel.selectedSpecies) {
                        Text("Select Species").tag(Optional<Species>.none)
                        ForEach(filteredSpecies) { species in
                            Text(species.name).tag(Optional(species))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.brandAccent)
                    Spacer()
                }
                .frame(minHeight: 44)
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                if !viewModel.isAddingNewSpecies {
                    Button(action: { viewModel.isAddingNewSpecies = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.subheadline)
                            Text("Add New Species")
                                .cvFont(CVFont.actionLabel)
                        }
                        .foregroundColor(Color.brandAccent)
                        .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            TextField("New Species Name", text: $viewModel.newSpeciesName)
                                .textFieldStyle(.roundedBorder)
                            
                            Button("Add") {
                                _ = viewModel.createAndSelectSpecies(
                                    allExistingSpecies: allSpecies,
                                    context: modelContext
                                )
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.brandAccent)
                            .disabled(viewModel.newSpeciesName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            Button("Cancel") {
                                viewModel.isAddingNewSpecies = false
                                viewModel.newSpeciesName = ""
                                viewModel.speciesValidationError = nil
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        if let error = viewModel.speciesValidationError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var weightSectionCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight (lbs)")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                HStack {
                    TextField("0.00", text: $viewModel.weightInput)
                        .keyboardType(.decimalPad)
                        .cvFont(CVFont.telemetryHeavy)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                    
                    Text("lbs")
                        .cvFont(CVFont.primaryBody)
                        .foregroundColor(.secondary)
                }
                .frame(minHeight: 44)
            }
        }
    }
    
    private var telemetrySectionCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Media")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                // Photo Attachment Control
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .foregroundColor(Color.brandAccent)
                        Text(viewModel.selectedImageData == nil ? "Attach Catch Photo" : "Photo Attached")
                            .cvFont(CVFont.primaryBody)
                            .foregroundColor(Color.primary)
                        Spacer()
                        if viewModel.selectedImageData != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .frame(minHeight: 44)
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            viewModel.selectedImageData = data
                        }
                    }
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                // Location Indicator
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundColor(viewModel.capturedLatitude != nil ? Color.statusActive : .secondary)
                    
                    if viewModel.isFetchingLocation {
                        Text("Acquiring GPS coordinates...")
                            .cvFont(CVFont.metadata)
                            .foregroundColor(.secondary)
                    } else if let lat = viewModel.capturedLatitude, let lon = viewModel.capturedLongitude {
                        Text(String(format: "GPS: %.4f, %.4f", lat, lon))
                            .cvFont(CVFont.metadata)
                            .foregroundColor(.primary)
                    } else {
                        Text("GPS Location Unavailable")
                            .cvFont(CVFont.metadata)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(minHeight: 36)
            }
        }
    }
    
    private var notesSectionCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                TextField("Lure, depth, structural observations...", text: $viewModel.comment, axis: .vertical)
                    .cvFont(CVFont.primaryBody)
                    .lineLimit(3...5)
            }
        }
    }
    
    // Filter species list if search text is active
    private var filteredSpecies: [Species] {
        if viewModel.speciesSearchText.isEmpty {
            return allSpecies
        }
        return allSpecies.filter { $0.name.localizedCaseInsensitiveContains(viewModel.speciesSearchText) }
    }
}
