# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData.
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, background active session timers, local/push notifications).
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 6].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 6].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 6]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 6].
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports[cite: 6].
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` (`backgroundMain`, `surfaceCard`, `surfaceSecondary`, `surfaceTertiary`, `brandPrimary`, `brandAccent`, `statusActive`)[cite: 6].
  - Structural typography tokens encapsulated via `Typography.swift` and `.cvFont()`[cite: 6].
  - Layer 1 container primitive implemented via `CVCardContainer.swift`[cite: 6].
  - Universal Canvas Rule: All screens standardize on `Color.backgroundMain` as Layer 0 base canvas backdrop[cite: 6].
- Infrastructure Services & Hardware Proxies Completed:
  - `LocationService.swift`: Native CoreLocation hardware proxy managing authorization state checks, `kCLLocationAccuracyBest` off-grid satellite tracking streams, 15-second fallback timeout, simulator relaxation checks (`#if targetEnvironment(simulator)`), and async single-resume continuation guards[cite: 6].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, 44pt minimum touch targets, toolbar link to `AnalyticsDashboardView`, and full modal/fullScreenCover transition to active trips[cite: 6].
  - `ReservoirDetailsView.swift`: Detailed view displaying aggregate metrics (trips, catches, weight), interactive MapKit spatial catch map rendering year-filtered pins with species color coding, year-filtered trip cards, angler lists, and direct value-based navigation routing to `TripDetailsView`[cite: 6, 22].
  - `TripDetailsView.swift` & `TripCatchMapView.swift`: Post-trip summary view detailing session metrics, interactive MapKit spatial catch map (`TripCatchMapView`) rendering landing annotations with custom info callouts, weather snapshot cards, chronological catch log timeline, and read-only observation commentary (`trip.notes`).
  - `StartTripView.swift`: Configuration sheet for launching trips. Enforces explicit insertion into `modelContext` *before* assigning anglers relationships to prevent SwiftData relationship serialization drops[cite: 6].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time active trip workspace featuring an absolute clock delta timer (`Date().timeIntervalSince(trip.startTime)`), lifecycle-resilient stopwatch mechanics, live catch timeline, telemetry summary cards, and dynamic angler roster formatting[cite: 6].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Real-time catch logging modal featuring roster-scoped angler selection, inline species search with deduplication guardrails (whitespace trimming, 2-character minimum, case-insensitive check), native `LocationService` GPS snapshot capture, sandboxed local photo attachment, and styled using `CVCardContainer` cards over `Color.backgroundMain`[cite: 6].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal summary sheet and state locking workspace. Displays final duration readout (`HH:mm:ss`), aggregate session catches/weights, species breakdown list, multiline session observation editor (`tripNotes`), and executes atomic state locking (`trip.endTime = Date()`) via `modelContext.save()`[cite: 6].
  - `AnalyticsDashboardView.swift`: Diagnostic dashboard root providing dynamic master temporal filtering (`CVYearPicker`), live total fish, total trips, and total mass telemetry summary cards, and navigation entry tiles leading to individual analytical breakdown views[cite: 6].
  - `AnglerTotalsView.swift`: High-density diagnostic ledger evaluating angler statistics. Displays total catches, total mass (lbs), total trips, catch avg/trip, mean weight per fish, zero-fish trip participation tally, and species frequency breakdown with zero-count species omission[cite: 6].
  - `ReservoirLeaderboardView.swift`: Ranked top-10 tabular ledger detailing the heaviest fish landed per reservoir boundary with rank indicators, angler, species, weight (lbs), and catch year[cite: 6].
  - `SpeciesBreakdownView.swift`: Volumetric and spatial breakdown view visualizing landed species volumes across reservoirs using native Swift Charts `BarMark` components inside `CVCardContainer` cards[cite: 6].
  - `CatchTrendsView.swift`: Prompt-driven 12-month temporal density chart analyzing seasonal catch distribution per species using native Swift Charts `BarMark` bars, master year filtering, and monthly landing tallies[cite: 6].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 6].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 6].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 6].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 6].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 6].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 6].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 6].
8. ENHANCEMENT_LIST.md: Backlog ledger tracking post-baseline utilities, spatial enhancements, data quality refinements, and deferred infrastructure features.
9. MARKETING_STRATEGY.md: Position strategy, heritage outdoor branding voice, and audience targeting[cite: 6].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 6]. Models, relationships, inverse annotations, and unit tests verified[cite: 6].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 6]. Legacy JSON polymorphic decoders, trip aggregation, and ACL migration engine verified[cite: 6].
- Milestone 3 (Presentation Core & Infrastructure Bedrock): Completed[cite: 6].
  - Completed: Design Tokens (`Colors.swift`, `Typography.swift`)[cite: 6], Container (`CVCardContainer.swift`)[cite: 6], `ReservoirHome.swift`[cite: 6], `ReservoirDetailsView.swift`[cite: 6], `TripDetailsView.swift`[cite: 12], `TripCatchMapView.swift` MapKit integration[cite: 12], `LocationService.swift` CoreLocation Proxy[cite: 6].
  - Deferred: `WeatherService.swift`.
- Milestone 4 (Live Operational Workflows): Completed[cite: 6].
  - Completed: `ActiveTripViewModel.swift` (Step 4.1)[cite: 6], `StartTripView.swift` (Step 4.2)[cite: 6], `ActiveTripView.swift` (Step 4.3)[cite: 6], `RecordFishView.swift` (Step 4.4)[cite: 6], `EndTripView.swift` (Step 4.5)[cite: 6].
- Milestone 5 (Analytical Dashboards): Completed[cite: 6].
  - Completed: `AnalyticsDashboardView.swift` (Step 5.1)[cite: 6], `AnglerTotalsView.swift` (Step 5.2)[cite: 6], `ReservoirLeaderboardView.swift` (Step 5.3)[cite: 6], `SpeciesBreakdownView.swift` (Step 5.4)[cite: 6], `CatchTrendsView.swift` (Step 5.4)[cite: 6].

## 5. Key Architecture & Design Learnings

- CoreLocation Continuation Safety: In Swift Concurrency, wrapping `CLLocationManagerDelegate` callbacks inside `withCheckedThrowingContinuation` requires strict single-resume enforcement to prevent continuation leaks and task hanging[cite: 6].
- Authorization Interception: Invoking location requests prior to handling `authorizationStatus == .notDetermined` or omitting `NSLocationWhenInUseUsageDescription` in `Info.plist` causes iOS to suppress system permission dialogs and drop location updates[cite: 6].
- Off-Grid Satellite Acquisition: Enforcing `desiredAccuracy = kCLLocationAccuracyBest` engages the device's physical GPS chip, enabling off-grid coordinate acquisition in remote fishing spots without cell towers[cite: 6].