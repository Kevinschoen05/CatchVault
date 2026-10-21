# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData[cite: 23, 29].
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, WeatherKit, background active session timers)[cite: 22, 23].
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 23, 34].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 23].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 23]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 23].
- Hardware & Service Proxies:
  - `LocationService.swift`: Native CoreLocation proxy supporting single-flight concurrency, high-accuracy GPS locks, and simulator relaxation[cite: 21].
  - `WeatherService.swift`: Native Apple WeatherKit service proxy with non-blocking error handling, live WeatherDaemon JWT authentication, and automatic unit conversion (°F / mph / inches)[cite: 19, 52].
- Universal Coordinate Resolution Engine:
  - Captures weather for 100% of trips (including skunked / 0-catch sessions) via a 3-tier fallback hierarchy[cite: 52]:
    1. Last recorded catch GPS coordinates[cite: 52].
    2. Active device hardware location snapshot at trip closure[cite: 52].
    3. Central Reservoir geographic coordinates (`reservoir.latitude`, `reservoir.longitude`)[cite: 52].
- Release Assets, Provisioning & UI Architecture:
  - `AppIcon.appiconset`: Complete 1024x1024 master App Icon catalog deployed across iOS Home screen, Settings, and Notification contexts[cite: 19].
  - Launch Experience: `LaunchScreen.storyboard` static XML background paired with `LaunchView.swift` dynamic logo pulse animation on app cold boot[cite: 8].
  - Provisioning & Signing: Capabilities configured with active Apple Developer Team signing certificate, enabling native WeatherKit and iCloud container entitlements[cite: 19, 52].
  - UI Contrast & Trait Resolution: App-wide screen-by-screen contrast audit complete[cite: 41]. Card-internal controls and text elements explicitly enforce card-scoped semantic tokens (`textOnCardPrimary` and `textOnCardSecondary`), ensuring dark slate legibility over warm sand cards in both Light and Dark system modes[cite: 41].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard with temporal filtering, summary telemetry cards, value-based navigation, and `.sheet` presentation trigger for onboarding new reservoirs[cite: 10, 37].
  - `AddReservoirView.swift`: Onboarding form sheet for new reservoirs with case-insensitive name deduplication, 2-character validation, optional GPS centerpoint capture via `LocationService`, and atomic `modelContext.save()` commits[cite: 10, 40].
  - `ReservoirDetailsView.swift`: Aggregate metrics, MapKit spatial catch map with species-coded annotations, and trip listing[cite: 22].
  - `TripDetailsView.swift` & `TripCatchMapView.swift`: Session overview, interactive MapKit spatial catch map with callouts, weather snapshot cards, and chronological catch log timeline[cite: 22].
  - `StartTripView.swift`: Configuration sheet launching live active sessions with explicit pre-insertion into `modelContext` and dark-mode high-contrast DatePicker/TextField prompts[cite: 23, 41].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time session workspace with active stopwatch mechanics, live catch timeline, and destructive alert-confirmed "Discard Trip" action[cite: 10, 23].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Catch logging modal with native `LocationService` coordinate capture, local image disk storage via `ImageStorageService`, and dark-mode high-contrast input prompts[cite: 21, 26, 49].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal state locking sheet triggering `resolveCoordinate()` and `WeatherService.shared.fetchCurrentWeather()` prior to committing atomic `modelContext.save()` transactions, plus "Discard Trip Without Saving" fallback CTA[cite: 10, 52].
  - `AnalyticsDashboardView.swift`: Diagnostic dashboard root with master temporal filtering (`CVYearPicker`)[cite: 11].
  - `AnglerTotalsView.swift`: High-density angler performance ledger[cite: 25].
  - `ReservoirLeaderboardView.swift`: Ranked top-10 heaviest landed fish matrix[cite: 48].
  - `SpeciesBreakdownView.swift` & `CatchTrendsView.swift`: Native Swift Charts spatial/volumetric and 12-month temporal density views[cite: 27, 46].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 7].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution.
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 36].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 29].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, card-scoped trait resolution, and operational layout rules[cite: 34, 41].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 33, 44].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 8].
8. ENHANCEMENT_LIST.md: Backlog ledger tracking post-baseline utilities, spatial enhancements, data quality refinements, and deferred infrastructure features[cite: 13, 61].
9. MARKETING_STRATEGY.md: Position strategy, heritage outdoor branding voice, and audience targeting[cite: 20].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 56].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 56].
- Milestone 3 (Presentation Core & Infrastructure Bedrock): Completed[cite: 56].
- Milestone 4 (Live Operational Workflows): Completed[cite: 56].
- Milestone 5 (Analytical Dashboards): Completed[cite: 56].
- Milestone 6 (Minimum Testing Product & Beta Deployment): In Progress[cite: 56].
  - Completed: Step 6.1.1 (WeatherKit live API verification)[cite: 60], Step 6.2.1 – 6.2.3 (UI Card Geometry, Empty States, and Light/Dark Mode Contrast Audit)[cite: 41, 60], Step 6.3.1 (App Icon asset catalog setup)[cite: 60], Step 6.3.2 (Launch Screen and animated LaunchView setup)[cite: 60], Step 6.4.1 (Developer Signing & Capabilities provisioning)[cite: 60].

## 5. Key Architecture & Design Learnings

- Deduplication Invariants in Onboarding Forms: Case-insensitive `.trimmingCharacters(in: .whitespacesAndNewlines)` string comparisons against active `@Query` result sets prevent duplicate entity creation at creation boundaries (e.g., in `AddReservoirView` and `RecordFishView` species additions)[cite: 10, 26].
- Card-Scoped Trait-Resolved Contrast: Standard iOS controls (`TextField` prompts, `DatePicker` popovers) flip internal font colors to white in Dark Mode[cite: 41]. Because Layer 1 card containers (`CVCardContainer`) preserve a warm sand background across appearance modes, form elements inside cards must explicitly apply card-scoped semantic tokens (`textOnCardPrimary` / `textOnCardSecondary`) to remain crisp and dark[cite: 41].
- WeatherKit Entitlements & App Services: WeatherKit requires explicit configuration under both the **Capabilities** tab and the **App Services** tab on developer.apple.com to prevent WeatherDaemon JWT authentication failures (`error 2`)[cite: 19, 52].