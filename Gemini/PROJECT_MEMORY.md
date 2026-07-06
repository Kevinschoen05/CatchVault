# CatchVault — Project Memory & State

## 1. System Intent & Mission
- **Objective**: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData.
- **Key Vectors**:
  - Leverage native hardware & platform capabilities (MapKit, local notifications, background timers, push notifications).
  - Modernize and optimize the UI/UX using a strict declarative, state-driven paradigm.
  - Implement a highly resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit.

## 2. Architectural Baseline & Evolutionary State
- **Data Persistence**: SwiftData acts as the absolute on-device engine and local source of truth. Programmatic `try context.save()` boundaries are explicitly enforced during data operations to avoid relying on unstable implicit container cycles.
- **Ingestion Strategy**: Static text data migration from production MongoDB exports via an intentional, chunked, heavily validated `MigrationManager` acting as an Anti-Corruption Layer (ACL).
- **Codebase Posture**: Clean greenfield implementation utilizing CatchVault V1 models as structural blueprints, rewritten to enforce strict multi-entity inverse macros and deterministic data laws.

## 3. Project Documentation Matrix (Source of Truth)
The project state is governed by six core reference files, which serve as our absolute test oracles and architectural guidelines:
1. **`RULES.md`**: Enforces system posture, conversational constraints, development practices, and strict communication invariants.
2. **`PROJECT_MEMORY.md`**: (This file) Tracks system evolution, architectural milestones, active state parameters, and strategic development progress.
3. **`USER_REQUIREMENTS_v1.md`**: Outlines the active transactional workflows, operational logging constraints, metrics calculations, and visual charts paradigms.
4. **`DATA_MODEL.md`**: Defines the precise schema configurations, relationship properties, cascade rules, and on-device deduplication requirements.
5. **`STYLE_GUIDE.md`**: Formally codifies semantic design tokens, color constraints, typographical configurations, and high-density layout rules.
6. **`Project File Structure.md`**: Mandates physical group separation within the Xcode workspace to isolate the domain logic from presentation and migration layers.

## 4. Completed Milestones & Architectural History
### 🟩 Milestone 1: Core Domain Engine Build (Completed)
- **1.1 Entity Layout Initialization**: Created the five baseline SwiftData files in `Domain/Models/`: `Angler.swift`, `Reservoir.swift`, `Species.swift`, `Trip.swift`, and `FishCatch.swift`.
- **1.2 Relationship & CloudKit Rule Enforcement**: Applied explicit `@Relationship(inverse: ...)` macro ownership chains to guarantee CloudKit mirroring safety. Resolved a macro generation bottleneck caused by reciprocal structural cycles between `Trip` and `Angler` by designating `Trip` as the explicit owner of cluster collection graphs.
- **1.3 Cascade Validation Layer**: Established the automated test oracle using a dedicated unit testing target (`CatchVaultTests`). Verified that delete policies (`.cascade` for `Trip` ↔ `FishCatch` and `.nullify` for remaining paths) protect structural graph integrity without creating orphan states.

### 🟩 Milestone 2: Data Ingestion Pipeline / Anti-Corruption Bridge (Completed)
- **2.1 Legacy Payload Decoders**: Designed and implemented polymorphic Swift `Decodable` models under `Features/Migration/Models/` capable of ingesting inconsistent raw JSON fragments from production MongoDB exports. Integrated a structural wrapper `StringOrDouble` to safely parse string-wrapped numerical values and raw numbers uniformly into type-safe metrics.
- **2.2 Deterministic Trip Aggregator**: Developed token-generation logic that groups separate floating legacy catch entries into single parent `Trip` occurrences. The unique token architecture tracks data boundaries using a composite dictionary structural layout rule matching `YYYY-MM-DD-ReservoirName`, mapping synthetic multi-angler single-day trip realities seamlessly.
- **2.3 Chunked Migration Executor**: Realized the core standalone `MigrationManager` pipeline. Ingestion mechanisms process data in bounded, transactionally complete memory batches, explicitly triggering intermediate `try context.save()` save points. Memory heaps are freed proactively during large payloads, preventing stack overflows or state corruptions on old target devices.

### 🛠️ Production Verification & Bug History (Milestone 2 Hardening)
During the initial application boot and live validation testing of `MigrationManager`, three critical integration hurdles were encountered and corrected:
- **Date Normalization Overhaul**: In early runs, the pipeline crashed due to date format variations in production MongoDB exports (which packaged dates inside nested `$date` structures containing ISO-8859 string fragments instead of flat primitives). The payload decoder was altered to normalize these structures into type-safe Swift `Date` objects on step zero, and the downstream day-grouping mechanism was refactored to consume the unified `Date` safely.
- **SwiftData Constructor & Initializer Constraints**: The pipeline encountered the notorious `Missing argument for parameter 'backingData' in call` compiler error. This happened because model entities were being instantiated via empty initializers `Angler()` with fields assigned post-initialization (`angler.name = record.angler`). Because our models enforce required memberwise constructors `init(id: UUID = UUID(), name: String)` to satisfy CloudKit invariants, the compiler dropped back to the macro-synthesized internal tracking signatures. This was corrected by feeding required properties explicitly inside class constructors at instantiation points.
- **Call-Site Parameter Mismatch**: A final signature error (`Missing argument for parameter 'records' in call`) occurred at the hook point inside `CatchVaultApp.swift`. The manager's execution method signature was rewritten to declare clear, idiomatic external and internal labels (`func migrate(from records: [LegacyFishRecord])`) to match native caller syntaxes perfectly.

## 5. Core Domain Entities & Schema Analysis
### Target Data Model (SwiftData Graph)
- **Reservoir**: Unique identifier and location tracking. Deduplicated by name string.
- **Angler**: Unique identifier and name string. Deduplicated by name string.
- **Species**: Unique identifier and species categorization. Deduplicated by name string.
- **FishCatch**: Captures exact timestamp, precise decimal weight, optional GPS coordinates (`Double?`), local storage image path, and descriptive text comments.
- **Trip**: Tracks a distinct fishing session over time, bundling multiple `FishCatch` entries. Contains synthetic weather parameters and telemetry.

## 6. Current Engineering Constraints & Critical Paths
### Post-Migration Database Status
- The ingestion engine is fully validated and operational. The local database state has successfully converted production text imports into a heavily normalized relational SwiftData engine graph without creating orphan states or duplicate entity records.
- The one-time cutover initialization rule is securely locked inside app launch setups, driven by a `UserDefaults` token to guarantee idempotency and guard against multi-trigger ingest hazards.

### Active Target Path (Milestone 3: Presentation Core Architecture)
- **3.1 Semantic Token Layer**: Instantiating static architectural styles for global design compliance, reifying font metrics and size standards defined inside `STYLE_GUIDE.md`.
- **3.2 Custom UI Container Structure**: Deploying structural `CVCardContainer` templates across user environments to preserve layout canvas symmetries.
- **3.3 Infrastructure Service Proxies**: Engineering the `CoreLocation` device tracking hooks and setting up external telemetry serialization bridges.