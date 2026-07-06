//
//  CatchVaultApp.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/1/26.
//

import SwiftUI
import SwiftData

@main
struct CatchVaultApp: App {
    // Standard persistent multi-entity system container matching schema requirements
    let container: ModelContainer
    
    init() {
        do {
            // Instantiate the live SQLite disk container engine matching DATA_MODEL.md matrix
            container = try ModelContainer(for: Angler.self, Reservoir.self, Species.self, Trip.self, FishCatch.self)
            
            // Invoke the safety-gated cutover migration engine immediately upon container spin-up
            checkForAndRunMigration()
        } catch {
            fatalError("Failed to initialize production ModelContainer engine: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ReservoirHome() // Root presentation dashboard entry point
        }
        .modelContainer(container) // Cascade context through the view hierarchy
    }
    
    // MARK: - Safe Ingestion Guardrails Engine
    
    private func checkForAndRunMigration() {
        let key = "didPerformLegacyMigration"
        
        // --- Strategy Rule: Enforce One-Time Production Cutover Law ---
        if UserDefaults.standard.bool(forKey: key) {
            print("[MIGRATION GUARDRAIL] Cutover state evaluated true. System initialized cleanly from existing disk storage.")
            return
        }
        
        print("[MIGRATION GUARDRAIL] Snapshot marker missing. Preparing initial state setup...")
        
        // Isolate context thread operations manually to keep launch sequence thread-safe
        let backgroundContext = ModelContext(container)
        let manager = MigrationManager(context: backgroundContext)
        
        // Locate the cleaned production snapshot embedded inside the application package bundle
        guard let fileURL = Bundle.main.url(forResource: "cleaned_production_snapshot", withExtension: "json") else {
            print("[CRITICAL DIAGNOSTIC ERROR] 'cleaned_production_snapshot.json' missing from main application bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            // 1. Decode the uniform JSON primitives directly into our typed recovery array structures
            let records = try JSONDecoder().decode([LegacyFishRecord].self, from: data)
            
            // 2. Pass the typed array cleanly into the ingestion engine
            try manager.migrate(from: records)
            
            // Lock down state mutation securely on success to ensure idempotency across simulator restarts
            UserDefaults.standard.set(true, forKey: key)
            print("[MIGRATION PIPELINE COMPLETE] Initial snapshot loaded into local storage safely.")
        } catch {
            print("[CRITICAL MIGRATION ERROR] Ingestion engine aborted. State unchanged: \(error)")
        }
    }
}
