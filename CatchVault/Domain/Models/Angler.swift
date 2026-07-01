//
//  Angler.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/1/26.
//
import Foundation
import SwiftData

@Model
final class Angler {
    @Attribute(.unique)
    var id: UUID = UUID()
    
    var name: String
    
    var trips: [Trip] = []
    
    @Relationship(deleteRule: .nullify, inverse: \FishCatch.angler)
    var catches: [FishCatch] = []
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.trips = []
        self.catches = []
    }
}
