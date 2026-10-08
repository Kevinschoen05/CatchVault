# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData[cite: 11, 12, 17].
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, background active session timers, local/push notifications)[cite: 11, 12, 17].
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 11, 12, 17].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 11, 12, 17].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 11, 12, 17]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 11, 12, 17].
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports[cite: 11, 12, 17].
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` (`backgroundMain`, `surfaceCard`, `surfaceSecondary`, `surfaceTertiary`, `brandPrimary`, `brandAccent`, `statusActive`)[cite: 11, 12, 17].
  - Structural typography tokens encapsulated via `Typography.swift` and `.cvFont()`[cite: 11, 12, 17].
  - Layer 1 container primitive implemented via `CVCardContainer.swift`[cite: 11, 12, 17].
  - Universal Canvas Rule: All screens standardize on `Color.backgroundMain` as Layer 0 base canvas backdrop[cite: 11, 12, 17].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, 44pt minimum touch targets, toolbar link to `AnalyticsDashboardView`, and full modal/fullScreenCover transition to active trips[cite: 11, 12, 17].
  - `ReservoirDetailsView.swift`: Detailed view displaying aggregate metrics (trips, catches, weight), spatial CatchMap placeholder, year-filtered trip cards, angler lists, and direct value-based navigation routing to `TripDetailsView`[cite: 11, 12, 23].
  - `TripDetailsView.swift` & `TripCatchMapView.swift`: Post-trip summary view detailing session metrics, interactive MapKit spatial catch map (`TripCatchMapView`) rendering landing annotations with custom info callouts, weather snapshot cards, chronological catch log timeline, and read-only observation commentary (`trip.notes`)[cite: 26].
  - `StartTripView.swift`: Configuration sheet for launching trips. Enforces explicit insertion into `modelContext` *before* assigning anglers relationships to prevent SwiftData relationship serialization drops[cite: 11, 12, 17].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time active trip workspace featuring an absolute clock delta timer (`Date().timeIntervalSince(trip.startTime)`), lifecycle-resilient stopwatch mechanics, live catch timeline, telemetry summary cards, and dynamic angler roster formatting[cite: 11, 12, 17].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Real-time catch logging modal featuring roster-scoped angler selection, inline species search with deduplication guardrails (whitespace trimming, 2-character minimum, case-insensitive check), native `CLLocationManager` GPS snapshot capture, sandboxed local photo attachment, and styled using `CVCardContainer` cards over `Color.backgroundMain`[cite: 11, 12, 17].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal summary sheet and state locking workspace. Displays final duration readout (`HH:mm:ss`), aggregate session catches/weights, species breakdown list, multiline session observation editor (`tripNotes`), and executes atomic state locking (`trip.endTime = Date()`) via `modelContext.save()`[cite: 11, 12, 17].
  - `AnalyticsDashboardView.swift`: Diagnostic dashboard root providing dynamic master temporal filtering (`CVYearPicker`), live total fish, total trips, and total mass telemetry summary cards, and navigation entry tiles leading to individual analytical breakdown views[cite: 11, 12, 17].
  - `AnglerTotalsView.swift`: High-density diagnostic ledger evaluating angler statistics. Displays total catches, total mass (lbs), total trips, catch avg/trip, mean weight per fish, zero-fish trip participation tally, and species frequency breakdown with zero-count species omission[cite: 11, 12, 17].
  - `ReservoirLeaderboardView.swift`: Ranked top-10 tabular ledger detailing the heaviest fish landed per reservoir boundary with rank indicators, angler, species, weight (lbs), and catch year[cite: 11, 12, 17].
  - `SpeciesBreakdownView.swift`: Volumetric and spatial breakdown view visualizing landed species volumes across reservoirs using native Swift Charts `BarMark` components inside `CVCardContainer` cards[cite: 11, 12, 17].
  - `CatchTrendsView.swift`: Prompt-driven 12-month temporal density chart analyzing seasonal catch distribution per species using native Swift Charts `BarMark` bars, master year filtering, and monthly landing tallies[cite: 11, 12, 17].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 11, 12, 17].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 11, 12, 17].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 11, 12, 17].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 11, 12, 17].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 11, 12, 17].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 11, 12, 17].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 11, 12, 17].
8. ENHANCEMENT_LIST.md: Backlog ledger tracking post-baseline utilities, spatial enhancements, data quality refinements, and deferred infrastructure features[cite: 4, 26].
9. MARKETING_STRATEGY.md: Position strategy, heritage outdoor branding voice, and audience targeting[cite: 11, 12, 34].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 11, 12, 17]. Models, relationships, inverse annotations, and unit tests verified[cite: 11, 12, 17].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 11, 12, 17]. Legacy JSON polymorphic decoders, trip aggregation, and ACL migration engine verified[cite: 11, 12, 17].
- Milestone 3 (Presentation Core & Infrastructure Bedrock):
  - Completed: Design Tokens (`Colors.swift`, `Typography.swift`)[cite: 11, 12, 17], Container (`CVCardContainer.swift`)[cite: 11, 12, 17], `ReservoirHome.swift`[cite: 11, 12, 17], `ReservoirDetailsView.swift`[cite: 11, 12, 23], `TripDetailsView.swift`[cite: 26].
  - In Progress: `TripCatchMapView.swift` MapKit integration.
  - Deferred: Infrastructure proxies (`LocationService.swift`, `WeatherService.swift`)[cite: 11, 12, 17].
- Milestone 4 (Live Operational Workflows): Completed[cite: 11, 12, 17].
  - Completed: `ActiveTripViewModel.swift` (Step 4.1)[cite: 11, 12, 17], `StartTripView.swift` (Step 4.2)[cite: 11, 12, 17], `ActiveTripView.swift` (Step 4.3)[cite: 11, 12, 17], `RecordFishView.swift` (Step 4.4)[cite: 11, 12, 17], `EndTripView.swift` (Step 4.5)[cite: 11, 12, 17].
- Milestone 5 (Analytical Dashboards): Completed[cite: 11, 12, 17].
  - Completed: `AnalyticsDashboardView.swift` (Step 5.1)[cite: 11, 12, 17], `AnglerTotalsView.swift` (Step 5.2)[cite: 11, 12, 17], `ReservoirLeaderboardView.swift` (Step 5.3)[cite: 11, 12, 17], `SpeciesBreakdownView.swift` (Step 5.4)[cite: 11, 12, 17], `CatchTrendsView.swift` (Step 5.4)[cite: 11, 12, 17].

## 5. Key Architecture & Design Learnings

- MapKit Region Calculation Strategy: Dynamic MapKit bounding boxes require calculating coordinate min/max latitude and longitude spans across target catch arrays to automatically center and fit map annotations cleanly within 180pt card frames.
- Post-Baseline Enhancements: Native spatial rendering and backlog tasks are tracked in `ENHANCEMENT_LIST.md` to prevent core roadmap drift while continuing incremental UX refinements[cite: 4, 26].