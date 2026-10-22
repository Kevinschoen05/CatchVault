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
    
    @State private var position: MapCameraPosition = .automatic
    @State private var isMapExpanded: Bool = false
    
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
    
    private var filteredCatches: [FishCatch] {
        let yearFilteredTrips = trips.filter { trip in
            guard let selectedYear = selectedYear else { return true }
            let tripYear = Calendar.current.component(.year, from: trip.startTime)
            return tripYear == selectedYear
        }
        
        return yearFilteredTrips
            .flatMap { $0.catches }
            .filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    public var body: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                // Header Row with Title and Full-Screen Expand CTA
                HStack {
                    Text("Reservoir Catch Map")
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.textOnCardPrimary)
                    
                    Spacer()
                    
                    if !filteredCatches.isEmpty {
                        Button {
                            isMapExpanded = true
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.brandAccent)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                if filteredCatches.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "map.slash")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.textOnCardSecondary.opacity(0.6))
                        
                        Text(selectedYear == nil ? "No mapped catch locations recorded for this reservoir" : "No mapped catch locations recorded in \(selectedYear!)")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.surfaceSecondary.opacity(0.15))
                    )
                } else {
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
                    .onChange(of: selectedYear) { _, _ in
                        fitCameraToCatches()
                    }
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
    }
    
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
