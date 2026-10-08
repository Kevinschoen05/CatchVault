//
//  SpeciesBreakdownView.swift
//  CatchVault
//

import SwiftUI
import SwiftData
import Charts

struct SpeciesBreakdownView: View {
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData Queries fetching domain entities
    @Query(sort: \Species.name) private var speciesList: [Species]
    @Query private var catches: [FishCatch]
    @Query private var trips: [Trip]
    @Query(sort: \Reservoir.name) private var reservoirs: [Reservoir]
    
    // State filters
    @State private var selectedYear: Int? = nil
    
    // MARK: - Filter Extraction
    
    /// Dynamically extracts available years across all recorded trips
    private var availableYears: [Int] {
        let years = trips.map { Calendar.current.component(.year, from: $0.startTime) }
        return Array(Set(years)).sorted(by: >)
    }
    
    /// Catches filtered strictly by active selected year
    private var filteredCatches: [FishCatch] {
        guard let year = selectedYear else { return catches }
        return catches.filter { Calendar.current.component(.year, from: $0.timestamp) == year }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Layer 0 Base Canvas Backdrop
            Color.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // 1. Top Element: Centered Temporal Year Picker on Layer 0 Canvas
                    CVYearPicker(
                        selectedYear: $selectedYear,
                        availableYears: availableYears
                    )
                    
                    let activeSpeciesData = computeActiveSpeciesData()
                    
                    if activeSpeciesData.isEmpty {
                        emptySpeciesCard
                    } else {
                        // 2. Overview Chart Card
                        overviewChartCard(speciesData: activeSpeciesData)
                        
                        // 3. Species Spatial Breakdown Cards
                        ForEach(activeSpeciesData, id: \.species.id) { item in
                            speciesSpatialCard(for: item)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Species Distribution")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.backgroundMain, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    // MARK: - Subviews
    
    /// Layer 1 Container displaying top-level horizontal bar chart of species landing volumes
    private func overviewChartCard(speciesData: [SpeciesData]) -> some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Total Volume by Species")
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                        .foregroundStyle(Color.brandAccent)
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                Chart(speciesData, id: \.species.id) { item in
                    BarMark(
                        x: .value("Count", item.totalCount),
                        y: .value("Species", item.species.name)
                    )
                    .foregroundStyle(Color.brandAccent)
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                            .foregroundStyle(Color.secondary.opacity(0.15))
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                    }
                }
                .frame(height: max(140, CGFloat(speciesData.count * 36)))
                .padding(.vertical, 4)
            }
        }
    }
    
    /// Layer 1 Container presenting detailed spatial breakdown per reservoir for a single species
    private func speciesSpatialCard(for item: SpeciesData) -> some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                // Species Header & Total Badge
                HStack {
                    Text(item.species.name)
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.primary)
                    
                    Spacer()
                    
                    Text("\(item.totalCount) landed")
                        .cvFont(CVFont.telemetryMedium)
                        .foregroundStyle(Color.brandAccent)
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                // Reservoir Distribution Matrix
                VStack(spacing: 8) {
                    ForEach(item.reservoirBreakdown, id: \.reservoir.id) { spatial in
                        let percentage = Double(spatial.count) / Double(item.totalCount)
                        
                        VStack(spacing: 4) {
                            HStack {
                                Text(spatial.reservoir.name)
                                    .cvFont(CVFont.primaryBody)
                                    .foregroundStyle(Color.primary)
                                
                                Spacer()
                                
                                Text("\(spatial.count)")
                                    .cvFont(CVFont.telemetryMedium)
                                    .foregroundStyle(Color.primary)
                                
                                Text(String(format: "(%.0f%%)", percentage * 100))
                                    .cvFont(CVFont.metadata)
                                    .foregroundStyle(Color.secondary)
                                    .frame(width: 44, alignment: .trailing)
                            }
                            
                            // Visual Allocation Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.surfaceTertiary.opacity(0.5))
                                        .frame(height: 6)
                                    
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.brandAccent)
                                        .frame(width: max(0, geometry.size.width * CGFloat(percentage)), height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }
    
    /// Placeholder state when no catches match active filters
    private var emptySpeciesCard: some View {
        CVCardContainer {
            VStack(spacing: 8) {
                Image(systemName: "fish")
                    .font(.largeTitle)
                    .foregroundStyle(Color.secondary.opacity(0.6))
                
                Text("No Catches Found")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Text("Log trips and catches to view species spatial distribution analytics.")
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Query Scoping & Aggregation Model
    
    private struct SpatialEntry {
        let reservoir: Reservoir
        let count: Int
    }
    
    private struct SpeciesData {
        let species: Species
        let totalCount: Int
        let reservoirBreakdown: [SpatialEntry]
    }
    
    /// Calculates volumetric total and spatial distribution per reservoir for species with > 0 catches
    private func computeActiveSpeciesData() -> [SpeciesData] {
        let catchesScope = filteredCatches
        
        var result: [SpeciesData] = []
        
        for species in speciesList {
            let speciesCatches = catchesScope.filter { $0.species?.id == species.id }
            guard !speciesCatches.isEmpty else { continue } // Omit species with 0 catches
            
            var reservoirCounts: [UUID: (reservoir: Reservoir, count: Int)] = [:]
            
            for catchItem in speciesCatches {
                guard let reservoir = catchItem.trip?.reservoir else { continue }
                if let existing = reservoirCounts[reservoir.id] {
                    reservoirCounts[reservoir.id] = (reservoir, existing.count + 1)
                } else {
                    reservoirCounts[reservoir.id] = (reservoir, 1)
                }
            }
            
            let sortedBreakdown = reservoirCounts.values
                .map { SpatialEntry(reservoir: $0.reservoir, count: $0.count) }
                .sorted { $0.count > $1.count }
            
            result.append(
                SpeciesData(
                    species: species,
                    totalCount: speciesCatches.count,
                    reservoirBreakdown: sortedBreakdown
                )
            )
        }
        
        return result.sorted { $0.totalCount > $1.totalCount }
    }
}

