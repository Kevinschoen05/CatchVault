//
//  AnalyticsDashboardView.swift
//  CatchVault
//

import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData Query fetching all trips and fish catches directly
    @Query(sort: \Trip.startTime, order: .reverse) private var allTrips: [Trip]
    @Query private var allCatches: [FishCatch]
    
    @State private var selectedYear: Int? = nil
    
    // MARK: - Computed Filtered Collections
    
    /// Dynamically extracts available years from recorded trips
    private var availableYears: [Int] {
        let years = allTrips.map { Calendar.current.component(.year, from: $0.startTime) }
        return Array(Set(years)).sorted(by: >)
    }
    
    /// Trips filtered by selected year (or all trips if selectedYear is nil)
    private var filteredTrips: [Trip] {
        guard let year = selectedYear else { return allTrips }
        return allTrips.filter { Calendar.current.component(.year, from: $0.startTime) == year }
    }
    
    /// Catches filtered by selected year (or all catches if selectedYear is nil)
    private var filteredCatches: [FishCatch] {
        guard let year = selectedYear else { return allCatches }
        return allCatches.filter { Calendar.current.component(.year, from: $0.timestamp) == year }
    }
    
    // MARK: - Calculated Telemetry Metrics
    
    private var totalFishCount: Int {
        filteredCatches.count
    }
    
    private var totalTripsCount: Int {
        filteredTrips.count
    }
    
    private var totalMassLbs: Double {
        filteredCatches.reduce(0.0) { $0 + $1.weight }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Layer 0 Base Canvas Backdrop
            Color.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // 1. Master Temporal Filter
                    CVYearPicker(
                        selectedYear: $selectedYear,
                        availableYears: availableYears
                    )
                    
                    // 2. High-Level Telemetry Cards (Real-Time Live Aggregations)
                    highLevelMetricsSection
                    
                    // 3. Navigation Grid to Analytical Breakdown Views
                    breakdownNavigationGrid
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.backgroundMain, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    // MARK: - Subviews
    
    /// High-level summary metrics card displaying live aggregations
    private var highLevelMetricsSection: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                // Header text formatting fixed to explicitly format years without commas
                Text(selectedYear == nil ? "All-Time Performance Summary" : "\(String(format: "%d", selectedYear!)) Performance Summary")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                HStack(spacing: 12) {
                    // Total Fish Stat
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Fish")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(totalFishCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .frame(height: 32)
                        .background(Color.secondary.opacity(0.2))
                    
                    // Total Trips Stat
                    VStack(alignment: .center, spacing: 4) {
                        Text("Total Trips")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(totalTripsCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Divider()
                        .frame(height: 32)
                        .background(Color.secondary.opacity(0.2))
                    
                    // Total Mass Stat (Line limit and minimum scale factor prevent multi-line wrapping)
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Mass")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text(String(format: "%.2f lbs", totalMassLbs))
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
    
    /// Navigation tiles leading to specific analytical breakdown screens
    private var breakdownNavigationGrid: some View {
        VStack(spacing: 12) {
            analyticsTile(
                title: "Angler Totals",
                subtitle: "Total catches, averages, and species breakdown per angler.",
                icon: "person.3.fill",
                destination: Text("Angler Totals View (Placeholder)")
            )
            
            analyticsTile(
                title: "Reservoir Leaderboard",
                subtitle: "Top-10 heaviest fish recorded per body of water.",
                icon: "trophy.fill",
                destination: Text("Reservoir Leaderboard View (Placeholder)")
            )
            
            analyticsTile(
                title: "Species Breakdown",
                subtitle: "Distribution profiles and landed volumes across reservoirs.",
                icon: "fish.fill",
                destination: Text("Species Breakdown View (Placeholder)")
            )
            
            analyticsTile(
                title: "Catch Trends",
                subtitle: "Monthly temporal catches and seasonal performance trends.",
                icon: "chart.line.uptrend.xyaxis",
                destination: Text("Catch Trends View (Placeholder)")
            )
        }
    }
    
    /// Helper tile wrapper matching standard Layer 1 card styling and touch targets
    private func analyticsTile<Destination: View>(
        title: String,
        subtitle: String,
        icon: String,
        destination: Destination
    ) -> some View {
        CVCardContainer {
            NavigationLink(destination: destination) {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(Color.brandAccent)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .cvFont(CVFont.sectionHeader)
                            .foregroundStyle(Color.primary)
                        
                        Text(subtitle)
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
