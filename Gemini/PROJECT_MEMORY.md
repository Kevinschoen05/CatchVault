# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData.
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, background active session timers, local/push notifications).
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens.
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit.

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 13].
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports[cite: 13].
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` (`backgroundMain`, `surfaceCard`, `surfaceSecondary`, `surfaceTertiary`, `brandPrimary`, `brandAccent`, `statusActive`)[cite: 13].
  - Structural typography tokens encapsulated via `Typography.swift` and `.cvFont()`[cite: 13].
  - Layer 1 container primitive implemented via `CVCardContainer.swift`[cite: 13].
  - Universal Canvas Rule: All screens standardize on `Color.backgroundMain` as Layer 0 base canvas backdrop[cite: 13].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, 44pt minimum touch targets, toolbar link to `AnalyticsDashboardView`, and full modal/fullScreenCover transition to active trips[cite: 13].
  - `ReservoirDetailsView.swift`: Detailed view displaying aggregate metrics (trips, catches, weight), a CatchMap placeholder for spatial data, year-filtered trip cards, and angler lists[cite: 13].
  - `StartTripView.swift`: Configuration sheet for launching trips. Enforces explicit insertion into `modelContext` *before* assigning anglers relationships to prevent SwiftData relationship serialization drops[cite: 13].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time active trip workspace featuring an absolute clock delta timer (`Date().timeIntervalSince(trip.startTime)`), lifecycle-resilient stopwatch mechanics, live catch timeline, telemetry summary cards, and dynamic angler roster formatting[cite: 13].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Real-time catch logging modal featuring roster-scoped angler selection, inline species search with deduplication guardrails (whitespace trimming, 2-character minimum, case-insensitive check), native `CLLocationManager` GPS snapshot capture, sandboxed local photo attachment, and styled using `CVCardContainer` cards over `Color.backgroundMain`[cite: 13].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal summary sheet and state locking workspace. Displays final duration readout (`HH:mm:ss`), aggregate session catches/weights, species breakdown list, multiline session observation editor (`tripNotes`), and executes atomic state locking (`trip.endTime = Date()`) via `modelContext.save()`[cite: 13].
  - `AnalyticsDashboardView.swift`: Diagnostic dashboard root providing dynamic master temporal filtering (`CVYearPicker`), live total fish, total trips, and total mass telemetry summary cards, and navigation entry tiles leading to individual analytical breakdown views[cite: 13].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 13].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 13].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 13].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 13].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 13].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 13].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 2, 13].
8. MARKETING_STRATEGY.md: Position strategy, heritage outdoor branding voice, and audience targeting[cite: 13].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 13]. Models, relationships, inverse annotations, and unit tests verified[cite: 13].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 13]. Legacy JSON polymorphic decoders, trip aggregation, and ACL migration engine verified[cite: 13].
- Milestone 3 (Presentation Core & Infrastructure Bedrock):
  - Completed: Design Tokens (`Colors.swift`, `Typography.swift`)[cite: 13], Container (`CVCardContainer.swift`)[cite: 13], `ReservoirHome.swift`[cite: 13], `ReservoirDetailsView.swift`[cite: 13].
  - Deferred: Infrastructure proxies (`LocationService.swift`, `WeatherService.swift`)[cite: 13].
- Milestone 4 (Live Operational Workflows): Completed[cite: 13].
  - Completed: `ActiveTripViewModel.swift` (Step 4.1)[cite: 13], `StartTripView.swift` (Step 4.2)[cite: 13], `ActiveTripView.swift` (Step 4.3)[cite: 13], `RecordFishView.swift` (Step 4.4)[cite: 13], `EndTripView.swift` (Step 4.5)[cite: 13].
- Milestone 5 (Analytical Dashboards): In Progress[cite: 13].
  - Completed: `AnalyticsDashboardView.swift` (Step 5.1)[cite: 13].
  - Pending: `AnglerTotalsView.swift` (Step 5.2)[cite: 13], `ReservoirLeaderboardView.swift` (Step 5.3)[cite: 13], `TemporalTrendsView.swift` / `SpeciesBreakdownView.swift` (Step 5.4)[cite: 13].

## 5. Key Architecture & Design Learnings

- SwiftData Direct View-Query Strategy: Read-heavy diagnostic screens execute aggregations directly against `@Query` arrays via computed view properties, eliminating ViewModel boilerplate and remaining reactive to real-time database updates[cite: 13].
- Dynamic Mass Telemetry Auto-Scaling: Applying `.lineLimit(1)` and `.minimumScaleFactor(0.75)` on fixed horizontal flex containers prevents telemetry strings from multi-line wrapping when numeric values grow large[cite: 13].
- Year String Formatting: Explicitly formatting integers via `String(format: "%d", year)` avoids Swift's default string-interpolation grouping separators (e.g., `2026` vs `2,026`)[cite: 13].