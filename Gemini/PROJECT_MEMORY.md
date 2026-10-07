# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData[cite: 1, 10].
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, background active session timers, local/push notifications)[cite: 1, 10].
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 1, 10].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 1, 10].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 1, 10]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 1, 6, 10].
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports[cite: 1, 6, 10].
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` (`backgroundMain`, `surfaceCard`, `surfaceSecondary`, `surfaceTertiary`, `brandPrimary`, `brandAccent`, `statusActive`)[cite: 1, 4, 6].
  - Structural typography tokens encapsulated via `Typography.swift` and `.cvFont()`[cite: 1, 2, 6].
  - Layer 1 container primitive implemented via `CVCardContainer.swift`[cite: 1, 2, 6].
  - Universal Canvas Rule: All screens standardize on `Color.backgroundMain` as Layer 0 base canvas backdrop[cite: 1, 2, 6].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, 44pt minimum touch targets, and full modal/fullScreenCover transition to active trips[cite: 1, 2, 6].
  - `ReservoirDetailsView.swift`: Detailed view displaying aggregate metrics (trips, catches, weight), a CatchMap placeholder for spatial data, year-filtered trip cards, and angler lists[cite: 1, 2, 6].
  - `StartTripView.swift`: Configuration sheet for launching trips. Enforces explicit insertion into `modelContext` *before* assigning anglers relationships to prevent SwiftData relationship serialization drops[cite: 1, 3, 7].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time active trip workspace featuring an absolute clock delta timer (`Date().timeIntervalSince(trip.startTime)`), lifecycle-resilient stopwatch mechanics, live catch timeline, telemetry summary cards, and dynamic angler roster formatting[cite: 1, 5].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Real-time catch logging modal featuring roster-scoped angler selection, inline species search with deduplication guardrails (whitespace trimming, 2-character minimum, case-insensitive check), native `CLLocationManager` GPS snapshot capture, sandboxed local photo attachment, and styled using `CVCardContainer` cards over `Color.backgroundMain`[cite: 1, 4].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal summary sheet and state locking workspace. Displays final duration readout (`HH:mm:ss`), aggregate session catches/weights, species breakdown list, multiline session observation editor (`tripNotes`), and executes atomic state locking (`trip.endTime = Date()`) via `modelContext.save()`[cite: 1, 4].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 1, 6, 8].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 1, 6].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 1, 7].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 1, 10, 15].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 1, 6, 10].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 1, 8, 17].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 1, 18, 22].
8. MARKETING_STRATEGY.md: Position strategy, heritage outdoor branding voice, and audience targeting[cite: 1, 26].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 1, 6]. Models, relationships, inverse annotations, and unit tests verified[cite: 1, 6].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 1, 6]. Legacy JSON polymorphic decoders, trip aggregation, and ACL migration engine verified[cite: 1, 6].
- Milestone 3 (Presentation Core & Infrastructure Bedrock):
  - Completed: Design Tokens (`Colors.swift`, `Typography.swift`)[cite: 1, 2, 6], Container (`CVCardContainer.swift`)[cite: 1, 2, 6], `ReservoirHome.swift`[cite: 1, 2, 6], `ReservoirDetailsView.swift`[cite: 1, 2, 6].
  - Deferred: Infrastructure proxies (`LocationService.swift`, `WeatherService.swift`)[cite: 1, 6, 14].
- Milestone 4 (Live Operational Workflows): Completed.
  - Completed: `ActiveTripViewModel.swift` (Step 4.1)[cite: 1, 17], `StartTripView.swift` (Step 4.2)[cite: 1, 3], `ActiveTripView.swift` (Step 4.3)[cite: 1, 5], `RecordFishView.swift` (Step 4.4)[cite: 1, 4], `EndTripView.swift` (Step 4.5)[cite: 1, 4].
- Milestone 5 (Analytical Dashboards): In Progress[cite: 1, 2].

## 5. Key Architecture & Design Learnings

- SwiftData Relationship Ingestion Rule: When creating models with collection relationships (e.g., `Trip.anglers`), always `modelContext.insert(newTrip)` *before* assigning `newTrip.anglers = Array(...)`[cite: 1, 3]. Assigning relationships prior to insertion can cause SwiftData's macro pipeline to omit relational graph attachments upon `modelContext.save()`[cite: 1, 3].
- Session Finalization Protocol: Transitioning a live session (`endTime == nil`) to a historical log requires explicitly stamping `trip.endTime = Date()`, trimming optional notes, and committing `modelContext.save()`[cite: 1, 4]. Clearing the unclosed session state automatically prevents cold boot auto-restoration back into `ActiveTripView`[cite: 1, 15].