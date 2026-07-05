import SwiftUI
import SwiftData

struct ReservoirHome: View {
    @Environment(\.modelContext) private var modelContext
    
    // Direct Query Pattern: Listens to the domain models natively
    @Query(sort: \Reservoir.name, order: .forward) private var reservoirs: [Reservoir]
    @Query private var trips: [Trip]
    
    // Localized Interface Parameters
    @State private var selectedYear: Int? = nil
    @State private var expandedReservoirID: UUID? = nil
    @State private var isShowingAddReservoir = false
    
    // Converted to a computed property to resolve instance lifecycle errors
    private var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        var years = Set<Int>([currentYear])
        trips.forEach { years.insert(Calendar.current.component(.year, from: $0.startTime)) }
        return Array(years).sorted(by: >)
    }
    
    var body: some View {
        ZStack {
            Color("surfacePrimary")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(reservoirs) { reservoir in
                        reservoirTile(for: reservoir)
                    }
                    
                    addReservoirStructuralTile
                }
                .padding(16)
            }
        }
        .navigationTitle("CatchVault")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: Text("Analytics Dashboard View Template")) {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundColor(Color("brandAccent"))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                CVYearPicker(selectedYear: $selectedYear, availableYears: availableYears)
            }
        }
        .sheet(isPresented: $isShowingAddReservoir) {
            Text("Add Reservoir Form Overlay Template")
                .presentationDetents([.medium])
        }
    }
    
    @ViewBuilder
    private func reservoirTile(for reservoir: Reservoir) -> some View {
        let isExpanded = expandedReservoirID == reservoir.id
        
        let filteredTrips = reservoir.trips.filter { trip in
            guard let year = selectedYear else { return true }
            return Calendar.current.component(.year, from: trip.startTime) == year
        }
        
        // Corrected type constraint: direct array access without optional checking
        let totalFishCount = filteredTrips.reduce(0) { $0 + $1.catches.count }
        
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(reservoir.name.capitalized)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(filteredTrips.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(filteredTrips.count == 1 ? "Total Trip" : "Total Trips")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(totalFishCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Fish Landed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if isExpanded {
                    VStack(spacing: 8) {
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack(spacing: 12) {
                            NavigationLink(destination: Text("Reservoir Details View Context Target")) {
                                Text("View Details")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .background(Color.primary.opacity(0.05))
                                    .cornerRadius(8)
                            }
                            
                            NavigationLink(destination: Text("Active Trip Workflow View Target")) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Start Trip")
                                }
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color("brandAccent"))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedReservoirID = isExpanded ? nil : reservoir.id
                }
            }
        }
    }
    
    private var addReservoirStructuralTile: some View {
        Button(action: { isShowingAddReservoir = true }) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                Text("Add Reservoir")
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    .background(Color("surfaceSecondary").opacity(0.5))
            )
        }
        .buttonStyle(.plain)
    }
}
