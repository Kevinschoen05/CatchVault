import Foundation
import SwiftData
import SwiftUI
import CoreLocation

@Observable
final class EndTripViewModel {
    // MARK: - Local Editable State
    var tripNotes: String = ""
    var isSaving: Bool = false
    var isFetchingWeather: Bool = false
    var errorMessage: String?
    
    // MARK: - Context Dependencies
    let trip: Trip
    private let weatherService: WeatherServiceProtocol
    
    // MARK: - Initializer
    init(trip: Trip, weatherService: WeatherServiceProtocol = WeatherService.shared) {
        self.trip = trip
        self.tripNotes = trip.notes ?? ""
        self.weatherService = weatherService
    }
    
    // MARK: - Computed Summary Readouts
    
    /// Final elapsed trip duration formatted as HH:mm:ss
    var formattedFinalDuration: String {
        let end = trip.endTime ?? Date()
        let elapsed = max(0, end.timeIntervalSince(trip.startTime))
        
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// Total fish landed count derived from trip.catches
    var totalCatchesCount: Int {
        trip.catches.count
    }
    
    /// Cumulative weight landed sum in pounds
    var totalWeight: Double {
        trip.catches.reduce(0.0) { $0 + $1.weight }
    }
    
    /// Formatted comma-separated list of participating anglers
    var anglersFormattedString: String {
        guard !trip.anglers.isEmpty else { return "No Anglers Assigned" }
        return trip.anglers.map { $0.name }.sorted().joined(separator: ", ")
    }
    
    /// Breakdown of catches count per species for the session summary
    var speciesSummary: [(speciesName: String, count: Int)] {
        var counts: [String: Int] = [:]
        for catchItem in trip.catches {
            let name = catchItem.species?.name ?? "Unknown Species"
            counts[name, default: 0] += 1
        }
        return counts.map { (speciesName: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })
    }
    
    // MARK: - Coordinate Resolution Hierarchy
    
    /// Resolves the best available coordinate for weather queries.
    /// Priority 1: Coordinate of last catch on this trip
    /// Priority 2: Parent reservoir coordinates
    private func resolveCoordinate() async -> CLLocationCoordinate2D? {
            // Priority 1: Last catch logged on this trip with valid GPS coordinates
            if let lastCatch = trip.catches.last(where: { $0.latitude != nil && $0.longitude != nil }),
               let lat = lastCatch.latitude,
               let lon = lastCatch.longitude {
                print("📍 [WEATHER DEBUG] Priority 1: Using last catch coordinates (\(lat), \(lon))")
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            
            // Priority 2: Active device hardware location snapshot at time of closing trip
            do {
                let location = try await LocationService.shared.requestCurrentLocation()
                print("📍 [WEATHER DEBUG] Priority 2: Using active hardware GPS fix (\(location.coordinate.latitude), \(location.coordinate.longitude))")
                return location.coordinate
            } catch {
                print("⚠️ [WEATHER DEBUG] Active GPS request failed or unavailable: \(error.localizedDescription)")
            }
            
            // Priority 3: Fallback to parent Reservoir geographic coordinates
            if let resLat = trip.reservoir?.latitude,
               let resLon = trip.reservoir?.longitude {
                print("📍 [WEATHER DEBUG] Priority 3: Using parent reservoir fallback coordinates (\(resLat), \(resLon))")
                return CLLocationCoordinate2D(latitude: resLat, longitude: resLon)
            }
            
            print("❌ [WEATHER DEBUG] No valid coordinates resolved across catches, active GPS, or reservoir.")
            return nil
        }
    // MARK: - Atomic Session Closing Operation
    
    /// Concludes and locks the active trip session by fetching weather, stamping endTime, persisting notes, and saving context.
    @MainActor
        func saveAndEndTrip(context: ModelContext) async -> Bool {
            isSaving = true
            isFetchingWeather = true
            defer {
                isSaving = false
                isFetchingWeather = false
            }
            
            // 1. Resolve geographic target across 3-tier hierarchy & fetch weather snapshot
            if let coordinate = await resolveCoordinate() {
                let snapshot = await weatherService.fetchCurrentWeather(for: coordinate)
                trip.temperature = snapshot?.temperature
                trip.windSpeed = snapshot?.windSpeed
                trip.precipitation = snapshot?.precipitation
                trip.weatherSummary = snapshot?.summary
            } else {
                print("ℹ️ [WEATHER DEBUG] Skipping weather fetch due to unresolvable location.")
            }
            
            let trimmedNotes = tripNotes.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 2. Lock trip state with endTime and notes
            trip.endTime = Date()
            trip.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            
            // 3. Commit atomic transaction
            do {
                try context.save()
                return true
            } catch {
                errorMessage = "Failed to complete and save trip: \(error.localizedDescription)"
                return false
            }
        }
}
