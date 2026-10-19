import SwiftUI
import SwiftData

struct ActiveTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    /// Binds directly to the active session view model.
    @State private var viewModel: ActiveTripViewModel
    
    /// Modal presentation triggers for operational sub-workflows.
    @State private var showingRecordFishSheet: Bool = false
    @State private var showingEndTripSheet: Bool = false
    
    // MARK: - Initializer
    
    init(trip: Trip) {
        _viewModel = State(initialValue: ActiveTripViewModel(trip: trip))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Layer 0 Base Canvas Background (Standardized app-wide backdrop)
                Color.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 1. Session Status & Live Ticker Card
                        statusHeaderCard
                        
                        // 2. Real-Time Telemetry Summary
                        telemetrySummaryCard
                        
                        // 3. Primary Action Triggers ("Record Fish" & "End Trip")
                        actionButtonsSection
                        
                        // 4. Live Catch Timeline
                        catchTimelineSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Active Trip")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.backgroundMain, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                viewModel.startTimer()
            }
            .onDisappear {
                viewModel.pauseTimer()
            }
            // MARK: - Modal Workflows
            .sheet(isPresented: $showingRecordFishSheet) {
                RecordFishView(trip: viewModel.trip)
                    .presentationDetents([.large])
            }
            .sheet(isPresented: $showingEndTripSheet) {
                EndTripView(
                    trip: viewModel.trip,
                    onTripCompleted: {
                        // Dismiss parent ActiveTripView workspace cleanly back to ReservoirHome
                        dismiss()
                    }
                )
                .presentationDetents([.large])
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Layer 1 Container displaying Reservoir name, Angler roster, and running stopwatch.
    private var statusHeaderCard: some View {
        CVCardContainer {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.trip.reservoir?.name ?? "Unknown Reservoir")
                            .cvFont(CVFont.sectionHeader)
                            .foregroundStyle(Color.textOnCardPrimary)
                        
                        Text(anglersFormattedString)
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                    }
                    
                    Spacer()
                    
                    // Active Status Indicator Pill
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.statusActive)
                            .frame(width: 8, height: 8)
                        
                        Text("LIVE")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.statusActive)
                            .bold()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.statusActive.opacity(0.15))
                    .clipShape(Capsule())
                }
                
                Divider()
                    .background(Color.textOnCardSecondary.opacity(0.2))
                
                // Running Stopwatch Display
                VStack(spacing: 2) {
                    Text("ELAPSED DURATION")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.textOnCardSecondary)
                    
                    Text(viewModel.formattedElapsedTime)
                        .cvFont(CVFont.telemetryHeavy)
                        .font(.system(size: 38, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.textOnCardPrimary)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    /// Layer 1 Container displaying total fish landed and cumulative weight telemetry.
    private var telemetrySummaryCard: some View {
        CVCardContainer {
            HStack(spacing: 16) {
                // Total Catches Telemetry
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
                    .frame(height: 36)
                    .background(Color.textOnCardSecondary.opacity(0.2))
                
                // Total Weight Telemetry
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
    
    /// Primary Action Controls with distinct tactical styling.
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // "Record Fish" Primary Tactical CTA (Beacon Amber)
            Button {
                showingRecordFishSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Record Fish")
                        .cvFont(CVFont.actionLabel)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50) // Enforces explicit 50pt primary CTA height
                .background(Color.brandAccent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            
            // "End Trip" Secondary CTA (Slate Blue Surface Secondary)
            Button {
                showingEndTripSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.subheadline)
                    Text("End Trip")
                        .cvFont(CVFont.actionLabel)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44) // 44pt touch geometry
                .background(Color.surfaceSecondary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
    
    /// Chronological list of catches logged during the active session.
    private var catchTimelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Timeline")
                .cvFont(CVFont.sectionHeader)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 4)
            
            if viewModel.trip.catches.isEmpty {
                CVCardContainer {
                    VStack(spacing: 8) {
                        Image(systemName: "fish")
                            .font(.largeTitle)
                            .foregroundStyle(Color.textOnCardSecondary.opacity(0.6))
                        
                        Text("No Catches Logged Yet")
                            .cvFont(CVFont.primaryBody)
                            .foregroundStyle(Color.textOnCardPrimary)
                        
                        Text("Tap 'Record Fish' above to log your first catch for this trip.")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            } else {
                ForEach(viewModel.trip.catches.sorted(by: { $0.timestamp > $1.timestamp })) { catchItem in
                    catchRowTile(for: catchItem)
                }
            }
        }
    }
    
    /// Individual catch tile inside Layer 1 CVCardContainer.
    private func catchRowTile(for catchItem: FishCatch) -> some View {
        CVCardContainer {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(catchItem.species?.name ?? "Unknown Species")
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.textOnCardPrimary)
                    
                    HStack(spacing: 8) {
                        Text(catchItem.angler?.name ?? "Unknown Angler")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                        
                        Text("•")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                        
                        Text(catchItem.timestamp.formatted(date: .omitted, time: .shortened))
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                    }
                    
                    if let comment = catchItem.comment, !comment.isEmpty {
                        Text(comment)
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                            .lineLimit(1)
                            .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                Text(String(format: "%.2f lbs", catchItem.weight))
                    .cvFont(CVFont.telemetryMedium)
                    .foregroundStyle(Color.brandAccent)
            }
        }
    }
    
    // MARK: - Helpers

    private var anglersFormattedString: String {
        let anglers = viewModel.trip.anglers
        guard !anglers.isEmpty else { return "No Anglers Assigned" }
        
        return anglers
            .map { $0.name }
            .sorted()
            .joined(separator: ", ")
    }
} 
