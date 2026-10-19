# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData[cite: 5].
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, WeatherKit, background active session timers)[cite: 5].
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 5].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 5].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 5]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 5].
- Hardware & Service Proxies:
  - `LocationService.swift`: Native CoreLocation proxy supporting single-flight concurrency, high-accuracy GPS locks, and simulator relaxation[cite: 5].
  - `WeatherService.swift`: Native Apple WeatherKit service proxy with non-blocking error handling, live WeatherDaemon JWT authentication, and automatic unit conversion (°F / mph / inches)[cite: 5, 7].
- Universal Coordinate Resolution Engine:
  - Captures weather for 100% of trips (including skunked / 0-catch sessions) via a 3-tier fallback hierarchy[cite: 5]:
    1. Last recorded catch GPS coordinates[cite: 5].
    2. Active device hardware location snapshot at trip closure[cite: 5].
    3. Central Reservoir geographic coordinates (`reservoir.latitude`, `reservoir.longitude`)[cite: 5].
- Release Assets & Provisioning Engine:
  - `AppIcon.appiconset`: Complete 1024x1024 master App Icon catalog deployed across iOS Home screen, Settings, and Notification contexts[cite: 5].
  - Launch Experience: `LaunchScreen.storyboard` static XML background paired with `LaunchView.swift` dynamic logo pulse animation on app cold boot[cite: 5].
  - Provisioning & Signing: Capabilities configured with active Apple Developer Team signing certificate, enabling native WeatherKit and iCloud container entitlements[cite: 5, 7].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard with temporal filtering, summary telemetry cards, and value-based navigation[cite: 5].
  - `ReservoirDetailsView.swift`: Aggregate metrics, MapKit spatial catch map, and trip listing[cite: 5].
  - `TripDetailsView.swift` & `TripCatchMapView.swift`: Session overview, interactive MapKit spatial catch map, weather snapshot cards, and chronological catch log timeline[cite: 5].
  - `StartTripView.swift`: Configuration sheet launching live active sessions with explicit pre-insertion into `modelContext`[cite: 5].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time session workspace with active stopwatch mechanics and live catch timeline[cite: 5].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Catch logging modal with native `LocationService` coordinate capture[cite: 5].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal state locking sheet triggering `resolveCoordinate()` and `WeatherService.shared.fetchCurrentWeather()` prior to committing atomic `modelContext.save()` transactions[cite: 5].
  - `AnalyticsDashboardView.swift`: Diagnostic dashboard root with master temporal filtering (`CVYearPicker`)[cite: 5].
  - `AnglerTotalsView.swift`: High-density angler performance ledger[cite: 5].
  - `ReservoirLeaderboardView.swift`: Ranked top-10 heaviest landed fish matrix[cite: 5].
  - `SpeciesBreakdownView.swift` & `CatchTrendsView.swift`: Native Swift Charts spatial/volumetric and 12-month temporal density views[cite: 5].

## 3. Project Documentation Matrix

1. RULES.md: Operational posture, communication rules, and code quality invariants[cite: 5].
2. PROJECT_MEMORY.md: Current project state, memory baseline, and structural evolution[cite: 5].
3. USER_REQUIREMENTS_v1.md: Operational workflows, transactional logging limits, and metrics calculations[cite: 5].
4. DATA_MODEL.md: Schema rules, inverses, delete rules, and deduplication constraints[cite: 5].
5. STYLE_GUIDE.md: Design system tokens, typography rules, layer hierarchy, visual palette definitions, and operational layout rules[cite: 5].
6. PROJECT_ROADMAP.md: Master milestone target tracking checklist[cite: 5, 6].
7. PROJECT_WORKFLOW.md: Mandatory 5-step operational workflow for feature implementation and verification[cite: 5].
8. ENHANCEMENT_LIST.md: Backlog ledger tracking post-baseline utilities, spatial enhancements, data quality refinements, and deferred infrastructure features[cite: 5].
9. MARKETING_STRATEGY.md: Position strategy, heritage outdoor branding voice, and audience targeting[cite: 5].

## 4. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 5].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 5].
- Milestone 3 (Presentation Core & Infrastructure Bedrock): Completed[cite: 5].
  - Completed: Design Tokens, UI Container Primitives, Core Presentation Views, `LocationService.swift`, and `WeatherService.swift`[cite: 5].
- Milestone 4 (Live Operational Workflows): Completed[cite: 5].
- Milestone 5 (Analytical Dashboards): Completed[cite: 5].
- Milestone 6 (Minimum Testing Product & Beta Deployment): In Progress[cite: 5, 6].
  - Completed: Step 6.1.1 (WeatherKit live API verification), Step 6.3.1 (App Icon asset catalog setup)[cite: 5], Step 6.3.2 (Launch Screen and animated LaunchView setup)[cite: 5], Step 6.4.1 (Developer Signing & Capabilities provisioning)[cite: 5, 7].

## 5. Key Architecture & Design Learnings

- WeatherKit Entitlements & App Services: WeatherKit requires explicit configuration under both the **Capabilities** tab and the **App Services** tab on developer.apple.com to prevent WeatherDaemon JWT authentication failures (`error 2`)[cite: 5, 7].
- Dynamic Splash Overlay Separation: Static launch storyboards serve OS-level startup needs, while wrapping `ReservoirHome` inside a `ZStack` overlaid with `LaunchView` provides seamless, hardware-smooth transition animations into the main workspace without blocking SwiftData queries[cite: 5].
- Zero-Catch Environmental Intelligence: Resolving coordinates via the parent Reservoir as a fallback ensures environmental snapshots are captured for 0-catch trips, preserving crucial weather baseline data for sports performance analysis[cite: 5].