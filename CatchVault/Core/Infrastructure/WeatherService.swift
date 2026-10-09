//
//  WeatherService.swift
//  CatchVault
//

import Foundation
import CoreLocation
import WeatherKit

/// Strongly typed value object representing an environmental snapshot.
public struct WeatherSnapshot: Sendable {
    public let temperature: Double?     // In °F
    public let windSpeed: Double?       // In mph
    public let precipitation: Double?   // In inches
    public let summary: String?         // e.g. "Mostly Clear", "Light Rain"
    
    public init(
        temperature: Double? = nil,
        windSpeed: Double? = nil,
        precipitation: Double? = nil,
        summary: String? = nil
    ) {
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.precipitation = precipitation
        self.summary = summary
    }
}

/// Protocol abstraction enabling injection and testability for weather queries.
public protocol WeatherServiceProtocol: Sendable {
    func fetchCurrentWeather(for location: CLLocationCoordinate2D) async -> WeatherSnapshot?
}

/// Concrete infrastructure implementation interfacing with Apple's WeatherKit service.
public final class WeatherService: WeatherServiceProtocol, @unchecked Sendable {
    public static let shared = WeatherService()
    
    private let appleWeatherService = WeatherKit.WeatherService.shared
    
    public init() {}
    
    /// Requests instantaneous weather metrics for a coordinate location.
    /// Returns `nil` gracefully on network failure, off-grid offline state, or missing capabilities.
    public func fetchCurrentWeather(for location: CLLocationCoordinate2D) async -> WeatherSnapshot? {
        print("🌤️ [WEATHER DEBUG] Weather fetch initiated for coordinate: \(location.latitude), \(location.longitude)...")
        
        // Basic coordinate sanity validation
        guard CLLocationCoordinate2DIsValid(location),
              location.latitude != 0.0 || location.longitude != 0.0 else {
            print("❌ [WEATHER DEBUG] Invalid coordinate provided (0.0, 0.0 or invalid). Aborting fetch.")
            return nil
        }
        
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        do {
            // Perform WeatherKit query with an asynchronous timeout safeguard (5 seconds)
            let weather = try await withTimeout(seconds: 5.0) {
                try await self.appleWeatherService.weather(for: clLocation)
            }
            
            let currentWeather = weather.currentWeather
            
            // Extract & convert metric values to imperial defaults
            let tempFahrenheit = currentWeather.temperature.converted(to: .fahrenheit).value
            let windMph = currentWeather.wind.speed.converted(to: .milesPerHour).value
            
            // Extract precipitation amount from hour forecast if available
            let precipitationInches = weather.hourlyForecast.first?.precipitationAmount.converted(to: .inches).value ?? 0.0
            
            let summaryDescription = currentWeather.condition.description
            
            print("✅ [WEATHER DEBUG] Weather successfully fetched!")
            print("   - Temp: \(String(format: "%.1f", tempFahrenheit)) °F")
            print("   - Wind: \(String(format: "%.1f", windMph)) mph")
            print("   - Precip: \(String(format: "%.2f", precipitationInches)) in")
            print("   - Summary: \(summaryDescription)")
            
            return WeatherSnapshot(
                temperature: tempFahrenheit,
                windSpeed: windMph,
                precipitation: precipitationInches,
                summary: summaryDescription
            )
            
        } catch {
            print("⚠️ [WEATHER DEBUG] WeatherKit query failed or timed out: \(error.localizedDescription)")
            print("⚠️ [WEATHER DEBUG] Gracefully returning nil snapshot (off-grid or network error fallback).")
            return nil
        }
    }
    
    // MARK: - Async Timeout Helper
    
    private func withTimeout<T: Sendable>(seconds: TimeInterval, operation: @escaping @Sendable () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw URLError(.timedOut)
            }
            
            guard let result = try await group.next() else {
                throw URLError(.unknown)
            }
            
            group.cancelAll()
            return result
        }
    }
}
