# CatchVault — Project Memory & State

## 1. System Intent & Mission
- **Objective**: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData.
- **Key Vectors**:
  - Leverage native hardware & platform capabilities (MapKit, local notifications, timers, push notifications).
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
- **1.2 Relationship & CloudKit Rule Enforcement**: Applied explicit `@Relationship(inverse: ...)` macro ownership chains to guarantee CloudKit mirroring safety. Discovered and resolved a macro generation bottleneck caused by reciprocal structural cycles between `Trip` and `Angler`. Standardized by designating `Trip` as the explicit owner of cluster collection graphs, keeping property definitions clean and eliminating compiler ambiguity.
- **1.3 Cascade Validation Layer**: Established the automated test oracle using a dedicated unit testing target (`CatchVaultTests`). Authored schema integration tests executing in isolated memory configurations to verify that delete policies (`.cascade` for `Trip` ↔ `FishCatch` and `.nullify` for remaining paths) protect structural graph integrity without creating orphan states.

## 5. Core Domain Entities & Schema Analysis
### Target Data Model (SwiftData Graph)
- **Reservoir**: Unique identifier and location tracking. Deduplicated by name string.
- **Angler**: Unique identifier and name string. Deduplicated by name string.
- **Species**: Unique identifier and species categorization. Deduplicated by name string.
- **FishCatch**: Captures exact timestamp, precise decimal weight, optional GPS coordinates (`Double?`), local storage image path, and descriptive text comments.
- **Trip**: Tracks a distinct fishing session over time, bundling multiple `FishCatch` entries. Contains synthetic weather parameters and telemetry.

## 6. Current Engineering Constraints & Critical Paths
### The Trip Synthesis State Strategy
- **Legacy Behavior**: The original application had no explicit schema representation for a "Trip". Users logged fish immediately at the moment of catch, making the trip concept entirely a UI-driven presentation layer.
- **Deterministic Grouping Rule**: The `MigrationManager` grouping strategy maps a "Trip" per calendar day, per unique reservoir, per angler.
- **Key Generation**: Synthetic trips are evaluated against a composite dictionary token pattern: `YYYY-MM-DD-ReservoirName`. Subsequent catches matching this token are dynamically grouped into the same parent `Trip` entry during data ingestion.

### Data Ingestion and Parsing Hazards (Active Focus for Milestone 2)
- **Coordinates**: Legacy latitude and longitude parameters are un-sanitized strings (often empty `""`). The migration layer must convert these into optional Swift `Double` values safely.
- **Weights**: Legacy weight data variations require polymorphic decoding handling (handling both string-wrapped integers/doubles and raw numeric structures via a specialized `StringOrDouble` enum wrapper).
- **Deduplication Constraint**: Inputs targeted at `Angler.name`, `Reservoir.name`, and `Species.name` undergo case-insensitive validation lookups in the active `ModelContext` before execution writes commit to storage.