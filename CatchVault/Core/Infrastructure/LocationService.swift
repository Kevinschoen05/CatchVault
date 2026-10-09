//
//  LocationService.swift
//  CatchVault
//

import Foundation
import CoreLocation

/// Protocol abstraction enabling dependency injection and testability for hardware location requests.
public protocol LocationServiceProtocol {
    func requestCurrentLocation() async throws -> CLLocation
}

/// Concrete implementation managing native CLLocationManager hardware interactions.
public final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    public static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?
    private var timeoutTask: Task<Void, Never>?
    private var bestLocationSoFar: CLLocation?
    private var isAwaitingAuthorization: Bool = false
    private var activeTask: Task<CLLocation, Error>?
    
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
    
    /// Requests instantaneous GPS coordinates with accuracy filtering and a 15-second timeout safeguard.
    public func requestCurrentLocation() async throws -> CLLocation {
        // Prevent Re-entrancy: If a location request is already in-flight, return the active task
        if let existingTask = activeTask {
            print("ℹ️ [GPS DEBUG] Location request already in flight. Joining existing task...")
            return try await existingTask.value
        }
        
        let task = Task<CLLocation, Error> {
            try await self.performLocationRequest()
        }
        
        self.activeTask = task
        
        defer {
            self.activeTask = nil
        }
        
        return try await task.value
    }
    
    private func performLocationRequest() async throws -> CLLocation {
        print("📍 [GPS DEBUG] Location request initiated...")
        
        guard CLLocationManager.locationServicesEnabled() else {
            print("❌ [GPS DEBUG] Location services are disabled on device.")
            throw LocationError.servicesDisabled
        }
        
        bestLocationSoFar = nil
        let status = locationManager.authorizationStatus
        print("📍 [GPS DEBUG] Current authorization status: \(status.rawValue)")
        
        if status == .denied || status == .restricted {
            print("❌ [GPS DEBUG] Permission denied or restricted.")
            throw LocationError.permissionDenied
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            if status == .notDetermined {
                print("📍 [GPS DEBUG] Prompting user for Location Authorization...")
                self.isAwaitingAuthorization = true
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
                        print("✅ [GPS DEBUG] Returning best location acquired before timeout: \(fallback.coordinate)")
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
        
        guard continuation != nil || isAwaitingAuthorization else { return }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isAwaitingAuthorization = false
            startHardwareUpdates()
        case .denied, .restricted:
            isAwaitingAuthorization = false
            finish(with: .failure(LocationError.permissionDenied))
        case .notDetermined:
            break
        @unknown default:
            isAwaitingAuthorization = false
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
        // Relax accuracy threshold in Simulator because mock locationd often reports ±50m or uncalibrated values
        let isAccurate = accuracy >= 0 && accuracy <= 100.0
        #else
        // Strict off-grid satellite accuracy requirement for physical hardware
        let isAccurate = accuracy >= 0 && accuracy <= 20.0
        #endif
        
        if isRecent && isAccurate {
            print("✅ [GPS DEBUG] Valid high-accuracy fix acquired!")
            finish(with: .success(location))
        } else {
            print("⚠️ [GPS DEBUG] Fix rejected | isRecent: \(isRecent), isAccurate: \(isAccurate)")
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
    
    // MARK: - Safe Continuation Termination
    
    private func finish(with result: Result<CLLocation, Error>) {
        locationManager.stopUpdatingLocation()
        timeoutTask?.cancel()
        timeoutTask = nil
        isAwaitingAuthorization = false
        
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
