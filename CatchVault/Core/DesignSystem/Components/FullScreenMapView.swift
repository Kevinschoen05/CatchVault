//
//  FullScreenMapView.swift
//  CatchVault
//  Path: CatchVault/Core/Components/FullScreenMapView.swift
//

import SwiftUI
import MapKit

public struct FullScreenMapView: View {
    let title: String
    let catches: [FishCatch]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var position: MapCameraPosition = .automatic
    @State private var mapStyleSelection: MapStyleOption = .standard
    
    private enum MapStyleOption: String, CaseIterable, Identifiable {
        case standard = "Standard"
        case imagery = "Satellite"
        case hybrid = "Hybrid"
        
        var id: String { rawValue }
        
        var style: MapStyle {
            switch self {
            case .standard: return .standard
            case .imagery: return .imagery
            case .hybrid: return .hybrid
            }
        }
    }
    
     init(title: String, catches: [FishCatch]) {
        self.title = title
        self.catches = catches
    }
    
    private var catchesWithCoordinates: [FishCatch] {
        catches.filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    public var body: some View {
        ZStack {
            // Layer 0 Base Canvas
            Color.backgroundMain
                .ignoresSafeArea()
            
            // Map Canvas View
            Map(position: $position) {
                ForEach(catchesWithCoordinates) { catchItem in
                    if let lat = catchItem.latitude, let lon = catchItem.longitude {
                        Marker(
                            catchItem.species?.name ?? "Unknown Fish",
                            monogram: Text(String(catchItem.species?.name.prefix(1) ?? "F")),
                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        )
                        .tint(SpeciesColorProvider.color(for: catchItem.species?.name))
                    }
                }
            }
            .mapStyle(mapStyleSelection.style)
            .ignoresSafeArea()
            
            // Overlays Layer
            VStack {
                // Top Header Overlay Bar
                topControlHeader
                
                Spacer()
                
                // Bottom Map Style Segment Selector
                bottomMapStylePicker
            }
        }
        .onAppear {
            fitCameraToCatches()
        }
    }
    
    // MARK: - Header & Control Overlays
    
    private var topControlHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .cvFont(CVFont.sectionHeader)
                    .foregroundStyle(Color.textOnCardPrimary)
                    .lineLimit(1)
                
                Text("\(catchesWithCoordinates.count) Mapped Catches")
                    .cvFont(CVFont.metadata)
                    .foregroundStyle(Color.textOnCardSecondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 12)
            
            // Recenter Camera Button
            Button {
                withAnimation(.spring()) {
                    fitCameraToCatches()
                }
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.textOnCardPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.surfaceSecondary.opacity(0.2))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            // Close Full Screen Button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.textOnCardPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.surfaceCard)
                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    
    private var bottomMapStylePicker: some View {
        Picker("Map Style", selection: $mapStyleSelection) {
            ForEach(MapStyleOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.surfaceCard)
                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
        )
        .frame(maxWidth: 280)
        .padding(.bottom, 24)
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
