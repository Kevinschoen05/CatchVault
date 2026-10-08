//
//  CatchTrendsView.swift
//  CatchVault
//

import SwiftUI
import SwiftData
import Charts

struct CatchTrendsView: View {
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData Queries fetching domain entities
    @Query(sort: \Species.name) private var speciesList: [Species]
    @Query private var catches: [FishCatch]
    @Query private var trips: [Trip]
    @Query(sort: \Reservoir.name) private var reservoirs: [Reservoir]
    
    // State filters
    @State private var selectedYear: Int? = nil
    @State private var selectedReservoir: Reservoir? = nil
    @State private var selectedSpeciesID: UUID? = nil
    
    // MARK: - Filter Extraction
    
    /// Dynamically extracts available years across all recorded trips
    private var availableYears: [Int] {
        let years = trips.map { Calendar.current.component(.year, from: $0.startTime) }
        return Array(Set(years)).sorted(by: >)
    }
    
    /// Returns currently focused species entity or defaults to the first available species
    private var activeSpecies: Species? {
        if let id = selectedSpeciesID, let found = speciesList.first(where: { $0.id == id }) {
            return found
        }
        return speciesList.first
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
                    
                    if speciesList.isEmpty {
                        emptySpeciesCard
                    } else {
                        // 2. Interactive Selection Controls Card (Layer 1)
                        filterControlsCard
                        
                        let monthlyData = computeMonthlyData()
                        let totalCatches = monthlyData.reduce(0) { $0 + $1.catchCount }
                        
                        if totalCatches == 0 {
                            emptyDataCard
                        } else {
                            // 3. 12-Month Calendar Distribution Swift Chart Card
                            monthlyChartCard(monthlyData: monthlyData, totalCatches: totalCatches)
                            
                            // 4. Monthly Breakdown Ledger Card
                            monthlyLedgerCard(monthlyData: monthlyData)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Catch Trends")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.backgroundMain, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            if selectedSpeciesID == nil, let defaultSpecies = speciesList.first {
                selectedSpeciesID = defaultSpecies.id
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Layer 1 Container housing Species and Reservoir pickers
    private var filterControlsCard: some View {
        CVCardContainer {
            VStack(spacing: 12) {
                // Species Selector Row
                HStack {
                    Text("Target Species")
                        .cvFont(CVFont.primaryBody)
                        .foregroundStyle(Color.primary)
                    
                    Spacer()
                    
                    Picker("Target Species", selection: $selectedSpeciesID) {
                        ForEach(speciesList) { species in
                            Text(species.name).tag(Optional<UUID>.some(species.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.brandAccent)
                    .frame(minHeight: 44)
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                // Reservoir Scope Selector Row
                HStack {
                    Text("Reservoir Scope")
                        .cvFont(CVFont.primaryBody)
                        .foregroundStyle(Color.primary)
                    
                    Spacer()
                    
                    Picker("Reservoir Scope", selection: $selectedReservoir) {
                        Text("All Reservoirs").tag(Optional<Reservoir>.none)
                        Divider()
                        ForEach(reservoirs) { reservoir in
                            Text(reservoir.name).tag(Optional<Reservoir>.some(reservoir))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.brandAccent)
                    .frame(minHeight: 44)
                }
            }
        }
    }
    
    /// Layer 1 Container displaying 12-month trend distribution chart
    private func monthlyChartCard(monthlyData: [MonthlyTrendEntry], totalCatches: Int) -> some View {
        let peakMonth = monthlyData.max(by: { $0.catchCount < $1.catchCount })
        
        return CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activeSpecies?.name ?? "Species Trends")
                            .cvFont(CVFont.sectionHeader)
                            .foregroundStyle(Color.primary)
                        
                        Text("\(totalCatches) total landed")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Spacer()
                    
                    if let peak = peakMonth, peak.catchCount > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Peak Month")
                                .cvFont(CVFont.metadata)
                                .foregroundStyle(Color.secondary)
                            
                            Text("\(peak.monthName) (\(peak.catchCount))")
                                .cvFont(CVFont.telemetryMedium)
                                .foregroundStyle(Color.brandAccent)
                        }
                    }
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                Chart(monthlyData) { entry in
                    BarMark(
                        x: .value("Month", entry.monthName),
                        y: .value("Catches", entry.catchCount)
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
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                            .foregroundStyle(Color.secondary.opacity(0.15))
                        AxisValueLabel()
                    }
                }
                .frame(height: 200)
                .padding(.vertical, 4)
            }
        }
    }
    
    /// Layer 1 Container itemizing active monthly counts in a structured grid
    private func monthlyLedgerCard(monthlyData: [MonthlyTrendEntry]) -> some View {
        let activeMonths = monthlyData.filter { $0.catchCount > 0 }
        
        return CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Monthly Summary Ledger")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                VStack(spacing: 6) {
                    ForEach(activeMonths) { entry in
                        HStack {
                            Text(entry.monthFullName)
                                .cvFont(CVFont.primaryBody)
                                .foregroundStyle(Color.primary)
                            
                            Spacer()
                            
                            Text("\(entry.catchCount) landed")
                                .cvFont(CVFont.telemetryMedium)
                                .foregroundStyle(Color.brandAccent)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.surfaceTertiary.opacity(0.3))
                        )
                    }
                }
            }
        }
    }
    
    /// Placeholder state when no species exist in persistent storage
    private var emptySpeciesCard: some View {
        CVCardContainer {
            VStack(spacing: 8) {
                Image(systemName: "fish")
                    .font(.largeTitle)
                    .foregroundStyle(Color.secondary.opacity(0.6))
                
                Text("No Species Recorded")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Text("Log species and catches to unlock seasonal temporal trend analytics.")
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }
    
    /// Placeholder state when active species has 0 catches under current filters
    private var emptyDataCard: some View {
        CVCardContainer {
            VStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.largeTitle)
                    .foregroundStyle(Color.secondary.opacity(0.6))
                
                Text("No Trends Data")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Text("No catch records found for \(activeSpecies?.name ?? "selected species") under active filter boundaries.")
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Aggregation & Computation Engine
    
    private struct MonthlyTrendEntry: Identifiable {
        let id = UUID()
        let monthNumber: Int
        let monthName: String
        let monthFullName: String
        let catchCount: Int
    }
    
    /// Aggregates catches across 12 calendar months for active species under selected filters
    private func computeMonthlyData() -> [MonthlyTrendEntry] {
        guard let targetSpecies = activeSpecies else { return [] }
        
        let filteredScope = catches.filter { catchItem in
            guard catchItem.species?.id == targetSpecies.id else { return false }
            
            if let year = selectedYear {
                guard Calendar.current.component(.year, from: catchItem.timestamp) == year else { return false }
            }
            
            if let reservoir = selectedReservoir {
                guard catchItem.trip?.reservoir?.id == reservoir.id else { return false }
            }
            
            return true
        }
        
        let shortFormatter = DateFormatter()
        shortFormatter.dateFormat = "MMM"
        
        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "MMMM"
        
        var entries: [MonthlyTrendEntry] = []
        
        for month in 1...12 {
            var components = DateComponents()
            components.month = month
            components.day = 1
            components.year = 2026 // Nominal reference year for month name extraction
            
            let date = Calendar.current.date(from: components) ?? Date()
            let shortName = shortFormatter.string(from: date)
            let fullName = fullFormatter.string(from: date)
            
            let count = filteredScope.filter {
                Calendar.current.component(.month, from: $0.timestamp) == month
            }.count
            
            entries.append(
                MonthlyTrendEntry(
                    monthNumber: month,
                    monthName: shortName,
                    monthFullName: fullName,
                    catchCount: count
                )
            )
        }
        
        return entries
    }
}
