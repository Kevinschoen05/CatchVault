//
//  ReservoirDetailsView.swift
//  CatchVault
//

import SwiftUI
import SwiftData

public struct ReservoirDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    
    /// Target reservoir entity bound directly from caller
    let reservoir: Reservoir
    
    // MARK: - State Management
    
    @State private var selectedYear: Int? = nil
    @State private var showingStartTripSheet: Bool = false
    @State private var activeTrip: Trip? = nil
    
    // MARK: - Filter Extraction & Computations
    
    /// Dynamically computes available years across all historical trips for this reservoir
    private var availableYears: [Int] {
        let years = reservoir.trips.map { Calendar.current.component(.year, from: $0.startTime) }
        return Array(Set(years)).sorted(by: >)
    }
    
    /// Chronologically sorted (descending) trips filtered by selectedYear
    private var filteredTrips: [Trip] {
        reservoir.trips
            .filter { trip in
                guard let year = selectedYear else { return true }
                return Calendar.current.component(.year, from: trip.startTime) == year
            }
            .sorted { $0.startTime > $1.startTime }
    }
    
    /// Aggregate telemetry metrics calculated dynamically across filtered trips
    private var totalTripsCount: Int {
        filteredTrips.count
    }
    
    private var totalFishCount: Int {
        filteredTrips.reduce(0) { $0 + $1.catches.count }
    }
    
    private var totalWeight: Double {
        filteredTrips.reduce(0.0) { sum, trip in
            sum + trip.catches.reduce(0.0) { $0 + $1.weight }
        }
    }
    
    // MARK: - Initializer
    
     init(reservoir: Reservoir) {
        self.reservoir = reservoir
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Layer 0 Base Canvas Backdrop
            Color.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // 1. Top Temporal Filter Pill on Canvas Backdrop
                    CVYearPicker(
                        selectedYear: $selectedYear,
                        availableYears: availableYears
                    )
                    
                    // 2. Aggregate Telemetry Card
                    telemetryCard
                    
                    // 3. CatchMap Placeholder Container
                    catchMapPlaceholderCard
                    
                    // 4. Primary Modal Action Trigger
                    startTripButton
                    
                    // 5. Historical Trip Ledger
                    tripHistoryLedgerSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(reservoir.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.backgroundMain, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        
        // Modal Sheet setup for launching a new trip session
        .sheet(isPresented: $showingStartTripSheet) {
            StartTripView(
                reservoir: reservoir,
                onTripStarted: { createdTrip in
                    showingStartTripSheet = false
                    // Hand off new trip to launch ActiveTripView workspace
                    activeTrip = createdTrip
                }
            )
        }
        
        // Modal fullScreenCover transitioning directly into ActiveTripView
        .fullScreenCover(item: $activeTrip) { trip in
            ActiveTripView(trip: trip)
        }
        
        // Programmatic Value-Based Navigation Target for historical trip details
        .navigationDestination(for: Trip.self) { trip in
           TripDetailsView(trip: trip)
        }
    }
    
    // MARK: - Subviews
    
    /// High-density Telemetry Card evaluating aggregate metrics
    private var telemetryCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Reservoir Totals")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                HStack(spacing: 12) {
                    // Total Trips Metric
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Trips")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(totalTripsCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .frame(height: 32)
                        .background(Color.secondary.opacity(0.2))
                    
                    // Total Fish Count Metric
                    VStack(alignment: .center, spacing: 4) {
                        Text("Total Fish")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(totalFishCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Divider()
                        .frame(height: 32)
                        .background(Color.secondary.opacity(0.2))
                    
                    // Total Weight (lbs) Metric
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Mass")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text(String(format: "%.2f lbs", totalWeight))
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
    
    /// CatchMap Placeholder Card (Reserved 180pt height for MapKit integration)
    private var catchMapPlaceholderCard: some View {
        CVCardContainer {
            VStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.brandAccent)
                
                Text("Catch Map Placeholder")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Text("Spatial coordinates from catches logged on this reservoir will render here.")
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
        }
    }
    
    /// Primary Action CTA ("Start Trip")
    private var startTripButton: some View {
        Button(action: {
            showingStartTripSheet = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                    .font(.body.weight(.semibold))
                
                Text("Start Trip")
                    .cvFont(CVFont.actionLabel)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.brandAccent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    /// Chronological Historical Trip Ledger Section
    private var tripHistoryLedgerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trip History")
                .cvFont(CVFont.sectionHeader)
                .foregroundStyle(Color.white)
                .padding(.leading, 4)
            
            if filteredTrips.isEmpty {
                emptyTripsCard
            } else {
                ForEach(filteredTrips) { trip in
                    tripLedgerTile(for: trip)
                }
            }
        }
    }
    
    /// Individual Historical Trip Tile Component
    private func tripLedgerTile(for trip: Trip) -> some View {
        let catchesCount = trip.catches.count
        let totalMass = trip.catches.reduce(0.0) { $0 + $1.weight }
        let formattedDate = trip.startTime.formatted(date: .abbreviated, time: .shortened)
        let anglerNames = trip.anglers.map { $0.name }.joined(separator: ", ")
        
        return CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                // Header Row: Date & View Details Link
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formattedDate)
                            .cvFont(CVFont.sectionHeader)
                            .foregroundStyle(Color.primary)
                        
                        Text(anglerNames.isEmpty ? "No Anglers Recorded" : anglerNames)
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Value-Based Navigation Trigger to TripDetailsView
                    NavigationLink(value: trip) {
                        HStack(spacing: 4) {
                            Text("View Details")
                                .cvFont(CVFont.metadata)
                                .foregroundStyle(Color.brandAccent)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.brandAccent)
                        }
                        .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                // Telemetry Row: Fish Count & Mass
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Text("Fish Landed:")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(catchesCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Text("Total Mass:")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text(String(format: "%.2f lbs", totalMass))
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                    }
                }
            }
        }
    }
    
    /// Empty State Card displayed when no trips match the active year filter
    private var emptyTripsCard: some View {
        CVCardContainer {
            VStack(spacing: 8) {
                Text("No Trips Found")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Text("No recorded fishing trips match the active year filter for this reservoir.")
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }
}
