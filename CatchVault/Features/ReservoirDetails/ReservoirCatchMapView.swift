//
//  ReservoirCatchMapView.swift
//  CatchVault
//  Path: CatchVault/Features/Reservoirs/ReservoirCatchMapView.swift
//

import SwiftUI
import MapKit

public struct ReservoirCatchMapView: View {
    let reservoirName: String
    let trips: [Trip]
    let selectedYear: Int?
    var onSelectTrip: ((Trip) -> Void)? = nil
    
    // MARK: - State Management
    
    @State private var position: MapCameraPosition = .automatic
    @State private var isMapExpanded: Bool = false
    
    /// Selected species filter set (Empty = All Species)
    @State private var selectedSpeciesNames: Set<String> = []
    
    /// Selected angler filter set (Empty = All Anglers)
    @State private var selectedAnglerNames: Set<String> = []
    
    // MARK: - Initializer
    
    init(
        reservoirName: String,
        trips: [Trip],
        selectedYear: Int?,
        onSelectTrip: ((Trip) -> Void)? = nil
    ) {
        self.reservoirName = reservoirName
        self.trips = trips
        self.selectedYear = selectedYear
        self.onSelectTrip = onSelectTrip
    }
    
    // MARK: - Filter Extraction & Computations
    
    /// Catches scoped strictly to the selected year and having valid coordinates
    private var yearScopedCatches: [FishCatch] {
        let yearFilteredTrips = trips.filter { trip in
            guard let selectedYear = selectedYear else { return true }
            let tripYear = Calendar.current.component(.year, from: trip.startTime)
            return tripYear == selectedYear
        }
        
        return yearFilteredTrips
            .flatMap { $0.catches }
            .filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    /// Available unique species present in the current temporal catch set
    private var availableSpecies: [String] {
        let names = yearScopedCatches.compactMap { $0.species?.name }
        return Array(Set(names)).sorted()
    }
    
    /// Available unique anglers present in the current temporal catch set
    private var availableAnglers: [String] {
        let names = yearScopedCatches.compactMap { $0.angler?.name }
        return Array(Set(names)).sorted()
    }
    
    /// Final filtered catch subset matching Year ∩ Species ∩ Angler criteria
    private var filteredCatches: [FishCatch] {
        yearScopedCatches.filter { catchItem in
            let matchesSpecies = selectedSpeciesNames.isEmpty ||
                (catchItem.species?.name != nil && selectedSpeciesNames.contains(catchItem.species!.name))
            
            let matchesAngler = selectedAnglerNames.isEmpty ||
                (catchItem.angler?.name != nil && selectedAnglerNames.contains(catchItem.angler!.name))
            
            return matchesSpecies && matchesAngler
        }
    }
    
    /// Indicates whether any active species or angler filter pills are selected
    private var isAnyFilterActive: Bool {
        !selectedSpeciesNames.isEmpty || !selectedAnglerNames.isEmpty
    }
    
    // MARK: - Body
    
    public var body: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                // 1. Header Row with Title, Clear Pill CTA, and Expand CTA
                HStack {
                    Text("Reservoir Catch Map")
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.textOnCardPrimary)
                    
                    Spacer()
                    
                    if isAnyFilterActive {
                        Button("Reset Filters") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedSpeciesNames.removeAll()
                                selectedAnglerNames.removeAll()
                            }
                        }
                        .cvFont(CVFont.metadata)
                        .foregroundStyle(Color.brandAccent)
                        .buttonStyle(.plain)
                    }
                    
                    if !filteredCatches.isEmpty {
                        Button {
                            isMapExpanded = true
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.brandAccent)
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // 2. Interactive Filter Toggle Pills Row
                if !availableSpecies.isEmpty || !availableAnglers.isEmpty {
                    filterPillsScrollView
                }
                
                // 3. Map Canvas / Empty State Layer
                if yearScopedCatches.isEmpty {
                    emptyStateContainer(
                        message: selectedYear == nil
                            ? "No mapped catch locations recorded for this reservoir"
                            : "No mapped catch locations recorded in \(selectedYear!)"
                    )
                } else if filteredCatches.isEmpty {
                    emptyStateContainer(message: "No catches match the active species and angler filters")
                } else {
                    mapCanvas
                }
            }
        }
        .fullScreenCover(isPresented: $isMapExpanded) {
            FullScreenMapView(
                title: "\(reservoirName) Map",
                catches: filteredCatches,
                onSelectTrip: onSelectTrip
            )
        }
        .onChange(of: selectedYear) { _, _ in
            // Reset filters on year change to prevent stale combinations
            selectedSpeciesNames.removeAll()
            selectedAnglerNames.removeAll()
            fitCameraToCatches()
        }
        .onChange(of: selectedSpeciesNames) { _, _ in
            withAnimation {
                fitCameraToCatches()
            }
        }
        .onChange(of: selectedAnglerNames) { _, _ in
            withAnimation {
                fitCameraToCatches()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Horizontal scroll container hosting species and angler filter pills
    private var filterPillsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Species Toggle Pills
                ForEach(availableSpecies, id: \.self) { speciesName in
                    let isSelected = selectedSpeciesNames.contains(speciesName)
                    let speciesColor = SpeciesColorProvider.color(for: speciesName)
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if isSelected {
                                selectedSpeciesNames.remove(speciesName)
                            } else {
                                selectedSpeciesNames.insert(speciesName)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(speciesColor)
                                .frame(width: 8, height: 8)
                            
                            Text(speciesName)
                                .cvFont(CVFont.metadata)
                                .foregroundStyle(isSelected ? Color.white : Color.textOnCardPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isSelected ? speciesColor : Color.surfaceSecondary.opacity(0.3))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(isSelected ? Color.clear : Color.textOnCardSecondary.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                if !availableSpecies.isEmpty && !availableAnglers.isEmpty {
                    Divider()
                        .frame(height: 16)
                        .background(Color.textOnCardSecondary.opacity(0.3))
                }
                
                // Angler Toggle Pills
                ForEach(availableAnglers, id: \.self) { anglerName in
                    let isSelected = selectedAnglerNames.contains(anglerName)
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if isSelected {
                                selectedAnglerNames.remove(anglerName)
                            } else {
                                selectedAnglerNames.insert(anglerName)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(isSelected ? Color.white : Color.textOnCardSecondary)
                            
                            Text(anglerName)
                                .cvFont(CVFont.metadata)
                                .foregroundStyle(isSelected ? Color.white : Color.textOnCardPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.brandAccent : Color.surfaceSecondary.opacity(0.3))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(isSelected ? Color.clear : Color.textOnCardSecondary.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    /// Embedded 180pt Live Map Canvas rendering matching markers
    private var mapCanvas: some View {
        Map(position: $position) {
            ForEach(filteredCatches) { catchItem in
                if let lat = catchItem.latitude, let lon = catchItem.longitude {
                    Marker(
                        catchItem.species?.name ?? "Fish",
                        monogram: Text(String(catchItem.species?.name.prefix(1) ?? "F")),
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    )
                    .tint(SpeciesColorProvider.color(for: catchItem.species?.name))
                }
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear {
            fitCameraToCatches()
        }
    }
    
    /// Reusable empty state view
    private func emptyStateContainer(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "map.slash")
                .font(.system(size: 28))
                .foregroundStyle(Color.textOnCardSecondary.opacity(0.6))
            
            Text(message)
                .cvFont(CVFont.metadata)
                .foregroundStyle(Color.textOnCardSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.surfaceSecondary.opacity(0.15))
        )
    }
    
    // MARK: - Camera Geometry Helpers
    
    /// Calculates optimal coordinate bounds to enclose active pin selection
    private func fitCameraToCatches() {
        let coords = filteredCatches.compactMap { catchItem -> CLLocationCoordinate2D? in
            guard let lat = catchItem.latitude, let lon = catchItem.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        guard !coords.isEmpty else { return }
        
        if coords.count == 1 {
            position = .region(MKCoordinateRegion(
                center: coords[0],
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            let minLat = coords.map { $0.latitude }.min() ?? 0.0
            let maxLat = coords.map { $0.latitude }.max() ?? 0.0
            let minLon = coords.map { $0.longitude }.min() ?? 0.0
            let maxLon = coords.map { $0.longitude }.max() ?? 0.0
            
            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2.0,
                longitude: (minLon + maxLon) / 2.0
            )
            let span = MKCoordinateSpan(
                latitudeDelta: max((maxLat - minLat) * 1.4, 0.01),
                longitudeDelta: max((maxLon - minLon) * 1.4, 0.01)
            )
            position = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
}
