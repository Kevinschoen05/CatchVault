# CatchVault — Project Memory & State

## 1. System Intent & Mission
- **Objective**: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData.
- **Key Vectors**:
  - Leverage native hardware & platform capabilities (MapKit, local notifications, timers, push notifications).
  - Modernize and optimize the UI/UX using a strict declarative, state-driven paradigm.
  - Implement a highly resilient, offline-ready local database configuration.

## 2. Architectural Baseline (Iteration 0)
- **Data Persistence**: SwiftData acts as the absolute on-device engine and local source of truth.
- **Ingestion Strategy**: Static text data migration from production MongoDB exports via an intentional, heavily validated `MigrationManager` acting as an Anti-Corruption Layer (ACL).
- **Codebase Posture**: Clean greenfield implementation utilizing CatchVault V1 models as structural blueprints while rewriting all execution paths to preserve clear architectural boundaries.

## 3. Project Documentation Matrix (Source of Truth)
The project state is governed by five core reference files, which serve as our absolute test oracles and guidelines:
1. **`RULES.md`**: Enforces system posture, architectural rules, development practices, and strict communication invariants.
2. **`PROJECT_MEMORY.md`**: (This file) Tracks system evolution, architectural milestones, active state baselines, and engineering constraints.
3. **`USER_REQUIREMENTS_v1.md`**: Formally maps out product workflows, trip lifecycles, and operational requirements for real-time logging and high-density analytics dashboards.
4. **`DATA_MODEL.md`**: Establishes the concrete SwiftData schema definitions, relational integrity rules, cascade delete policies, and automated background CloudKit mirroring compatibility requirements.
5. **`STYLE_GUIDE.md`**: Implements a strict visual design ledger defining semantic layout tokens, strict container nesting hierarchies, typography, and viewport adaptation rules.

## 4. Core Domain Entities & Schema Analysis
### Legacy Data Footprint (Source)
- Flat JSON structures capturing individual catch entries.
- **Fields**: `_id` (ObjectId), `date` (ISO/String formats), `image`, `species` (String), `angler` (String), `weight` (Double/String variations), `reservoir` (String), `comment` (String), `latitude` (String/Empty), `longitude` (String/Empty).

### Target Data Model (SwiftData Graph)
- **Reservoir**: Unique identifier and location tracking. Deduplicated by name string.
- **Angler**: Unique identifier and name string. Deduplicated by name string.
- **Species**: Unique identifier and species categorization. Deduplicated by name string.
- **FishCatch**: Captures exact timestamp, precise decimal weight, optional GPS coordinates (`Double?`), local storage image path, and descriptive text comments.
- **Trip**: Tracks a distinct fishing session over time, bundling multiple `FishCatch` entries. Contains synthetic weather parameters and telemetry.

## 5. Current Engineering Constraints & Critical Paths
### The Trip Synthesis State Strategy
- **Legacy Behavior**: The original application had no explicit schema representation for a "Trip". Users logged fish immediately at the moment of catch, making the trip concept entirely a UI-driven presentation layer.
- **Deterministic Grouping Rule**: The `MigrationManager` grouping strategy maps a "Trip" per calendar day, per unique reservoir, per angler.
- **Key Generation**: Synthetic trips are evaluated against a composite dictionary token pattern: `YYYY-MM-DD-ReservoirName`. Subsequent catches matching this token are dynamically grouped into the same parent `Trip` entry during data ingestion.

### Data Validation and Parsing Hazards
- **Coordinates**: Legacy latitude and longitude parameters are un-sanitized strings (often empty `""`). The migration layer converts these into optional Swift `Double` values safely.
- **Weights**: Legacy weight data variations require polymorphic decoding handling (handling both string-wrapped integers/doubles and raw numeric structures).
- **Deduplication Constraint**: Inputs targeted at `Angler.name`, `Reservoir.name`, and `Species.name` undergo case-insensitive validation lookups in the active `ModelContext` before execution writes commit to storage.

### CloudKit Operational Compatibility
- Every multi-entity relationship declares an explicit inverse macro: `@Relationship(inverse: ...)` to prevent cloud serialization failures during native, automated mirroring.
- Properties populated post-initialization utilize optional structural primitives or enforce default fallback constraints within the class constructor.