//
//  LocationService.swift
//  CatchVault
//

import Foundation
import CoreLocation

public protocol LocationServiceProtocol {
    func requestCurrentLocation() async throws -> CLLocation
}

public final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    public static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?
    private var timeoutTask: Task<Void, Never>?
    private var bestLocationSoFar: CLLocation?
    
    public enum LocationError: LocalizedError {
        case servicesDisabled
        case permissionDenied
        case timeout
        case unknown
        
        public var errorDescription: String? {
            switch self {
            case .servicesDisabled:
                return "Location services are disabled on this device."
            case .permissionDenied:
                return "Location access was denied."
            case .timeout:
                return "Unable to acquire accurate GPS fix within timeout window."
            case .unknown:
                return "An unknown location error occurred."
            }
        }
    }
    
    override public init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public func requestCurrentLocation() async throws -> CLLocation {
        print("📍 [GPS DEBUG] Location request initiated...")
        
        guard CLLocationManager.locationServicesEnabled() else {
            print("❌ [GPS DEBUG] Location services disabled.")
            throw LocationError.servicesDisabled
        }
        
        // Prevent Continuation Leak: Cleanly resolve any prior pending request
        if let existingContinuation = self.continuation {
            print("⚠️ [GPS DEBUG] Resolving prior pending continuation.")
            self.continuation = nil
            existingContinuation.resume(throwing: LocationError.timeout)
        }
        
        bestLocationSoFar = nil
        let status = locationManager.authorizationStatus
        print("📍 [GPS DEBUG] Authorization status: \(status.rawValue)")
        
        if status == .denied || status == .restricted {
            print("❌ [GPS DEBUG] Permission denied or restricted.")
            throw LocationError.permissionDenied
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            if status == .notDetermined {
                print("📍 [GPS DEBUG] Prompting user for Location Authorization...")
                self.locationManager.requestWhenInUseAuthorization()
            } else {
                self.startHardwareUpdates()
            }
            
            // 15-second timeout safeguard
            self.timeoutTask = Task {
                try? await Task.sleep(nanoseconds: 15_000_000_000)
                if !Task.isCancelled {
                    print("⚠️ [GPS DEBUG] 15-second timeout fired.")
                    if let fallback = self.bestLocationSoFar {
                        print("✅ [GPS DEBUG] Returning fallback location: \(fallback.coordinate)")
                        self.finish(with: .success(fallback))
                    } else {
                        print("❌ [GPS DEBUG] No location acquired within window.")
                        self.finish(with: .failure(LocationError.timeout))
                    }
                }
            }
        }
    }
    
    private func startHardwareUpdates() {
        print("📍 [GPS DEBUG] Starting hardware location updates...")
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("📍 [GPS DEBUG] Authorization status changed to: \(status.rawValue)")
        
        guard continuation != nil else { return }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startHardwareUpdates()
        case .denied, .restricted:
            finish(with: .failure(LocationError.permissionDenied))
        case .notDetermined:
            break
        @unknown default:
            finish(with: .failure(LocationError.unknown))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let age = abs(location.timestamp.timeIntervalSinceNow)
        let accuracy = location.horizontalAccuracy
        
        print("📍 [GPS DEBUG] Update received | Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)")
        print("📍 [GPS DEBUG] Accuracy: ±\(accuracy)m | Age: \(String(format: "%.2f", age))s")
        
        if accuracy >= 0 {
            if let existingBest = bestLocationSoFar {
                if accuracy < existingBest.horizontalAccuracy {
                    bestLocationSoFar = location
                }
            } else {
                bestLocationSoFar = location
            }
        }
        
        let isRecent = age < 10.0
        
        #if targetEnvironment(simulator)
        let isAccurate = accuracy >= 0 && accuracy <= 100.0
        #else
        let isAccurate = accuracy >= 0 && accuracy <= 20.0
        #endif
        
        if isRecent && isAccurate {
            print("✅ [GPS DEBUG] High-accuracy fix locked!")
            finish(with: .success(location))
        } else {
            print("⚠️ [GPS DEBUG] Fix pending accuracy/recency filters.")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ [GPS DEBUG] CLLocationManager error: \(error.localizedDescription)")
        if let clError = error as? CLError {
            if clError.code == .denied {
                finish(with: .failure(LocationError.permissionDenied))
                return
            } else if clError.code == .locationUnknown {
                print("⚠️ [GPS DEBUG] Location currently unknown, keeping hardware stream active...")
                return
            }
        }
        finish(with: .failure(error))
    }
    
    // MARK: - Helper Termination
    
    private func finish(with result: Result<CLLocation, Error>) {
        locationManager.stopUpdatingLocation()
        timeoutTask?.cancel()
        timeoutTask = nil
        
        if let continuation = self.continuation {
            self.continuation = nil
            switch result {
            case .success(let location):
                continuation.resume(returning: location)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
} 
