//
//  ContentView.swift
//  CatchVault
//  Path: CatchVault/App/ContentView.swift
//

import SwiftUI
import SwiftData

public struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Trip> { $0.endTime == nil }) private var activeTrips: [Trip]
    
    @State private var showSplash: Bool = true
    
    public init() {}
    
    public var body: some View {
        Group {
            if showSplash {
                // Phase 2: Dynamic Launch Overlay (Guaranteed Initial View Gate)
                LaunchView(isAnimating: $showSplash)
            } else {
                // Phase 3: Main App Root & Active Trip Interceptor
                NavigationStack {
                    ReservoirHome()
                }
                .fullScreenCover(item: Binding(
                    get: { activeTrips.first },
                    set: { _ in }
                )) { unclosedTrip in
                    ActiveTripView(trip: unclosedTrip)
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
    }
}
