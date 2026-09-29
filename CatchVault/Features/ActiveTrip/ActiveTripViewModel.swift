import Foundation
import Combine
import UIKit
import SwiftData

@Observable
@MainActor
final class ActiveTripViewModel {
    // MARK: - Core State Properties
    
    /// The active trip entity managed by SwiftData.
    let trip: Trip
    
    /// Raw calculated elapsed duration in seconds.
    private(set) var elapsedTime: TimeInterval = 0
    
    /// Indicates whether the active session timer is actively ticking.
    private(set) var isRunning: Bool = false
    
    // MARK: - Private Infrastructure
    
    private var timerTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization & Deinitialization
    
    init(trip: Trip) {
        self.trip = trip
        self.recalculateElapsedTime()
        self.setupLifecycleObservers()
        self.startTimer()
    }
    
    // MARK: - Formatted Output Properties
    
    /// Formatted stopwatch string (e.g., "02:14:35" or "05:12").
    var formattedElapsedTime: String {
        let totalSeconds = Int(max(0, elapsedTime))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    /// Total catch count logged for this active session.
    var totalCatchesCount: Int {
        trip.catches.count
    }
    
    /// Combined weight telemetry of all catches logged during this active trip.
    var totalWeight: Double {
        trip.catches.reduce(0.0) { $0 + $1.weight }
    }
    
    // MARK: - Timer Control Mechanics
    
    /// Starts or resumes the periodic 1-second ticker task.
    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        recalculateElapsedTime()
        
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second interval
                guard let self = self, self.isRunning else { break }
                self.recalculateElapsedTime()
            }
        }
    }
    
    /// Pauses the UI ticker (e.g. when presented with modal views).
    func pauseTimer() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }
    
    /// Stops the timer and clears state (explicit actor-isolated call).
    func stopTimer() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }
    
    /// Manually recalculates duration based on absolute hardware clock delta.
    func recalculateElapsedTime() {
        if let endTime = trip.endTime {
            elapsedTime = endTime.timeIntervalSince(trip.startTime)
        } else {
            elapsedTime = Date().timeIntervalSince(trip.startTime)
        }
    }
    
    // MARK: - App Lifecycle Synchronization
    
    private func setupLifecycleObservers() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.recalculateElapsedTime()
            }
            .store(in: &cancellables)
    }
}
