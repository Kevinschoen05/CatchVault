//
//  Trip.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/1/26.
//
import Foundation
import SwiftData

@Model
final class Trip {
    @Attribute(.unique)
    var id: UUID = UUID()
    
    var startTime: Date
    var endTime: Date?
    var notes: String?
    var migrated: Bool
    var dataVersion: Int
    
    // Weather Snapshot Data
    var weatherSummary: String?
    var temperature: Double?
    var windSpeed: Double?
    var precipitation: Double?
    
    // Relationships
    var reservoir: Reservoir?
    
    @Relationship(deleteRule: .nullify, inverse: \Angler.trips)
    var anglers: [Angler] = []
    
    @Relationship(deleteRule: .cascade, inverse: \FishCatch.trip)
    var catches: [FishCatch] = []
    
    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date? = nil,
        notes: String? = nil,
        migrated: Bool = false,
        dataVersion: Int = 1,
        weatherSummary: String? = nil,
        temperature: Double? = nil,
        windSpeed: Double? = nil,
        precipitation: Double? = nil,
        reservoir: Reservoir? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
        self.migrated = migrated
        self.dataVersion = dataVersion
        self.weatherSummary = weatherSummary
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.precipitation = precipitation
        self.reservoir = reservoir
        self.anglers = []
        self.catches = []
    }
}
