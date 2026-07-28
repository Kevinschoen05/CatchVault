import SwiftUI
import SwiftData

struct ReservoirDetailsView: View {
    let reservoir: Reservoir
    
    @State private var selectedYear: Int? = nil
    @State private var showingStartTripSheet = false
    @State private var selectedTripForDetails: Trip? = nil
    
    private var availableYears: [Int] {
        let years = reservoir.trips.map { Calendar.current.component(.year, from: $0.startTime) }
        return Array(Set(years)).sorted(by: >)
    }
    
    private var filteredTrips: [Trip] {
        let sortedTrips = reservoir.trips.sorted { $0.startTime > $1.startTime }
        guard let year = selectedYear else {
            return sortedTrips
        }
        return sortedTrips.filter { Calendar.current.component(.year, from: $0.startTime) == year }
    }
    
    private var totalTripsCount: Int {
        filteredTrips.count
    }
    
    private var totalFishCount: Int {
        filteredTrips.reduce(0) { $0 + $1.catches.count }
    }
    
    private var totalWeight: Double {
        filteredTrips.reduce(0.0) { tripSum, trip in
            tripSum + trip.catches.compactMap { $0.weight }.reduce(0.0, +)
        }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    yearFilterSelector
                    telemetryCard
                    catchMapPlaceholder
                    startTripButton
                    tripHistoryLedger
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Reservoir Details")
                    .font(.headline)
                    .foregroundStyle(Color.white)
            }
        }
        .sheet(isPresented: $showingStartTripSheet) {
            Text("Start Trip Sheet (Placeholder)")
        }
        .sheet(item: $selectedTripForDetails) { _ in
            Text("Trip Details (Placeholder)")
        }
    }
    
    private var yearFilterSelector: some View {
        HStack {
            Menu {
                Button("All Time") {
                    selectedYear = nil
                }
                Divider()
                ForEach(availableYears, id: \.self) { year in
                    Button(String(year)) {
                        selectedYear = year
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedYear.map { String($0) } ?? "All Time")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.brandAccent)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var telemetryCard: some View {
        CVCardContainer{
            VStack(spacing: 12) {
                HStack {
                    Text(reservoir.name + " Summary")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                Divider()
                
                HStack(spacing: 16) {
                    telemetryMetricCell(
                        label: "Total Trips",
                        value: "\(totalTripsCount)"
                    )
                    
                    telemetryMetricCell(
                        label: "Total Fish",
                        value: "\(totalFishCount)"
                    )
                    
                    telemetryMetricCell(
                        label: "Total Weight",
                        value: String(format: "%.2f lbs", totalWeight)
                    )
                }
            }
            .padding(16)
        }
    }
    
    private func telemetryMetricCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var catchMapPlaceholder: some View {
        CVCardContainer {
            VStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary)
                
                Text("CatchMap View (Placeholder)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(Color.surfaceTertiary)
            .cornerRadius(8)
            .padding(12)
        }
    }
    
    private var startTripButton: some View {
        Button(action: {
            showingStartTripSheet = true
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Trip")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.brandAccent)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    private var tripHistoryLedger: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trip History")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            if filteredTrips.isEmpty {
                CVCardContainer {
                    Text("No trips recorded for this selection.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(24)
                }
            } else {
                ForEach(filteredTrips) { trip in
                    tripTile(for: trip)
                }
            }
        }
    }
    
    private func tripTile(for trip: Trip) -> some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(trip.startTime, style: .date)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedTripForDetails = trip
                    }) {
                        Text("View Details")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.brandAccent)
                            .cornerRadius(8)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
                
                if !trip.anglers.isEmpty {
                    Text("Anglers: \(trip.anglers.map { $0.name }.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                HStack {
                    Label("\(trip.catches.count) Fish", systemImage: "fish.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    let tripWeight = trip.catches.compactMap { $0.weight }.reduce(0.0, +)
                    Text(String(format: "%.2f lbs", tripWeight))
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            .padding(16)
        }
    }
}

