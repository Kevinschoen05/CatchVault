//
//  TripDetailsView.swift
//  CatchVault
//

import SwiftUI
import SwiftData
import MapKit

public struct TripDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    
    /// Target trip entity bound directly via value-based navigation
    let trip: Trip
    
    // MARK: - Initializer
    
     init(trip: Trip) {
        self.trip = trip
    }
    
    // MARK: - Formatter Configuration
    
    /// User-friendly duration formatter (e.g., "10h 15m 30s")
    private static let readableDurationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter
    }()
    
    // MARK: - Computed Properties & Metrics
    
    /// Formatted human-readable session duration
    private var formattedDuration: String {
        let end = trip.endTime ?? Date()
        let elapsed = max(0, end.timeIntervalSince(trip.startTime))
        
        return Self.readableDurationFormatter.string(from: elapsed) ?? "0m 0s"
    }
    
    /// Total landed catch count
    private var totalCatchesCount: Int {
        trip.catches.count
    }
    
    /// Cumulative weight landed in pounds
    private var totalWeight: Double {
        trip.catches.reduce(0.0) { $0 + $1.weight }
    }
    
    /// Alphabetized participating angler roster string
    private var formattedAnglers: String {
        guard !trip.anglers.isEmpty else { return "No Anglers Assigned" }
        return trip.anglers.map { $0.name }.sorted().joined(separator: ", ")
    }
    
    /// Chronologically sorted (descending) catches logged during this trip
    private var sortedCatches: [FishCatch] {
        trip.catches.sorted { $0.timestamp > $1.timestamp }
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Layer 0 Base Canvas Backdrop
            Color.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // 1. Session Overview & Telemetry Header Card
                    sessionOverviewCard
                    
                    // 2. Spatial CatchMap Container (Live Interactive Map)
                    tripCatchMapCard
                    
                    // 3. Weather Snapshot Container
                    weatherSnapshotCard
                    
                    // 4. Chronological Catch Log Feed
                    catchLogSection
                    
                    // 5. Session Observations & Notes Card
                    if let notes = trip.notes, !notes.isEmpty {
                        sessionNotesCard(notes: notes)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.backgroundMain, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    // MARK: - Subviews
    
    /// Layer 1 Overview Card displaying Reservoir, Anglers, Duration, and Aggregated Metrics
    private var sessionOverviewCard: some View {
        CVCardContainer {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.reservoir?.name ?? "Unknown Reservoir")
                            .cvFont(CVFont.sectionHeader)
                            .foregroundStyle(Color.primary)
                        
                        Text(formattedAnglers)
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                    }
                    Spacer()
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                // Session Timing & Human-Readable Elapsed Duration
                VStack(spacing: 4) {
                    Text("SESSION DURATION")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.secondary)
                    
                    Text(formattedDuration)
                        .cvFont(CVFont.telemetryHeavy)
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text(trip.startTime.formatted(date: .abbreviated, time: .shortened))
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.secondary)
                }
                .padding(.vertical, 4)
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                // Telemetry Metrics Grid
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Fish")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(totalCatchesCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .frame(height: 32)
                        .background(Color.secondary.opacity(0.2))
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Mass")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text(String(format: "%.2f lbs", totalWeight))
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
    
    /// Live Spatial Catch Map Card replacing static placeholder
    private var tripCatchMapCard: some View {
        CVCardContainer {
            TripCatchMapView(catches: trip.catches)
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    /// Weather Telemetry Snapshot Card
    private var weatherSnapshotCard: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "cloud.sun.fill")
                        .foregroundStyle(Color.brandAccent)
                    
                    Text("Weather & Environmental Snapshot")
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.primary)
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                if let summary = trip.weatherSummary, !summary.isEmpty {
                    Text(summary)
                        .cvFont(CVFont.primaryBody)
                        .foregroundStyle(Color.primary)
                    
                    HStack(spacing: 16) {
                        if let temp = trip.temperature {
                            Text(String(format: "Temp: %.1f°F", temp))
                                .cvFont(CVFont.metadata)
                                .foregroundStyle(Color.secondary)
                        }
                        if let wind = trip.windSpeed {
                            Text(String(format: "Wind: %.1f mph", wind))
                                .cvFont(CVFont.metadata)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                } else {
                    Text("No weather observations were recorded during this session.")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    /// Chronological Catch Log Feed Section
    private var catchLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Catch Log")
                .cvFont(CVFont.sectionHeader)
                .foregroundStyle(Color.primary)
                .padding(.leading, 4)
            
            if sortedCatches.isEmpty {
                emptyCatchLogCard
            } else {
                ForEach(sortedCatches) { catchItem in
                    catchLogTile(for: catchItem)
                }
            }
        }
    }
    
    /// Individual Catch Item Tile Component
    private func catchLogTile(for catchItem: FishCatch) -> some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(catchItem.species?.name ?? "Unknown Species")
                            .cvFont(CVFont.sectionHeader)
                            .foregroundStyle(Color.primary)
                        
                        Text("Landed by \(catchItem.angler?.name ?? "Unknown Angler")")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.2f lbs", catchItem.weight))
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.brandAccent)
                        
                        Text(catchItem.timestamp.formatted(date: .omitted, time: .shortened))
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                if let comment = catchItem.comment, !comment.isEmpty {
                    Divider()
                        .background(Color.secondary.opacity(0.2))
                    
                    Text(comment)
                        .cvFont(CVFont.primaryBody)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }
    
    /// Empty State Card when no catches are attached to the trip
    private var emptyCatchLogCard: some View {
        CVCardContainer {
            VStack(spacing: 8) {
                Text("No Fish Recorded")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Text("No fish catches were logged for this session.")
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
    
    /// Session Commentary & Notes Card
    private func sessionNotesCard(notes: String) -> some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Text("Session Notes & Tactics")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Text(notes)
                    .cvFont(CVFont.primaryBody)
                    .foregroundStyle(Color.primary)
            }
        }
    }
}

// MARK: - Spatial Map Subview

private struct TripCatchMapView: View {
    let catches: [FishCatch]
    
    /// Filtered list of catches containing valid GPS coordinates
    private var mappedCatches: [FishCatch] {
        catches.filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Group {
            if mappedCatches.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.brandAccent)
                    
                    Text("Session Catch Map")
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.primary)
                    
                    Text("No GPS coordinates recorded for catches on this trip.")
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
            }
        }
    }
    
    /// Evaluates bounding box across all catches to center map camera cleanly
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
