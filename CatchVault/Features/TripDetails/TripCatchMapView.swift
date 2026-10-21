//
//  TripCatchMapView.swift
//  CatchVault
//

import SwiftUI
import MapKit

public struct TripCatchMapView: View {
    let catches: [FishCatch]
    
    @State private var position: MapCameraPosition = .automatic
    @State private var isMapExpanded: Bool = false
    
       init(catches: [FishCatch]) {
        self.catches = catches
    }
    
    private var catchesWithCoordinates: [FishCatch] {
        catches.filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    public var body: some View {
        CVCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Catch Locations")
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.textOnCardPrimary)
                    
                    Spacer()
                    
                    if !catchesWithCoordinates.isEmpty {
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
                
                if catchesWithCoordinates.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "map.slash")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.textOnCardSecondary.opacity(0.6))
                        
                        Text("No GPS coordinates recorded for catches on this trip")
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
                        ForEach(catchesWithCoordinates) { catchItem in
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
            }
        }
        .fullScreenCover(isPresented: $isMapExpanded) {
            FullScreenMapView(title: "Trip Catch Map", catches: catchesWithCoordinates)
        }
    }
    
    private func fitCameraToCatches() {
        let coords = catchesWithCoordinates.compactMap { catchItem -> CLLocationCoordinate2D? in
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
