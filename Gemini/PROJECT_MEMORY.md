# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData[cite: 1, 25].
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, background active session timers, local/push notifications)[cite: 1, 25].
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 1, 25].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 1, 25].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 1, 25]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 1, 25].
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports[cite: 1, 25].
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` and `.cvFont()` typography helpers[cite: 1, 25].
  - Layer 1 container primitive implemented via `CVCardContainer.swift`[cite: 1, 25].
  - Universal Canvas Rule: All screens standardize on `Color.backgroundMain` as Layer 0 base canvas backdrop[cite: 1, 25].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, 44pt touch targets, and `AddReservoirView` modal[cite: 1, 20, 25].
  - `ReservoirDetailsView.swift`: Detailed view displaying aggregate metrics, interactive MapKit spatial catch map, year-filtered trip cards, and angler lists[cite: 1, 5, 25].
  - `TripDetailsView.swift`: Session overview displaying interactive MapKit spatial catch map, WeatherKit snapshot card, chronological catch timeline, and multiline notes[cite: 1, 5, 25].
  - `StartTripView.swift`: Configuration sheet for launching trips. Enforces explicit insertion into `modelContext` *before* assigning anglers relationships to prevent SwiftData relationship serialization drops[cite: 1, 25].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time active trip workspace featuring an absolute clock delta timer (`Date().timeIntervalSince(trip.startTime)`), real-time catch timeline, telemetry summary cards, and an alert-confirmed destructive **Discard Trip** cascade delete trigger[cite: 1, 25].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Catch logging sheet with roster-scoped angler pickers, inline species deduplication, native `CLLocationManager` GPS snapshot capture, and sandboxed photo attachment[cite: 1, 25].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal trip summary sheet with live WeatherKit fetching, final telemetry breakdown, trip commentary editor, and explicit **Discard Trip Without Saving** cascade delete action[cite: 1, 5, 25].
  - `AddReservoirView.swift`: Modal sheet for onboarding new bodies of water with whitespace trimming, 2-character minimum checks, and case-insensitive deduplication against existing records[cite: 1, 20].
  - **High-Density Analytics (Milestone 5)**: `AnalyticsDashboardView.swift`, `AnglerTotalsView.swift`, `ReservoirLeaderboardView.swift`, `SpeciesBreakdownView.swift`, `CatchTrendsView.swift`[cite: 1, 25].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 1, 25].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 1, 25].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 1, 25].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 1, 25].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 1, 25].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 1, 25].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 1, 25].
8. ENHANCEMENT_LIST.md: Backlog ledger tracking post-baseline enhancements and operational utilities[cite: 1, 4].
9. MARKETING_STRATEGY.md: Position strategy, heritage outdoor branding voice, and audience targeting[cite: 1, 25].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 1, 25].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 1, 25].
- Milestone 3 (Presentation Core & Infrastructure Bedrock): Completed[cite: 1, 25].
- Milestone 4 (Live Operational Workflows): Completed[cite: 1, 25].
- Milestone 5 (Analytical Dashboards): Completed[cite: 1, 25].
- Milestone 6 (MTP & Release Deployment): In Progress (App Icon, Launch Screen, WeatherKit verified, Discard Trip implemented)[cite: 1, 6, 7].

## 5. Key Architecture & Design Learnings

- SwiftData Cascade Delete Rule: Invoking `modelContext.delete(trip)` on a pre-inserted active trip triggers `@Relationship(deleteRule: .cascade)` on `Trip.catches`, purging all associated `FishCatch` entities from persistent disk storage in a single atomic transaction upon `try modelContext.save()`[cite: 1, 4].
- Palette Token Mapping:
  - `backgroundMain`: Layer 0 Base Canvas (#10222D)[cite: 1, 25].
  - `surfaceCard`: Layer 1 Card Containers (Warm Sand #EADEC9 / #EFE5D3)[cite: 1, 25].
  - `textOnCardPrimary`: High-contrast dark text inside card containers (#10222D).
  - `textOnCardSecondary`: Muted secondary text inside card containers (#3A3A3C).
  - `brandAccent`: Primary Tactical CTAs (Beacon Amber #D97706 / #F59E0B)[cite: 1, 25].
  - `statusActive`: Live Status Indicators (Emerald #16A34A / #10B981)[cite: 1, 25].