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
            // Instantiate the live SQLite disk container engine
            container = try ModelContainer(for: Angler.self, Reservoir.self, Species.self, Trip.self, FishCatch.self)
            
            // Invoke the safety-gated cutover migration engine immediately upon container spin-up
            checkForAndRunMigration()
        } catch {
            fatalError("Failed to initialize production ModelContainer engine: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView() // Your root navigation/dashboard view interface
        }
        .modelContainer(container) // Cascade context through the view hierarchy
    }
    
    // MARK: - Safe Ingestion Guardrails Engine
    
    private func checkForAndRunMigration() {
        let key = "hasCompletedLegacyMigration"
        
        // --- Strategy Rule: Enforce One-Time Production Cutover Law ---
        if UserDefaults.standard.bool(forKey: key) {
            print("[MIGRATION GUARDRAIL] Cutover state evaluated true. System initialized cleanly from existing disk storage.")
            return
        }
        
        print("[MIGRATION GUARDRAIL] Snapshot marker missing. Preparing initial state setup...")
        
        // Isolate context thread operations manually
        let backgroundContext = ModelContext(container)
        let manager = MigrationManager(context: backgroundContext)
        
        // Locate the target asset embedded inside the primary production app binary package
        guard let fileURL = Bundle.main.url(forResource: "production_snapshot", withExtension: "json") else {
            print("[CRITICAL DIAGNOSTIC ERROR] 'production_snapshot.json' missing from main application bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            // Execute the Anti-Corruption Layer normalization transaction
            try manager.migrate(from: data)
            
            // Lock down state mutation securely on success to ensure idempotency across restarts
            UserDefaults.standard.set(true, forKey: key)
            print("[MIGRATION PIPELINE COMPLETE] Initial snapshot loaded into local storage safely.")
        } catch {
            print("[CRITICAL MIGRATION ERROR] Ingestion engine aborted. State unchanged: \(error)")
        }
    }
}
