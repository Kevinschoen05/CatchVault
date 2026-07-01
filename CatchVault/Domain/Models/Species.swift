//
//  Species.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/1/26.
//
import Foundation
import SwiftData

@Model
final class Species {
    @Attribute(.unique)
    var id: UUID = UUID()
    
    @Attribute(.unique)
    var name: String
    
    @Relationship(deleteRule: .nullify, inverse: \FishCatch.species)
    var catches: [FishCatch] = []
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.catches = []
    }
}
