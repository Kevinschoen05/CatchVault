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
    
    @State private var selectedViewerImage: UIImage? = nil
    
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
        .fullScreenCover(item: Binding(
            get: { selectedViewerImage.map { IdentifiableImage(image: $0) } },
            set: { selectedViewerImage = $0?.image }
        )) { item in
            FullScreenPhotoViewer(image: item.image)
        }
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
                            .foregroundStyle(Color.textOnCardPrimary)
                        
                        Text(formattedAnglers)
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                    }
                    Spacer()
                }
                
                Divider()
                    .background(Color.textOnCardSecondary.opacity(0.2))
                
                // Session Timing & Human-Readable Elapsed Duration
                VStack(spacing: 4) {
                    Text("SESSION DURATION")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.textOnCardSecondary)
                    
                    Text(formattedDuration)
                        .cvFont(CVFont.telemetryHeavy)
                        .foregroundStyle(Color.textOnCardPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text(trip.startTime.formatted(date: .abbreviated, time: .shortened))
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.textOnCardSecondary)
                }
                .padding(.vertical, 4)
                
                Divider()
                    .background(Color.textOnCardSecondary.opacity(0.2))
                
                // Telemetry Metrics Grid
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Fish")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                        
                        Text("\(totalCatchesCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.textOnCardPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .frame(height: 32)
                        .background(Color.textOnCardSecondary.opacity(0.2))
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Mass")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                        
                        Text(String(format: "%.2f lbs", totalWeight))
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.textOnCardPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
    
    /// Live Spatial Catch Map Card replacing static placeholder
    private var tripCatchMapCard: some View {
            TripCatchMapView(catches: trip.catches)
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
                        .foregroundStyle(Color.textOnCardPrimary)
                }
                
                Divider()
                    .background(Color.textOnCardSecondary.opacity(0.2))
                
                if let summary = trip.weatherSummary, !summary.isEmpty {
                    Text(summary)
                        .cvFont(CVFont.primaryBody)
                        .foregroundStyle(Color.textOnCardPrimary)
                    
                    HStack(spacing: 16) {
                        if let temp = trip.temperature {
                            Text(String(format: "Temp: %.1f°F", temp))
                                .cvFont(CVFont.metadata)
                                .foregroundStyle(Color.textOnCardSecondary)
                        }
                        if let wind = trip.windSpeed {
                            Text(String(format: "Wind: %.1f mph", wind))
                                .cvFont(CVFont.metadata)
                                .foregroundStyle(Color.textOnCardSecondary)
                        }
                    }
                } else {
                    Text("No weather observations were recorded during this session.")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.textOnCardSecondary)
                }
            }
        }
    }
    
    /// Chronological Catch Log Feed Section
    private var catchLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Catch Log")
                .cvFont(CVFont.sectionHeader)
                .foregroundStyle(Color.white)
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
                HStack(spacing: 12) {
                    // Thumbnail trigger for FullScreenPhotoViewer
                    if let relativePath = catchItem.imagePath {
                        let thumbPath = ImageStorageService.shared.thumbnailPath(for: relativePath)
                        if let thumbImage = ImageStorageService.shared.loadImage(relativePath: thumbPath) {
                            Button {
                                if let fullImage = ImageStorageService.shared.loadImage(relativePath: relativePath) {
                                    selectedViewerImage = fullImage
                                }
                            } label: {
                                Image(uiImage: thumbImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 52, height: 52)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(catchItem.species?.name ?? "Unknown Species")
                            .cvFont(CVFont.sectionHeader)
                            .foregroundStyle(Color.textOnCardPrimary)
                        
                        Text("Landed by \(catchItem.angler?.name ?? "Unknown Angler")")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.2f lbs", catchItem.weight))
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.brandAccent)
                        
                        Text(catchItem.timestamp.formatted(date: .omitted, time: .shortened))
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                    }
                }
                
                if let comment = catchItem.comment, !comment.isEmpty {
                    Divider()
                        .background(Color.textOnCardSecondary.opacity(0.2))
                    
                    Text(comment)
                        .cvFont(CVFont.primaryBody)
                        .foregroundStyle(Color.textOnCardSecondary)
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
                    .foregroundStyle(Color.textOnCardPrimary)
                
                Text("No fish catches were logged for this session.")
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.textOnCardSecondary)
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
                    .foregroundStyle(Color.textOnCardPrimary)
                
                Text(notes)
                    .cvFont(CVFont.primaryBody)
                    .foregroundStyle(Color.textOnCardPrimary)
            }
        }
    }
}

// MARK: - Identifiable Image Helper for Sheet Binding
private struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - Spatial Map Subview
