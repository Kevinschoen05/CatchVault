//
//  FishCatch.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/1/26.
//
import Foundation
import SwiftData

@Model
final class FishCatch {
    @Attribute(.unique)
    var id: UUID = UUID()
    
    var timestamp: Date
    var weight: Double
    var latitude: Double?
    var longitude: Double?
    var imagePath: String?
    var comment: String?
    
    var trip: Trip?
    var angler: Angler?
    var species: Species?
    
    init(
        id: UUID = UUID(),
        timestamp: Date,
        weight: Double,
        latitude: Double? = nil,
        longitude: Double? = nil,
        imagePath: String? = nil,
        comment: String? = nil,
        trip: Trip? = nil,
        angler: Angler? = nil,
        species: Species? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.weight = weight
        self.latitude = latitude
        self.longitude = longitude
        self.imagePath = imagePath
        self.comment = comment
        self.trip = trip
        self.angler = angler
        self.species = species
    }
}
