//
//  Reservoir.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/1/26.
//
import Foundation
import SwiftData

@Model
final class Reservoir {
    @Attribute(.unique)
    var id: UUID = UUID()
    
    @Attribute(.unique)
    var name: String
    
    @Relationship(deleteRule: .nullify, inverse: \Trip.reservoir)
    var trips: [Trip] = []
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.trips = []
    }
}
