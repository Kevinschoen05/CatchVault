//
//  ReservoirDetailsView.swift
//  CatchVault
//

import SwiftUI
import SwiftData
import MapKit

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
                    
                    // 3. CatchMap Container (Live Interactive Reservoir Map)
                    reservoirCatchMapCard
                    
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
                Text("Water Body Telemetry")
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
    
    /// Live Spatial Catch Map Card replacing static placeholder
    private var reservoirCatchMapCard: some View {
        CVCardContainer {
            ReservoirCatchMapView(trips: filteredTrips)
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 8))
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
                .foregroundStyle(Color.primary)
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
        
        // Derive unique anglers across both trip.anglers and individual catches
        let directAnglerNames = trip.anglers.map { $0.name }
        let catchAnglerNames = trip.catches.compactMap { $0.angler?.name }
        let allUniqueAnglers = Array(Set(directAnglerNames + catchAnglerNames)).sorted()
        let anglerNames = allUniqueAnglers.joined(separator: ", ")
        
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

// MARK: - Spatial Reservoir Map Subview

private struct ReservoirCatchMapView: View {
    let trips: [Trip]
    
    /// Aggregates catches across all filtered trips that contain valid GPS coordinates
    private var mappedCatches: [FishCatch] {
        trips.flatMap { $0.catches }
            .filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Group {
            if mappedCatches.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.brandAccent)
                    
                    Text("Reservoir Catch Map")
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.primary)
                    
                    Text("No GPS coordinates recorded for catches in this temporal view.")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Map(position: $cameraPosition) {
                    ForEach(mappedCatches) { catchItem in
                        if let lat = catchItem.latitude, let lon = catchItem.longitude {
                            let speciesName = catchItem.species?.name ?? "Fish"
                            let monogram = String(speciesName.prefix(1)).uppercased()
                            
                            Marker(
                                speciesName,
                                monogram: Text(monogram),
                                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            )
                            .tint(SpeciesColorProvider.color(for: catchItem.species?.name))
                        }
                    }
                }
                .mapStyle(.standard)
                .onAppear {
                    configureCameraPosition()
                }
                .onChange(of: trips) { _, _ in
                    configureCameraPosition()
                }
            }
        }
    }
    
    /// Computes bounding region across all aggregated catch locations to frame camera
    private func configureCameraPosition() {
        let coords = mappedCatches.compactMap { catchItem -> CLLocationCoordinate2D? in
            guard let lat = catchItem.latitude, let lon = catchItem.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        guard !coords.isEmpty else { return }
        
        if coords.count == 1 {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coords[0],
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        } else {
            let latitudes = coords.map { $0.latitude }
            let longitudes = coords.map { $0.longitude }
            
            let minLat = latitudes.min()!
            let maxLat = latitudes.max()!
            let minLon = longitudes.min()!
            let maxLon = longitudes.max()!
            
            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2.0,
                longitude: (minLon + maxLon) / 2.0
            )
            
            let latDelta = max((maxLat - minLat) * 1.4, 0.008)
            let lonDelta = max((maxLon - minLon) * 1.4, 0.008)
            
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: center,
                    span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                )
            )
        }
    }
}
