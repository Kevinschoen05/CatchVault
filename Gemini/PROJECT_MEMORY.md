# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData[cite: 25].
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, background active session timers, local/push notifications)[cite: 25].
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 25].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 25].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 25]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 25].
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports[cite: 25].
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` (`backgroundMain`, `surfaceCard`, `surfaceSecondary`, `surfaceTertiary`, `brandPrimary`, `brandAccent`, `statusActive`)[cite: 25].
  - Structural typography tokens encapsulated via `Typography.swift` and `.cvFont()`[cite: 25].
  - Layer 1 container primitive implemented via `CVCardContainer.swift`[cite: 25].
  - Universal Canvas Rule: All screens standardize on `Color.backgroundMain` as Layer 0 base canvas backdrop[cite: 25].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, 44pt minimum touch targets, and full modal/fullScreenCover transition to active trips[cite: 25].
  - `ReservoirDetailsView.swift`: Detailed view displaying aggregate metrics (trips, catches, weight), a CatchMap placeholder for spatial data, year-filtered trip cards, and angler lists[cite: 25].
  - `StartTripView.swift`: Configuration sheet for launching trips. Enforces explicit insertion into `modelContext` *before* assigning anglers relationships to prevent SwiftData relationship serialization drops[cite: 25].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time active trip workspace featuring an absolute clock delta timer (`Date().timeIntervalSince(trip.startTime)`), lifecycle-resilient stopwatch mechanics, live catch timeline, telemetry summary cards, and dynamic angler roster formatting[cite: 25].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Real-time catch logging modal featuring roster-scoped angler selection, inline species search with deduplication guardrails (whitespace trimming, 2-character minimum, case-insensitive check), native `CLLocationManager` GPS snapshot capture, sandboxed local photo attachment, and styled using `CVCardContainer` cards over `Color.backgroundMain`[cite: 25].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 25].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 25].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 25].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 25].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 25].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 25].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 25].
8. MARKETING_STRATEGY.md: Position strategy, heritage outdoor branding voice, and audience targeting[cite: 25].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 25]. Models, relationships, inverse annotations, and unit tests verified[cite: 25].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 25]. Legacy JSON polymorphic decoders, trip aggregation, and ACL migration engine verified[cite: 25].
- Milestone 3 (Presentation Core & Infrastructure Bedrock):
  - Completed: Design Tokens (`Colors.swift`, `Typography.swift`)[cite: 25], Container (`CVCardContainer.swift`)[cite: 25], `ReservoirHome.swift`[cite: 25], `ReservoirDetailsView.swift`[cite: 25].
  - Deferred: Infrastructure proxies (`LocationService.swift`, `WeatherService.swift`)[cite: 25].
- Milestone 4 (Live Operational Workflows): In Progress.
  - Completed: `ActiveTripViewModel.swift` (Step 4.1)[cite: 25], `StartTripView.swift` (Step 4.2)[cite: 25], `ActiveTripView.swift` (Step 4.3)[cite: 25], `RecordFishView.swift` (Step 4.4)[cite: 25].
  - Pending: `EndTripView.swift` (Step 4.5).
- Milestone 5 (Analytical Dashboards): Pending[cite: 25].

## 5. Key Architecture & Design Learnings

- SwiftData Relationship Ingestion Rule: When creating models with collection relationships (e.g., `Trip.anglers`), always `modelContext.insert(newTrip)` *before* assigning `newTrip.anglers = Array(...)`[cite: 25]. Assigning relationships prior to insertion can cause SwiftData's macro pipeline to omit relational graph attachments upon `modelContext.save()`[cite: 25].
- CoreLocation Hardware Integration: Direct usage of `CLLocationManager` inside view models provides straightforward snapshot access to user coordinates upon catch landing without requiring third-party wrappers[cite: 25].
- Palette Token Mapping:
  - `backgroundMain`: Layer 0 Base Canvas (#10222D)[cite: 25].
  - `surfaceCard`: Layer 1 Card Containers (Warm Sand #EADEC9 / #EFE5D3)[cite: 25].
  - `surfaceSecondary`: Secondary Action Controls (Vintage Slate Blue #2A4356)[cite: 25].
  - `brandAccent`: Primary Tactical CTAs (Beacon Amber #D97706 / #F59E0B)[cite: 25].
  - `statusActive`: Live Status Indicators (Emerald #16A34A / #10B981)[cite: 25].