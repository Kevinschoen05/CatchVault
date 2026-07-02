import XCTest
import SwiftData
@testable import CatchVault

final class MigrationManagerTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var sut: MigrationManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: Angler.self, Reservoir.self, Species.self, Trip.self, FishCatch.self,
            configurations: config
        )
        
        context = ModelContext(container)
        sut = MigrationManager(context: context)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        context = nil
        container = nil
        try super.tearDownWithError()
    }
    
    func testMigrationWithPolymorphicDataAndTelemetryInvariants() throws {
        // Arrange: Locate the asset within the localized execution test bundle
        let testBundle = Bundle(for: Self.self)
        
        // Safely evaluate file resolution mapping to pinpoint packaging defects instantly
        let fileURL = try XCTUnwrap(
            testBundle.url(forResource: "mock_legacy_extract", withExtension: "json"),
            "Critical Failure: 'mock_legacy_extract.json' was not discovered in the test target asset bundle. Verify Target Membership setup."
        )
        
        // Read binary contents from disk storage path
        let jsonData = try Data(contentsOf: fileURL)
        
        // Act: Invoke the anti-corruption layer transformation loop
        try sut.migrate(from: jsonData)
        
        // Assert: Verify structural entity deduplication invariants
        let anglerFetch = FetchDescriptor<Angler>()
        let anglers = try context.fetch(anglerFetch)
        XCTAssertEqual(anglers.count, 1, "The ingestion pipeline failed to deduplicate repeating angler entity instances case-insensitively.")
        XCTAssertEqual(anglers.first?.name, "Jim")
        
        // Assert: Verify synthetic calendar trip generation
        let tripFetch = FetchDescriptor<Trip>()
        let trips = try context.fetch(tripFetch)
        XCTAssertEqual(trips.count, 1, "The engine failed to consolidate concurrent catches on the same date and body of water into a single parent Trip record.")
        
        // Assert: Verify relationship composition maps correctly on disk
        let catchFetch = FetchDescriptor<FishCatch>()
        let catches = try context.fetch(catchFetch)
        XCTAssertEqual(catches.count, 2, "The ingestion pipeline dropped line records structurally.")
        
        // Assert: Verify polymorphic string weight extraction rules survived
        let stringWeightCatch = catches.first(where: { $0.weight == 1.82 })
        XCTAssertNotNil(stringWeightCatch, "The pipeline failed to map string-formatted decimal metrics polymorphically into double primitives.")
        
        // Assert: Verify coordinate atomic telemetry constraint
        XCTAssertNil(stringWeightCatch?.latitude, "Empty coordinate values should resolve cleanly to explicit nil properties on device.")
    }
}
