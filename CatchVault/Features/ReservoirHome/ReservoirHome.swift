//
//  ReservoirHome.swift
//  CatchVault
//

import SwiftUI
import SwiftData

public struct ReservoirHome: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Reservoir.name, order: .forward)
    private var reservoirs: [Reservoir]
    
    @Query
    private var allTrips: [Trip]
    
    @State private var selectedYear: Int? = nil
    @State private var showingAddReservoir: Bool = false
    
    private var availableYears: [Int] {
        let years = allTrips.map { Calendar.current.component(.year, from: $0.startTime) }
        return Array(Set(years)).sorted(by: >)
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        CVYearPicker(
                            selectedYear: $selectedYear,
                            availableYears: availableYears
                        )
                        
                        if reservoirs.isEmpty {
                            emptyStateCard
                        } else {
                            ForEach(reservoirs) { reservoir in
                                reservoirTile(for: reservoir)
                            }
                        }
                        
                        addReservoirButtonCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Reservoirs")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: Text("Analytics Dashboard")) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.brandAccent)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .toolbarBackground(Color.backgroundMain, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingAddReservoir) {
                Text("Add Reservoir View")
            }
            .navigationDestination(for: Reservoir.self) { reservoir in
                ReservoirDetailsView(reservoir: reservoir)
            }
        }
    }
    
    
    private func reservoirTile(for reservoir: Reservoir) -> some View {
        let trips = filteredTrips(for: reservoir)
        let tripCount = trips.count
        let fishCount = trips.reduce(0) { $0 + $1.catches.count }
        
        return CVCardContainer {
            VStack(alignment: .leading, spacing: 14) {
                NavigationLink(value: reservoir) {
                    HStack {
                        Text(reservoir.name)
                            .cvFont(CVFont.sectionHeader)
                            .foregroundStyle(Color.brandPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                Divider()
                    .background(Color.surfaceTertiary)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Total Trips")
                            .cvFont(CVFont.primaryBody)
                            .foregroundStyle(Color.secondary)
                        
                        Spacer()
                        
                        Text("\(tripCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                    }
                    
                    HStack {
                        Text("Total Fish")
                            .cvFont(CVFont.primaryBody)
                            .foregroundStyle(Color.secondary)
                        
                        Spacer()
                        
                        Text("\(fishCount)")
                            .cvFont(CVFont.telemetryMedium)
                            .foregroundStyle(Color.primary)
                    }
                }
                
                NavigationLink(destination: Text("Start Trip at \(reservoir.name)")) {
                    HStack {
                        Spacer()
                        Text("Start Trip")
                            .cvFont(CVFont.actionLabel)
                            .foregroundStyle(Color.white)
                        Spacer()
                    }
                    .frame(height: 44)
                    .background(Color.brandAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(12)
        }
    }
    
    private var emptyStateCard: some View {
        CVCardContainer {
            VStack(spacing: 8) {
                Text("No Reservoirs Found")
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.primary)
                
                Text("Add your first reservoir location below to begin tracking trips and catches.")
                    .cvFont(CVFont.primaryBody)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
    }
    
    private var addReservoirButtonCard: some View {
        CVCardContainer {
            Button(action: {
                showingAddReservoir = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Add Reservoir")
                        .cvFont(CVFont.actionLabel)
                }
                .foregroundStyle(Color.brandPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .padding(4)
        }
    }
    
    // MARK: - Helpers
    
    private func filteredTrips(for reservoir: Reservoir) -> [Trip] {
        reservoir.trips.filter { trip in
            guard let year = selectedYear else { return true }
            return Calendar.current.component(.year, from: trip.startTime) == year
        }
    }
}
