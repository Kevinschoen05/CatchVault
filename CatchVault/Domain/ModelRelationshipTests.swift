//
//  ModelRelationshipTests.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/1/26.
//
import XCTest
import SwiftData
@testable import CatchVault

final class ModelRelationshipTests: XCTestCase {
    var varModelContainer: ModelContainer!
    var varModelContext: ModelContext!
    
    override func setUpWithError() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        varModelContainer = try ModelContainer(for: Angler.self, Reservoir.self, Species.self, Trip.self, FishCatch.self, configurations: configuration)
        varModelContext = ModelContext(varModelContainer)
    }
    
    override func tearDownWithError() throws {
        varModelContext = nil
        varModelContainer = nil
    }
    
    func testTripDeleteCascadesToFishCatches() throws {
        let reservoir = Reservoir(name: "Croton")
        let angler = Angler(name: "Jim")
        let species = Species(name: "Pickerel")
        let trip = Trip(startTime: Date(), reservoir: reservoir)
        
        let fishCatch = FishCatch(timestamp: Date(), weight: 1.25, angler: angler, species: species)
        
        varModelContext.insert(reservoir)
        varModelContext.insert(angler)
        varModelContext.insert(species)
        varModelContext.insert(trip)
        varModelContext.insert(fishCatch)
        
        trip.catches.append(fishCatch)
        try varModelContext.save()
        
        let tripID = trip.id
        let catchID = fishCatch.id
        
        varModelContext.delete(trip)
        try varModelContext.save()
        
        let fetchedTrips = try varModelContext.fetch(FetchDescriptor<Trip>(predicate: #Predicate { $0.id == tripID }))
        let fetchedCatches = try varModelContext.fetch(FetchDescriptor<FishCatch>(predicate: #Predicate { $0.id == catchID }))
        
        XCTAssertTrue(fetchedTrips.isEmpty, "Trip should be deleted.")
        XCTAssertTrue(fetchedCatches.isEmpty, "FishCatch should be cascaded and deleted when parent Trip is deleted.")
    }
    
    func testReservoirDeleteNullifiesTripLink() throws {
        let reservoir = Reservoir(name: "New Croton")
        let trip = Trip(startTime: Date(), reservoir: reservoir)
        
        varModelContext.insert(reservoir)
        varModelContext.insert(trip)
        try varModelContext.save()
        
        let reservoirID = reservoir.id
        let tripID = trip.id
        
        varModelContext.delete(reservoir)
        try varModelContext.save()
        
        let fetchedReservoirs = try varModelContext.fetch(FetchDescriptor<Reservoir>(predicate: #Predicate { $0.id == reservoirID }))
        let fetchedTrips = try varModelContext.fetch(FetchDescriptor<Trip>(predicate: #Predicate { $0.id == tripID }))
        
        XCTAssertTrue(fetchedReservoirs.isEmpty, "Reservoir should be deleted.")
        XCTAssertFalse(fetchedTrips.isEmpty, "Trip should persist when its Reservoir is deleted.")
        XCTAssertNil(fetchedTrips.first?.reservoir, "Trip reservoir link should be nullified.")
    }
    
    func testTripAndAnglerManyToManyNullification() throws {
        let reservoir = Reservoir(name: "Kensico")
        let angler1 = Angler(name: "Matt")
        let angler2 = Angler(name: "Jim")
        let trip = Trip(startTime: Date(), reservoir: reservoir)
        
        varModelContext.insert(reservoir)
        varModelContext.insert(angler1)
        varModelContext.insert(angler2)
        varModelContext.insert(trip)
        
        trip.anglers.append(angler1)
        trip.anglers.append(angler2)
        try varModelContext.save()
        
        let tripID = trip.id
        let angler1ID = angler1.id
        
        varModelContext.delete(trip)
        try varModelContext.save()
        
        let fetchedAnglers = try varModelContext.fetch(FetchDescriptor<Angler>(predicate: #Predicate { $0.id == angler1ID }))
        XCTAssertFalse(fetchedAnglers.isEmpty, "Angler should persist when Trip is deleted.")
        XCTAssertTrue(fetchedAnglers.first?.trips.filter { $0.id == tripID }.isEmpty ?? true, "Relationship to deleted Trip should be cleared.")
    }
    
    func testAnglerDeleteNullifiesFishCatch() throws {
        let reservoir = Reservoir(name: "Croton")
        let angler = Angler(name: "Matt")
        let species = Species(name: "Bass")
        let fishCatch = FishCatch(timestamp: Date(), weight: 2.1, angler: angler, species: species)
        
        varModelContext.insert(reservoir)
        varModelContext.insert(angler)
        varModelContext.insert(species)
        varModelContext.insert(fishCatch)
        try varModelContext.save()
        
        let anglerID = angler.id
        let catchID = fishCatch.id
        
        varModelContext.delete(angler)
        try varModelContext.save()
        
        let fetchedCatches = try varModelContext.fetch(FetchDescriptor<FishCatch>(predicate: #Predicate { $0.id == catchID }))
        XCTAssertFalse(fetchedCatches.isEmpty, "FishCatch should persist when Angler is deleted.")
        XCTAssertNil(fetchedCatches.first?.angler, "Angler relationship should be nullified.")
    }
    
    func testSpeciesDeleteNullifiesFishCatch() throws {
        let reservoir = Reservoir(name: "Croton")
        let angler = Angler(name: "Jim")
        let species = Species(name: "Crappie")
        let fishCatch = FishCatch(timestamp: Date(), weight: 0.5, angler: angler, species: species)
        
        varModelContext.insert(reservoir)
        varModelContext.insert(angler)
        varModelContext.insert(species)
        varModelContext.insert(fishCatch)
        try varModelContext.save()
        
        let speciesID = species.id
        let catchID = fishCatch.id
        
        varModelContext.delete(species)
        try varModelContext.save()
        
        let fetchedCatches = try varModelContext.fetch(FetchDescriptor<FishCatch>(predicate: #Predicate { $0.id == catchID }))
        XCTAssertFalse(fetchedCatches.isEmpty, "FishCatch should persist when Species is deleted.")
        XCTAssertNil(fetchedCatches.first?.species, "Species relationship should be nullified.")
    }
}
