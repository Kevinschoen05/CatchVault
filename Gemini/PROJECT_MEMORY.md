# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData.
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, WeatherKit, background active session timers).
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 11, 12].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 11, 12].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 11, 12]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 11, 12].
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports[cite: 11, 12].
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` (`backgroundMain`, `surfaceCard`, `surfaceSecondary`, `surfaceTertiary`, `brandPrimary`, `brandAccent`, `statusActive`)[cite: 11, 12].
  - Structural typography tokens encapsulated via `Typography.swift` and `.cvFont()`[cite: 11, 12].
  - Layer 1 container primitive implemented via `CVCardContainer.swift`[cite: 11, 12].
  - Universal Canvas Rule: All screens standardize on `Color.backgroundMain` as Layer 0 base canvas backdrop[cite: 11, 12].
- Infrastructure Services & Hardware Proxies Completed:
  - `LocationService.swift`: CoreLocation hardware proxy with re-entrancy protection, checked continuation guards, relaxed simulator accuracy thresholds (<= 100m), and single-flight task locking[cite: 11].
  - `WeatherService.swift`: WeatherKit serialization framework with fallback error handling (`WeatherDaemon error 2` / JWT auth checks) ensuring zero application crashes when off-grid or without an active Developer Program profile.
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, 44pt minimum touch targets, toolbar link to `AnalyticsDashboardView`, and modal transitions[cite: 11, 12].
  - `ReservoirDetailsView.swift`: Detailed view displaying aggregate metrics, MapKit spatial catch maps, year-filtered trip cards, angler lists, and direct navigation routing to `TripDetailsView`[cite: 11, 12].
  - `TripDetailsView.swift` & `TripCatchMapView.swift`: Post-trip summary view detailing session metrics, interactive MapKit spatial catch map, weather snapshot cards, chronological catch log timeline, and read-only observation commentary (`trip.notes`)[cite: 11, 12].
  - `StartTripView.swift`: Configuration sheet for launching trips with explicit pre-insertion into `modelContext` to protect relational integrity[cite: 11, 12].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time active trip workspace featuring an absolute clock delta timer, live catch timeline, and telemetry summary cards[cite: 11, 12].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Real-time catch logging modal featuring roster-scoped angler selection, inline species search with deduplication, automatic native `LocationService` GPS coordinate capture, and sandboxed photo attachments[cite: 11, 12].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal summary sheet and state locking workspace displaying final duration readout (`HH:mm:ss`), species breakdown, session commentary editor, and atomic state locking (`trip.endTime = Date()`)[cite: 11, 12].
  - `AnalyticsDashboardView.swift`: Diagnostic dashboard root with master temporal filtering (`CVYearPicker`) and live telemetry cards[cite: 11, 12].
  - `AnglerTotalsView.swift`: Diagnostic ledger evaluating angler statistics, zero-fish trip participation tallies, and species frequency breakdowns[cite: 11, 12].
  - `ReservoirLeaderboardView.swift`: Ranked top-10 tabular ledger detailing the heaviest fish landed per reservoir boundary[cite: 11, 12].
  - `SpeciesBreakdownView.swift`: Volumetric and spatial breakdown view visualizing landed species volumes across reservoirs using native Swift Charts `BarMark` components[cite: 11, 12].
  - `CatchTrendsView.swift`: Prompt-driven 12-month temporal density chart analyzing seasonal catch distribution per species[cite: 11, 12].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 11, 12].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 11, 12].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 11, 12].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 11, 12].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 11, 12].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 11, 12].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 11, 12].
8. ENHANCEMENT_LIST.md: Backlog ledger tracking post-baseline utilities, data quality refinements, and deferred features[cite: 11, 12].
9. MARKETING_STRATEGY.md: Positioning strategy, heritage outdoor branding voice, and audience targeting[cite: 11, 12].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 11, 12].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 11, 12].
- Milestone 3 (Presentation Core & Infrastructure Bedrock): Completed[cite: 11, 12].
  - Completed: Design Tokens, Container Primitives, `ReservoirHome.swift`, `ReservoirDetailsView.swift`, `TripDetailsView.swift`, `TripCatchMapView.swift`, `LocationService.swift` CoreLocation Proxy, `WeatherService.swift` WeatherKit Proxy[cite: 11, 12].
- Milestone 4 (Live Operational Workflows): Completed[cite: 11, 12].
  - Completed: `ActiveTripViewModel.swift`, `StartTripView.swift`, `ActiveTripView.swift`, `RecordFishView.swift`, `EndTripView.swift`[cite: 11, 12].
- Milestone 5 (Analytical Dashboards): Completed[cite: 11, 12].
  - Completed: `AnalyticsDashboardView.swift`, `AnglerTotalsView.swift`, `ReservoirLeaderboardView.swift`, `SpeciesBreakdownView.swift`, `CatchTrendsView.swift`[cite: 11, 12].

## 5. Key Architecture & Design Learnings

- Single-Flight Concurrency: Guarding hardware tasks (like CoreLocation) behind an active `Task<T, Error>` joined by re-entrant callers prevents continuation leaks and duplicate hardware requests[cite: 11].
- WeatherKit Authorization Scoping: Free Apple Developer accounts do not emit WeatherDaemon JWT authorization tokens in Simulator environments, returning `error 2`. Gracefully catching these exceptions to return `nil` allows off-grid or un-enrolled development without blocking local database persistence.