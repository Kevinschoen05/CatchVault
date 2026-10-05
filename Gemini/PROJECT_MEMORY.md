# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData[cite: 7, 10, 28].
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, background active session timers, local/push notifications)[cite: 7, 10, 28].
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 7, 10].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 7, 10, 29].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 7, 10]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 6, 7, 10].
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports[cite: 6, 7, 10, 20].
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` (`backgroundMain`, `surfaceCard`, `surfaceSecondary`, `surfaceTertiary`, `brandPrimary`, `brandAccent`, `statusActive`)[cite: 4, 6, 10].
  - Structural typography tokens encapsulated via `Typography.swift` and `.cvFont()`[cite: 2, 6, 10].
  - Layer 1 container primitive implemented via `CVCardContainer.swift`[cite: 2, 6, 10].
  - Universal Canvas Rule: All screens standardize on `Color.backgroundMain` as Layer 0 base canvas backdrop[cite: 2, 5, 6].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, 44pt minimum touch targets, and full modal/fullScreenCover transition to active trips[cite: 2, 6, 10, 35].
  - `ReservoirDetailsView.swift`: Detailed view displaying aggregate metrics (trips, catches, weight), a CatchMap placeholder for spatial data, year-filtered trip cards, and angler lists[cite: 2, 6, 10, 39].
  - `StartTripView.swift`: Configuration sheet for launching trips. Enforces explicit insertion into `modelContext` *before* assigning anglers relationships to prevent SwiftData relationship serialization drops[cite: 3, 7].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time active trip workspace featuring an absolute clock delta timer (`Date().timeIntervalSince(trip.startTime)`), lifecycle-resilient stopwatch mechanics, live catch timeline, telemetry summary cards, and dynamic angler roster formatting[cite: 1, 5, 25].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 6, 8, 10].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 6, 10].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 7, 10].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 10, 15, 29].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 6, 10, 34].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 8, 17, 18].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 18, 22].
8. MARKETING_STRATEGY.md: Position strategy, heritage outdoor branding voice, and audience targeting[cite: 26].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 6, 10]. Models, relationships, inverse annotations, and unit tests verified[cite: 6, 10, 24].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 6, 10]. Legacy JSON polymorphic decoders, trip aggregation, and ACL migration engine verified[cite: 6, 10, 20].
- Milestone 3 (Presentation Core & Infrastructure Bedrock):
  - Completed: Design Tokens (`Colors.swift`, `Typography.swift`)[cite: 2, 6, 10], Container (`CVCardContainer.swift`)[cite: 2, 6, 10], `ReservoirHome.swift`[cite: 2, 6, 10], `ReservoirDetailsView.swift`[cite: 2, 6, 10].
  - Deferred: Infrastructure proxies (`LocationService.swift`, `WeatherService.swift`)[cite: 6, 14, 17].
- Milestone 4 (Live Operational Workflows): In Progress.
  - Completed: `ActiveTripViewModel.swift` (Step 4.1)[cite: 1, 17, 25], `StartTripView.swift` (Step 4.2)[cite: 3, 17, 30], `ActiveTripView.swift` (Step 4.3)[cite: 1, 5, 17].
  - Pending: `RecordFishView.swift` (Step 4.4)[cite: 1, 5, 17], `EndTripView.swift` (Step 4.5)[cite: 1, 5, 17].
- Milestone 5 (Analytical Dashboards): Pending[cite: 8, 10, 17].

## 5. Key Architecture & Design Learnings

- SwiftData Relationship Ingestion Rule: When creating models with collection relationships (e.g., `Trip.anglers`), always `modelContext.insert(newTrip)` *before* assigning `newTrip.anglers = Array(...)`[cite: 3]. Assigning relationships prior to insertion can cause SwiftData's macro pipeline to omit relational graph attachments upon `modelContext.save()`[cite: 3].
- Palette Token Mapping:
  - `backgroundMain`: Layer 0 Base Canvas (#10222D)[cite: 2, 6].
  - `surfaceCard`: Layer 1 Card Containers (Warm Sand #EADEC9 / #EFE5D3)[cite: 4, 6].
  - `surfaceSecondary`: Secondary Action Controls (Vintage Slate Blue #2A4356)[cite: 6].
  - `brandAccent`: Primary Tactical CTAs (Beacon Amber #D97706 / #F59E0B)[cite: 6].
  - `statusActive`: Live Status Indicators (Emerald #16A34A / #10B981)[cite: 2, 6].