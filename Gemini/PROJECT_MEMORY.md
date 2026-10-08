# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData[cite: 1, 10, 22].
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, background active session timers, local/push notifications)[cite: 1, 10, 22].
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 1, 10, 22].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 1, 10, 22].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 1, 10, 22]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 1, 6, 10].
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports[cite: 1, 6, 10, 22].
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` (`backgroundMain`, `surfaceCard`, `surfaceSecondary`, `surfaceTertiary`, `brandPrimary`, `brandAccent`, `statusActive`)[cite: 1, 4, 6, 10, 39].
  - Structural typography tokens encapsulated via `Typography.swift` and `.cvFont()`[cite: 1, 2, 6, 10, 18].
  - Layer 1 container primitive implemented via `CVCardContainer.swift`[cite: 1, 2, 6, 10, 18].
  - Universal Canvas Rule: All screens standardize on `Color.backgroundMain` as Layer 0 base canvas backdrop[cite: 1, 2, 6, 10, 18].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, 44pt minimum touch targets, toolbar link to `AnalyticsDashboardView`, and full modal/fullScreenCover transition to active trips[cite: 1, 2, 6, 10, 22, 24].
  - `ReservoirDetailsView.swift`: Detailed view displaying aggregate metrics (trips, catches, weight), a CatchMap placeholder for spatial data, year-filtered trip cards, and angler lists[cite: 1, 2, 6, 10, 22, 29].
  - `StartTripView.swift`: Configuration sheet for launching trips. Enforces explicit insertion into `modelContext` *before* assigning anglers relationships to prevent SwiftData relationship serialization drops[cite: 1, 3, 7, 10, 38].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time active trip workspace featuring an absolute clock delta timer (`Date().timeIntervalSince(trip.startTime)`), lifecycle-resilient stopwatch mechanics, live catch timeline, telemetry summary cards, and dynamic angler roster formatting[cite: 1, 5, 10, 31].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Real-time catch logging modal featuring roster-scoped angler selection, inline species search with deduplication guardrails (whitespace trimming, 2-character minimum, case-insensitive check), native `CLLocationManager` GPS snapshot capture, sandboxed local photo attachment, and styled using `CVCardContainer` cards over `Color.backgroundMain`[cite: 1, 4, 8, 10].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal summary sheet and state locking workspace. Displays final duration readout (`HH:mm:ss`), aggregate session catches/weights, species breakdown list, multiline session observation editor (`tripNotes`), and executes atomic state locking (`trip.endTime = Date()`) via `modelContext.save()`[cite: 1, 4, 10, 14].
  - `AnalyticsDashboardView.swift`: Diagnostic dashboard root providing dynamic master temporal filtering (`CVYearPicker`), live total fish, total trips, and total mass telemetry summary cards, and navigation entry tiles leading to individual analytical breakdown views[cite: 7, 10, 11, 15, 18].
  - `AnglerTotalsView.swift`: High-density diagnostic ledger evaluating angler statistics. Displays total catches, total mass (lbs), total trips, catch avg/trip, mean weight per fish, zero-fish trip participation tally, and species frequency breakdown with zero-count species omission[cite: 4, 10, 11, 15, 18].
  - `ReservoirLeaderboardView.swift`: Ranked top-10 tabular ledger detailing the heaviest fish landed per reservoir boundary with rank indicators, angler, species, weight (lbs), and catch year[cite: 4, 11, 15, 18].
  - `SpeciesBreakdownView.swift`: Volumetric and spatial breakdown view visualizing landed species volumes across reservoirs using native Swift Charts `BarMark` components inside `CVCardContainer` cards[cite: 4, 11, 15, 18].
  - `CatchTrendsView.swift`: Prompt-driven 12-month temporal density chart analyzing seasonal catch distribution per species using native Swift Charts `BarMark` bars, master year filtering, and monthly landing tallies[cite: 11, 12, 18, 43].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 1, 4, 6, 8].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 1, 4, 6].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 1, 4, 7].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 1, 4, 10, 17].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 1, 4, 6, 10, 35].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 1, 4, 8, 28].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 1, 4, 20, 26].
8. MARKETING_STRATEGY.md: Position strategy, heritage outdoor branding voice, and audience targeting[cite: 1, 4, 20].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 1, 4, 6]. Models, relationships, inverse annotations, and unit tests verified[cite: 1, 4, 6, 27].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 1, 4, 6]. Legacy JSON polymorphic decoders, trip aggregation, and ACL migration engine verified[cite: 1, 4, 6, 22].
- Milestone 3 (Presentation Core & Infrastructure Bedrock):
  - Completed: Design Tokens (`Colors.swift`, `Typography.swift`)[cite: 1, 2, 4, 6], Container (`CVCardContainer.swift`)[cite: 1, 2, 4, 6], `ReservoirHome.swift`[cite: 1, 2, 4, 6], `ReservoirDetailsView.swift`[cite: 1, 2, 4, 6].
  - Deferred: Infrastructure proxies (`LocationService.swift`, `WeatherService.swift`)[cite: 1, 4, 6, 18, 19].
- Milestone 4 (Live Operational Workflows): Completed[cite: 1, 2, 4, 14].
  - Completed: `ActiveTripViewModel.swift` (Step 4.1)[cite: 1, 4, 18, 31], `StartTripView.swift` (Step 4.2)[cite: 1, 3, 4, 18], `ActiveTripView.swift` (Step 4.3)[cite: 1, 4, 5, 18], `RecordFishView.swift` (Step 4.4)[cite: 1, 4, 8, 18], `EndTripView.swift` (Step 4.5)[cite: 1, 4, 14, 18].
- Milestone 5 (Analytical Dashboards): Completed[cite: 11, 12, 18].
  - Completed: `AnalyticsDashboardView.swift` (Step 5.1)[cite: 7, 11, 15, 18], `AnglerTotalsView.swift` (Step 5.2)[cite: 4, 11, 15, 18], `ReservoirLeaderboardView.swift` (Step 5.3)[cite: 4, 11, 15, 18], `SpeciesBreakdownView.swift` (Step 5.4)[cite: 4, 11, 15, 18], `CatchTrendsView.swift` (Step 5.4)[cite: 11, 12, 18].

## 5. Key Architecture & Design Learnings

- Swift Charts Modifier Ordering: Applying `.cornerRadii(...)` directly to `BarMark` before type-erasing modifiers (such as `.foregroundStyle(...)`) prevents compiler diagnostics[cite: 11].
- SwiftData Direct View-Query Strategy: Read-heavy diagnostic screens execute aggregations directly against `@Query` arrays via computed view properties, eliminating ViewModel boilerplate while staying reactive to database mutations[cite: 4, 11, 18, 34].
- Calendar Month Aggregations: Evaluating temporal trends using `Calendar.current.component(.month, from: catch.timestamp)` provides deterministic 1-to-12 monthly bucket mapping across year filters[cite: 43].