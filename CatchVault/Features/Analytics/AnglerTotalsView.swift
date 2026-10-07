//
//  AnglerTotalsView.swift
//  CatchVault
//

import SwiftUI
import SwiftData

struct AnglerTotalsView: View {
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData Queries fetching domain entities
    @Query(sort: \Angler.name) private var anglers: [Angler]
    @Query private var catches: [FishCatch]
    @Query private var trips: [Trip]
    @Query(sort: \Reservoir.name) private var reservoirs: [Reservoir]
    
    // State filters
    @State private var selectedYear: Int? = nil
    @State private var selectedReservoir: Reservoir? = nil
    
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
                    
                    // 2. Reservoir Scope Picker Card (Layer 1 Container)
                    reservoirFilterCard
                    
                    // 3. Angler Telemetry Ledger Cards
                    if anglers.isEmpty {
                        emptyAnglersCard
                    } else {
                        ForEach(anglers) { angler in
                            anglerPerformanceCard(for: angler)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Angler Totals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.backgroundMain, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    // MARK: - Subviews
    
    /// Dedicated Layer 1 card container for the Reservoir selection dropdown
    private var reservoirFilterCard: some View {
        CVCardContainer {
            HStack {
                Text("Reservoir")
                    .cvFont(CVFont.primaryBody)
                    .foregroundStyle(Color.primary)
                
                Spacer()
                
                Picker("Reservoir", selection: $selectedReservoir) {
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
    
    /// Layer 1 Container presenting telemetry breakdown and species frequency ledger for a specific angler
    private func anglerPerformanceCard(for angler: Angler) -> some View {
        let anglerCatches = filteredCatches(for: angler)
        let anglerTrips = filteredTrips(for: angler)
        let zeroFishTripsCount = zeroFishTrips(for: angler, trips: anglerTrips).count
        
        let totalCatches = anglerCatches.count
        let totalTrips = anglerTrips.count
        let totalMass = anglerCatches.reduce(0.0) { $0 + $1.weight }
        let catchesPerTrip = totalTrips == 0 ? 0.0 : Double(totalCatches) / Double(totalTrips)
        let avgMassPerFish = totalCatches == 0 ? 0.0 : totalMass / Double(totalCatches)
        let speciesFrequency = calculateSpeciesFrequency(for: anglerCatches)
        
        return CVCardContainer {
            VStack(alignment: .leading, spacing: 14) {
                // Angler Name Header
                HStack {
                    Text(angler.name)
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.primary)
                    
                    Spacer()
                    
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.brandAccent)
                }
                
                Divider()
                    .background(Color.secondary.opacity(0.2))
                
                // High-Density Telemetry Matrix (Row 1)
                HStack(spacing: 12) {
                    // Total Catches
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Catches")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(totalCatches)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .frame(height: 32)
                        .background(Color.secondary.opacity(0.2))
                    
                    // Total Mass (lbs)
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Mass")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text(String(format: "%.2f lbs", totalMass))
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                // High-Density Telemetry Matrix (Row 2)
                HStack(spacing: 12) {
                    // Total Trips
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Trips")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(totalTrips)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .frame(height: 32)
                        .background(Color.secondary.opacity(0.2))
                    
                    // Zero-Fish Trips Count
                    VStack(alignment: .center, spacing: 4) {
                        Text("Zero-Fish Trips")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(zeroFishTripsCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(zeroFishTripsCount > 0 ? Color.secondary : Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Divider()
                        .frame(height: 32)
                        .background(Color.secondary.opacity(0.2))
                    
                    // Catch Avg / Trip
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Catch Avg/Trip")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.secondary)
                        
                        Text(String(format: "%.1f", catchesPerTrip))
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                // Row 3: Mean Fish Weight
                HStack {
                    Text("Average Fish Weight")
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    Text(String(format: "%.2f lbs", avgMassPerFish))
                        .cvFont(CVFont.telemetryMedium)
                        .foregroundStyle(Color.primary)
                }
                .padding(.top, 2)
                
                // Species Breakdown Ledger
                if !speciesFrequency.isEmpty {
                    Divider()
                        .background(Color.secondary.opacity(0.2))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Species Breakdown")
                            .cvFont(CVFont.sectionHeader)
                            .foregroundStyle(Color.primary)
                        
                        ForEach(speciesFrequency, id: \.name) { species in
                            HStack {
                                Text(species.name)
                                    .cvFont(CVFont.primaryBody)
                                    .foregroundStyle(Color.primary)
                                
                                Spacer()
                                
                                Text("\(species.count)")
                                    .cvFont(CVFont.telemetryMedium)
                                    .foregroundStyle(Color.brandAccent)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
        }
    }
    
    /// Placeholder state when no anglers are present in persistent context
    private var emptyAnglersCard: some View {
        CVCardContainer {
            VStack(spacing: 8) {
                Image(systemName: "person.3")
                    .font(.largeTitle)
                    .foregroundStyle(Color.secondary.opacity(0.6))
                
                Text("No Anglers Found")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Text("Log trips and record catches to view individual angler statistics.")
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Query Scoping & Calculation Logic
    
    /// Filters catches belonging to a specific angler under selected reservoir and temporal boundaries
    private func filteredCatches(for angler: Angler) -> [FishCatch] {
        catches.filter { catchItem in
            guard catchItem.angler?.id == angler.id else { return false }
            
            if let year = selectedYear {
                guard Calendar.current.component(.year, from: catchItem.timestamp) == year else { return false }
            }
            
            if let reservoir = selectedReservoir {
                guard catchItem.trip?.reservoir?.id == reservoir.id else { return false }
            }
            
            return true
        }
    }
    
    /// Filters trips containing a specific angler under selected reservoir and temporal boundaries
    private func filteredTrips(for angler: Angler) -> [Trip] {
        trips.filter { trip in
            guard trip.anglers.contains(where: { $0.id == angler.id }) else { return false }
            
            if let year = selectedYear {
                guard Calendar.current.component(.year, from: trip.startTime) == year else { return false }
            }
            
            if let reservoir = selectedReservoir {
                guard trip.reservoir?.id == reservoir.id else { return false }
            }
            
            return true
        }
    }
    
    /// Evaluates trips in which the angler participated but logged zero catches
    private func zeroFishTrips(for angler: Angler, trips: [Trip]) -> [Trip] {
        trips.filter { trip in
            let anglerCatchesInTrip = trip.catches.filter { $0.angler?.id == angler.id }
            return anglerCatchesInTrip.isEmpty
        }
    }
    
    /// Computes species frequency breakdown, omitting species with 0 catches and sorting by frequency descending
    private func calculateSpeciesFrequency(for anglerCatches: [FishCatch]) -> [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for catchItem in anglerCatches {
            guard let speciesName = catchItem.species?.name, !speciesName.isEmpty else { continue }
            counts[speciesName, default: 0] += 1
        }
        
        return counts
            .filter { $0.value > 0 }
            .map { (name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
}
