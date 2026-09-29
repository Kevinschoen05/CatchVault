# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData.
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, background active session timers, local/push notifications).
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens.
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit.

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth. Explicit `try context.save()` calls wrap mutations to enforce atomic persistence boundaries.
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports.
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` (`surfacePrimary`, `surfaceSecondary`, `surfaceTertiary`, `brandPrimary`, `brandAccent`).
  - Structural typography tokens encapsulated via `Typography.swift` and `.cvFont()`.
  - Layer 1 container primitive implemented via `CVCardContainer.swift`.
- Presentation Views Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, and 44pt minimum touch targets.
  - `ReservoirsDetailsView.swift`: Detailed view displaying aggregate metrics (trips, catches, weight), a CatchMap placeholder for spatial data, year-filtered trip cards, and angler lists.

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants.
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution.
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations.
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints.
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, and high-density view layout laws.
6. Project Structure.md: Group organization inside the Xcode workspace.

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed. Models, relationships, inverse annotations, and unit tests verified.
- Milestone 2 (Data Ingestion Pipeline): Completed. Legacy JSON polymorphic decoders, trip aggregation, and ACL migration engine verified.
- Milestone 3 (Presentation Core & Infrastructure Bedrock): In Progress.
  - Completed: Design Tokens (`Colors.swift`, `Typography.swift`), Container (`CVCardContainer.swift`), `ReservoirHome.swift`, `ReservoirDetailsView.swift`.
  - Pending: Infrastructure proxies (`LocationService.swift`, `WeatherService.swift`).
- Milestone 4 (Live Operational Workflows): Pending.
- Milestone 5 (Analytical Dashboards): Pending.