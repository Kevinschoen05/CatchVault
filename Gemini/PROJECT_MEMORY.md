# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData[cite: 15, 16].
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, WeatherKit, background active session timers)[cite: 15, 16].
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 15, 16].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 15, 16].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 15, 16]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 15, 16].
- Ingestion Layer: Anti-Corruption Bridge (`MigrationManager.swift`) completed for single-use legacy data imports[cite: 15, 16].
- Core Design System (Milestone 3):
  - Semantic design tokens defined in `Colors.swift` (`backgroundMain`, `surfaceCard`, `surfaceSecondary`, `surfaceTertiary`, `brandPrimary`, `brandAccent`, `statusActive`)[cite: 15, 16].
  - Structural typography tokens encapsulated via `Typography.swift` and `.cvFont()`[cite: 15, 16].
  - Layer 1 container primitive implemented via `CVCardContainer.swift`[cite: 15, 16].
  - Universal Canvas Rule: All screens standardize on `Color.backgroundMain` as Layer 0 base canvas backdrop[cite: 15, 16].
- Presentation Views & Components Completed:
  - `ReservoirHome.swift`: Main dashboard supporting global year filtering, summary telemetry cards, empty states, value-based navigation, 44pt minimum touch targets, toolbar link to `AnalyticsDashboardView`, and modal transitions[cite: 16, 22].
  - `ReservoirDetailsView.swift`: Detailed view displaying aggregate metrics, interactive MapKit catch maps, year-filtered trip cards, angler lists, and programmatic value-based navigation routing to `TripDetailsView`[cite: 2, 16, 22].
  - `FullScreenMapView.swift`: Modal full-screen interactive MapKit canvas featuring custom floating callout popovers, species color-coded markers, style toggles, auto-recenter controls, memory flushing teardown, and direct navigation handoff to `TripDetailsView`[cite: 1].
  - `TripDetailsView.swift` & `TripCatchMapView.swift`: Post-trip summary view detailing session metrics, interactive MapKit spatial catch map, weather snapshot cards, chronological catch log timeline, and read-only observation commentary[cite: 16, 22].
  - `StartTripView.swift`: Configuration sheet for launching trips with explicit pre-insertion into `modelContext` to protect relational integrity[cite: 15, 16].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time active trip workspace featuring an absolute clock delta timer, live catch timeline, telemetry summary cards, and Discard Trip action[cite: 14, 16].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Real-time catch logging modal featuring roster-scoped angler selection, inline species search with deduplication, automatic native `LocationService` GPS coordinate capture, and sandboxed photo attachments[cite: 16, 22].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal summary sheet and state locking workspace displaying final duration readout, species breakdown, session commentary editor, and atomic state locking[cite: 16, 22].
  - `AnalyticsDashboardView.swift`, `AnglerTotalsView.swift`, `ReservoirLeaderboardView.swift`, `SpeciesBreakdownView.swift`, `CatchTrendsView.swift`: Complete diagnostic dashboard suite[cite: 16, 22].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 14, 15].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 14, 15].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 14, 15].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 14, 15].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 14, 15].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 14, 15].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 11, 14].
8. ENHANCEMENT_LIST.md: Backlog ledger tracking post-baseline utilities, data quality refinements, and deferred features.
9. MARKETING_STRATEGY.md: Positioning strategy, heritage outdoor branding voice, and audience targeting[cite: 14, 15].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 14, 15].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 14, 15].
- Milestone 3 (Presentation Core & Infrastructure Bedrock): Completed[cite: 14, 15].
- Milestone 4 (Live Operational Workflows): Completed[cite: 14, 15].
- Milestone 5 (Analytical Dashboards): Completed[cite: 14, 15].
- Milestone 6 (MTP & Release Deployment): In Progress[cite: 14, 15].

## 5. Key Architecture & Design Learnings

- Modal Dismissal Navigation Handoff: When initiating root `NavigationStack` pushes from inside presented full-screen covers, dismiss the modal first via `@Environment(\.dismiss)`, then trigger the parent view's state update or path append after a minimal delay (e.g., 0.3s) to prevent SwiftUI modal presentation collisions[cite: 1, 2].
- Explicit Memory Lifecycle Protection: MapKit views retain Metal context textures in memory. Always reset selected entity IDs (`selectedCatchID = nil`), remove local collections (`mappedCatches.removeAll()`), and reset camera positions in `.onDisappear`[cite: 1].