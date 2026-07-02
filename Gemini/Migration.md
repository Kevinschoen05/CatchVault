CatchVault — Migration Execution & Testing Strategy
This specification codifies the operational execution, bundle asset isolation, lifecycle test integration, and simulator deployment architectures for the MigrationManager anti-corruption pipeline. All validation routines and application hooks must conform strictly to these patterns to protect transactional stability and prevent state pollution.

1. Automated Unit Testing Environment Architecture
To guarantee total state isolation and rule enforcement across individual test runs without altering active disk-bound device storage, tests execute within volatile RAM boundaries using a configured In-Memory Model Container.

Structural Lifecycle Matrix
+-------------------------------------------------------------+
|                     XCTest Suite Lifecycle                  |
|                                                             |
|  1. setUpWithError()   --> Spins up Fresh In-Memory RAM DB  |
|  2. testMigration()    --> Executes Ingestion & Assertions   |
|  3. tearDownWithError()--> Purges RAM Database to Zero      |
+-------------------------------------------------------------+
2. Testing Bundle Resource Isolation Configuration
To back the test suite above with deterministic assets, mock extractions must sit strictly within the test framework bundle bounds.

Target Setup Protocol
Export a representative JSON text snippet containing edge-case anomalies (such as alternate payload type notations or missing coordinate fields) as a file named mock_legacy_extract.json.

Move mock_legacy_extract.json directly into the physical workspace folder CatchVaultTests/.

Highlight the asset inside the Xcode Project Navigator to expose the Identity and Type inspect panel.

Set Target Membership parameters exactly as follows:

Checked: CatchVaultTests

Unchecked: CatchVault

3. Simulator Integration Architecture & App Initialization Pipeline
To facilitate safe workflow and interface verification using real production subsets within active iPhone simulator environments, the single-use data ingestion bridge mounts into the absolute startup lifecycle sequence of the executable binary.

4. Deterministic State Purging & Re-Ingestion Procedures
Because persistent SQLite storage files and local standard user default key states are retained continuously across normal simulator re-runs, modifications to source data values or framework logic require a complete environment tear-down protocol.

Sandbox Clean Reset Protocol
To dump the state completely and execute a clean ingestion cycle using a revised production_snapshot.json asset, use this workspace execution path:

Bring the active iPhone Simulator application container window focus to the foreground.

Direct control markers to the host macOS toolbar menu block and execute: Device → Erase All Content and Settings...

Confirm the teardown command inside the alert dialog.

Wait for the operating system environment simulator to wipe the virtual device disk storage directories completely to zero. This purges all residual SQLite files and updates UserDefaults tracking flags back to zero states.

Return focus to your primary Xcode window and execute Cmd + R to launch a clean compilation deployment instance.

The application launch framework will fail the conditional UserDefaults match test, safely acquire the primary production_snapshot.json asset bundle resource, map synthetic parent objects, commit atomized blocks to storage, and initialize the SwiftUI view architecture instantly.