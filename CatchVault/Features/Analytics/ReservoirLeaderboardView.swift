//
//  ReservoirLeaderboardView.swift
//  CatchVault
//

import SwiftUI
import SwiftData

struct ReservoirLeaderboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData Queries fetching domain entities
    @Query(sort: \Reservoir.name) private var reservoirs: [Reservoir]
    @Query private var catches: [FishCatch]
    @Query private var trips: [Trip]
    
    // State filters
    @State private var selectedYear: Int? = nil
    
    // MARK: - Filter Extraction
    
    /// Dynamically extracts available years across all recorded trips
    private var availableYears: [Int] {
        let years = trips.map { Calendar.current.component(.year, from: $0.startTime) }
        return Array(Set(years)).sorted(by: >)
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
                    
                    // 2. Reservoir Leaderboard Cards
                    if reservoirs.isEmpty {
                        emptyReservoirsCard
                    } else {
                        ForEach(reservoirs) { reservoir in
                            reservoirLeaderboardCard(for: reservoir)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.backgroundMain, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    // MARK: - Subviews
    
    /// Layer 1 Container presenting top-10 heaviest landed fish for a specific reservoir
    private func reservoirLeaderboardCard(for reservoir: Reservoir) -> some View {
        let topCatches = topTenCatches(for: reservoir)
        
        return CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                // Reservoir Name Header
                HStack {
                    Text(reservoir.name)
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.primary)
                    
                    Spacer()
                    
                    Image(systemName: "trophy.fill")
                        .font(.title3)
                        .foregroundStyle(Color.brandAccent)
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                if topCatches.isEmpty {
                    Text("No recorded catches for this selection.")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.secondary)
                        .padding(.vertical, 8)
                } else {
                    // Tabular Column Header
                    HStack {
                        Text("#")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                            .frame(width: 28, alignment: .leading)
                        
                        Text("Angler / Species")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Spacer()
                        
                        Text("Weight / Year")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.horizontal, 4)
                    
                    // Top 10 Rows Matrix
                    VStack(spacing: 6) {
                        ForEach(Array(topCatches.enumerated()), id: \.element.id) { index, catchItem in
                            leaderboardRow(rank: index + 1, catchItem: catchItem)
                        }
                    }
                }
            }
        }
    }
    
    /// Tabular row entry enforcing string-left and numeric-right text alignment
    private func leaderboardRow(rank: Int, catchItem: FishCatch) -> some View {
        let catchYear = Calendar.current.component(.year, from: catchItem.timestamp)
        let anglerName = catchItem.angler?.name ?? "Unknown Angler"
        let speciesName = catchItem.species?.name ?? "Unknown Species"
        
        return HStack(spacing: 10) {
            // Rank Number (Frame expanded to 28pt & line limit locked to prevent wrapping)
            Text("\(rank)")
                .cvFont(CVFont.telemetryMedium)
                .foregroundStyle(rank <= 3 ? Color.brandAccent : Color.secondary)
                .lineLimit(1)
                .frame(width: 28, alignment: .leading)
            
            // Angler & Species Stack
            VStack(alignment: .leading, spacing: 2) {
                Text(anglerName)
                    .cvFont(CVFont.primaryBody)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                
                Text(speciesName)
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Weight & Year Stack
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.2f lbs", catchItem.weight))
                    .cvFont(CVFont.telemetryMedium)
                    .foregroundStyle(Color.primary)
                
                Text(String(format: "%d", catchYear))
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(rank % 2 == 0 ? Color.surfaceTertiary.opacity(0.3) : Color.clear)
        )
    }
    
    /// Placeholder state when no reservoirs exist in local context
    private var emptyReservoirsCard: some View {
        CVCardContainer {
            VStack(spacing: 8) {
                Image(systemName: "map")
                    .font(.largeTitle)
                    .foregroundStyle(Color.secondary.opacity(0.6))
                
                Text("No Reservoirs Found")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Text("Add reservoirs and record catches to view leaderboard rankings.")
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Query Scoping Logic
    
    /// Retrieves top 10 heaviest catches for a target reservoir under active temporal filter parameters
    private func topTenCatches(for reservoir: Reservoir) -> [FishCatch] {
        let filteredCatches = catches.filter { catchItem in
            guard catchItem.trip?.reservoir?.id == reservoir.id else { return false }
            
            if let year = selectedYear {
                guard Calendar.current.component(.year, from: catchItem.timestamp) == year else { return false }
            }
            
            return true
        }
        
        let sortedCatches = filteredCatches.sorted { $0.weight > $1.weight }
        return Array(sortedCatches.prefix(10))
    }
}
