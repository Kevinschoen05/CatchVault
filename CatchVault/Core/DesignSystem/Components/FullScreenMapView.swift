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
    
    /// Handoff callback to parent view to trigger root NavigationStack push to TripDetailsView
    var onSelectTrip: ((Trip) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var position: MapCameraPosition = .automatic
    @State private var mapStyleSelection: MapStyleOption = .standard
    @State private var mappedCatches: [FishCatch] = []
    @State private var selectedCatchID: UUID? = nil
    
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
    
    init(title: String, catches: [FishCatch], onSelectTrip: ((Trip) -> Void)? = nil) {
        self.title = title
        self.catches = catches
        self.onSelectTrip = onSelectTrip
    }
    
    /// Helper to find the currently selected catch entity
    private var selectedCatch: FishCatch? {
        guard let id = selectedCatchID else { return nil }
        return mappedCatches.first(where: { $0.id == id })
    }
    
    public var body: some View {
        ZStack {
            // Layer 0 Base Canvas Backdrop
            Color.backgroundMain
                .ignoresSafeArea()
            
            // Map Canvas View with Selection Binding
            Map(position: $position, selection: $selectedCatchID) {
                ForEach(mappedCatches) { catchItem in
                    if let lat = catchItem.latitude, let lon = catchItem.longitude {
                        Marker(
                            catchItem.species?.name ?? "Unknown Fish",
                            monogram: Text(String(catchItem.species?.name.prefix(1) ?? "F")),
                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        )
                        .tint(SpeciesColorProvider.color(for: catchItem.species?.name))
                        .tag(catchItem.id)
                    }
                }
            }
            .mapStyle(mapStyleSelection.style)
            .ignoresSafeArea()
            
            // Floating Overlays Layer
            VStack {
                topControlHeader
                
                Spacer()
                
                // Bottom Interactive Layer: Shows Catch Callout Card if pin selected, otherwise Map Style Picker
                if let catchItem = selectedCatch {
                    floatingCatchCalloutCard(for: catchItem)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    bottomMapStylePicker
                        .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedCatchID)
        }
        .onAppear {
            // Populate isolated local collection and center camera
            self.mappedCatches = catches.filter { $0.latitude != nil && $0.longitude != nil }
            fitCameraToCatches()
        }
        .onDisappear {
            // Explicit Memory Flush: Release references to allow MapKit Metal context deallocation
            self.selectedCatchID = nil
            self.mappedCatches.removeAll()
            self.position = .automatic
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
                
                Text("\(mappedCatches.count) Mapped Catches")
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
            
            // Close Modal Button
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
    
    // MARK: - Floating Catch Callout Popover Card
    
    private func floatingCatchCalloutCard(for catchItem: FishCatch) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(catchItem.species?.name ?? "Unknown Species")
                        .cvFont(CVFont.sectionHeader)
                        .foregroundStyle(Color.textOnCardPrimary)
                    
                    HStack(spacing: 8) {
                        Text(catchItem.angler?.name ?? "Unknown Angler")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                        
                        Text("•")
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                        
                        Text(catchItem.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .cvFont(CVFont.metadata)
                            .foregroundStyle(Color.textOnCardSecondary)
                    }
                }
                
                Spacer()
                
                Text(String(format: "%.2f lbs", catchItem.weight))
                    .cvFont(CVFont.telemetryMedium)
                    .foregroundStyle(Color.brandAccent)
                
                Button {
                    selectedCatchID = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.textOnCardSecondary)
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            
            // "View Trip Details" Direct Navigation CTA
            if let targetTrip = catchItem.trip {
                Button {
                    let tripToPush = targetTrip
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSelectTrip?(tripToPush)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("View Trip Details")
                            .cvFont(CVFont.actionLabel)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.brandAccent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.surfaceCard)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
    
    private func fitCameraToCatches() {
        let coords = mappedCatches.compactMap { catchItem -> CLLocationCoordinate2D? in
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
