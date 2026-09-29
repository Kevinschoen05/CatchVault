//
//  StartTrip.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/29/26.
//
import SwiftUI
import SwiftData

struct StartTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // SwiftData Queries
    @Query(sort: \Reservoir.name, order: .forward) private var reservoirs: [Reservoir]
    @Query(sort: \Angler.name, order: .forward) private var existingAnglers: [Angler]
    
    // Local View State
    @State private var selectedReservoir: Reservoir?
    @State private var selectedAnglers: Set<Angler> = []
    @State private var startTime: Date = Date()
    @State private var newAnglerName: String = ""
    
    // Injected Parameters
    private let initialReservoir: Reservoir?
    private let onTripStarted: ((Trip) -> Void)?
    
        init(reservoir: Reservoir? = nil, onTripStarted: ((Trip) -> Void)? = nil) {
        self.initialReservoir = reservoir
        self.onTripStarted = onTripStarted
        _selectedReservoir = State(initialValue: reservoir)
    }
    
    private var isValid: Bool {
        selectedReservoir != nil && !selectedAnglers.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        reservoirSelectionSection
                        anglerSelectionSection
                        startTimeSection
                        startTripButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Start New Trip")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .cvFont(CVFont.primaryBody)
                    .foregroundColor(Color.white)
                }
            }.toolbarBackground(Color.backgroundMain, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
        }
        
    
    // MARK: - Section Views
    
    private var reservoirSelectionSection: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("TARGET RESERVOIR")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundColor(Color.brandPrimary)
                
                if reservoirs.isEmpty {
                    Text("No reservoirs available. Please add a reservoir first.")
                        .cvFont(CVFont.metadata)
                        .foregroundColor(Color.brandPrimary)
                } else {
                    Menu {
                        ForEach(reservoirs) { reservoir in
                            Button(action: {
                                selectedReservoir = reservoir
                            }) {
                                HStack {
                                    Text(reservoir.name)
                                    if selectedReservoir?.id == reservoir.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedReservoir?.name ?? "Select Reservoir...")
                                .cvFont(CVFont.primaryBody)
                                .foregroundColor(selectedReservoir == nil ? Color.inputField : Color.brandPrimary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.footnote)
                                .foregroundColor(Color.surfaceSecondary)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(Color.inputField)
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var anglerSelectionSection: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("ANGLERS ON TRIP")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundColor(Color.surfaceSecondary)
                
                // Existing Angler List Checklist
                if !existingAnglers.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(existingAnglers) { angler in
                            Button(action: {
                                toggleAnglerSelection(angler)
                            }) {
                                HStack {
                                    Text(angler.name)
                                        .cvFont(CVFont.primaryBody)
                                        .foregroundColor(selectedAnglers.contains(angler) ? Color.white : Color.surfacePrimary)
                                    Spacer()
                                    Image(systemName: selectedAnglers.contains(angler) ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundColor(selectedAnglers.contains(angler) ? Color.brandAccent : Color.brandAccent)
                                }
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .background(selectedAnglers.contains(angler) ? Color.brandAccent : Color.clear)
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Inline New Angler Input
                HStack(spacing: 8) {
                    TextField("Add new angler...", text: $newAnglerName)
                        .cvFont(CVFont.primaryBody)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(Color.inputField)
                        .cornerRadius(8)
                    
                    Button(action: addNewAnglerInline) {
                        Text("Add")
                            .cvFont(CVFont.actionLabel)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .frame(height: 44)
                            .background(newAnglerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.brandAccent : Color.brandAccent)
                            .cornerRadius(8)
                    }
                    .disabled(newAnglerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var startTimeSection: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("START TIME")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundColor(Color.surfaceSecondary)
                
                DatePicker(
                    "Start Time",
                    selection: $startTime,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .cvFont(CVFont.primaryBody)
                .labelsHidden()
                .frame(height: 44)
            }
        }
    }
    
    private var startTripButton: some View {
        Button(action: executeStartTrip) {
            HStack {
                Spacer()
                Text("Start Trip")
                    .cvFont(CVFont.actionLabel)
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height: 50)
            .background(isValid ?  Color.brandAccent : Color.brandPrimary)
            .cornerRadius(12)
        }
        .disabled(!isValid)
        .padding(.top, 8)
    }
    
    // MARK: - Actions & Persistence
    
    private func toggleAnglerSelection(_ angler: Angler) {
        if selectedAnglers.contains(angler) {
            selectedAnglers.remove(angler)
        } else {
            selectedAnglers.insert(angler)
        }
    }
    
    private func addNewAnglerInline() {
        let trimmed = newAnglerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Deduplication check (case-insensitive)
        if let existing = existingAnglers.first(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            selectedAnglers.insert(existing)
        } else {
            let newAngler = Angler(name: trimmed)
            modelContext.insert(newAngler)
            try? modelContext.save()
            selectedAnglers.insert(newAngler)
        }
        
        newAnglerName = ""
    }
    
    private func executeStartTrip() {
        guard let reservoir = selectedReservoir, !selectedAnglers.isEmpty else { return }
        
        let newTrip = Trip(
            startTime: startTime,
            reservoir: reservoir,
            anglers: Array(selectedAnglers)
        )
        
        modelContext.insert(newTrip)
        
        do {
            try modelContext.save()
            onTripStarted?(newTrip)
            dismiss()
        } catch {
            print("Failed to start and save new trip: \(error)")
        }
    }
}
