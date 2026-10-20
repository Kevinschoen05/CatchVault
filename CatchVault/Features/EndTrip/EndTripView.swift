import SwiftUI
import SwiftData

struct EndTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    /// Dismiss callback trigger to signal parent ActiveTripView dismissal upon trip closure
    var onTripCompleted: (() -> Void)?
    
    @State private var viewModel: EndTripViewModel
    @State private var showingDiscardAlert: Bool = false
    
    init(trip: Trip, onTripCompleted: (() -> Void)? = nil) {
        _viewModel = State(initialValue: EndTripViewModel(trip: trip))
        self.onTripCompleted = onTripCompleted
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Layer 0 Base Canvas Backdrop
                Color.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 1. Final Telemetry Header Card
                        telemetryHeaderCard
                        
                        // 2. Session Highlights Card (Anglers & Species Breakdown)
                        sessionHighlightsCard
                        
                        // 3. Observations & Commentary Card (Multiline Notes)
                        observationsCard
                        
                        // 4. Action Buttons ("Complete & Save Trip", "Resume Session", & "Discard Session")
                        actionsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("End Trip Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.backgroundMain, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Resume") {
                        dismiss()
                    }
                    .foregroundStyle(Color.textOnCardSecondary)
                    .disabled(viewModel.isSaving)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Discard Active Trip?", isPresented: $showingDiscardAlert) {
                Button("Resume Session", role: .cancel) { }
                Button("Discard Trip", role: .destructive) {
                    discardActiveTrip()
                }
            } message: {
                Text("Are you sure you want to quit? All catches logged during this session will be permanently deleted.")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var telemetryHeaderCard: some View {
        CVCardContainer {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.trip.reservoir?.name ?? "Unknown Reservoir")
                            .cvFont(CVFont.sectionHeader)
                            .foregroundStyle(Color.textOnCardPrimary)
                        
                        Text(viewModel.anglersFormattedString)
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                    }
                    Spacer()
                }
                
                Divider()
                    .background(Color.textOnCardSecondary.opacity(0.2))
                
                VStack(spacing: 2) {
                    Text("FINAL TRIP DURATION")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.textOnCardSecondary)
                    
                    Text(viewModel.formattedFinalDuration)
                        .cvFont(CVFont.telemetryHeavy)
                        .font(.system(size: 34, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.textOnCardPrimary)
                }
                .padding(.vertical, 4)
                
                Divider()
                    .background(Color.textOnCardSecondary.opacity(0.2))
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Fish")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                        Text("\(viewModel.totalCatchesCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.textOnCardPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .frame(height: 32)
                        .background(Color.textOnCardSecondary.opacity(0.2))
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Weight")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                        Text(String(format: "%.2f lbs", viewModel.totalWeight))
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.textOnCardPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
    
    private var sessionHighlightsCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 10) {
                Text("Session Species Breakdown")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.textOnCardPrimary)
                
                if viewModel.speciesSummary.isEmpty {
                    Text("No catches recorded for this session.")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.textOnCardSecondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(viewModel.speciesSummary, id: \.speciesName) { item in
                        HStack {
                            Text(item.speciesName)
                                .cvFont(CVFont.primaryBody)
                                .foregroundStyle(Color.textOnCardPrimary)
                            Spacer()
                            Text("\(item.count) landed")
                                .cvFont(CVFont.metadata)
                                .foregroundStyle(Color.brandAccent)
                        }
                    }
                }
            }
        }
    }
    
    private var observationsCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Text("Trip Notes & Observations")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.textOnCardPrimary)
                
                TextField(
                    "",
                    text: $viewModel.tripNotes,
                    prompt: Text("Water clarity, weather, active lures, tactics...").foregroundStyle(Color.textOnCardSecondary.opacity(0.6)),
                    axis: .vertical
                )
                .cvFont(CVFont.primaryBody)
                .foregroundStyle(Color.textOnCardPrimary)
                .lineLimit(4...8)
                .padding(10)
                .background(Color.surfaceSecondary.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            // "Complete & Save Trip" Primary CTA
            Button {
                Task {
                    if await viewModel.saveAndEndTrip(context: modelContext) {
                        onTripCompleted?()
                        dismiss()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isFetchingWeather {
                        ProgressView()
                            .tint(.white)
                        Text("Fetching Weather & Saving...")
                            .cvFont(CVFont.actionLabel)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("Complete & Save Trip")
                            .cvFont(CVFont.actionLabel)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.brandAccent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSaving)
            
            // "Resume Session" Secondary CTA
            Button {
                dismiss()
            } label: {
                Text("Resume Session")
                    .cvFont(CVFont.actionLabel)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.surfaceSecondary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSaving)
            
            // "Discard Session" Destructive CTA
            Button {
                showingDiscardAlert = true
            } label: {
                Text("Discard Trip Without Saving")
                    .cvFont(CVFont.actionLabel)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundStyle(Color.red)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSaving)
        }
    }
    
    // MARK: - Actions
    
    private func discardActiveTrip() {
        modelContext.delete(viewModel.trip)
        do {
            try modelContext.save()
            onTripCompleted?()
            dismiss()
        } catch {
            print("Failed to discard active trip: \(error)")
        }
    }
}
