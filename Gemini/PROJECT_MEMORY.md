# CatchVault — Project Memory & State

## 1. System Intent & Mission

- Objective: Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData[cite: 3].
- Key Vectors:
  - Native hardware & platform integration (MapKit, CoreLocation, WeatherKit, background active session timers)[cite: 3].
  - Modernized UI/UX using a strict declarative, state-driven paradigm adhering to semantic design tokens[cite: 3].
  - Resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit[cite: 3, 17].

## 2. Architectural Baseline & State Summary

- Data Persistence: SwiftData is the local source of truth[cite: 3]. Explicit `try modelContext.save()` calls wrap mutations to enforce atomic persistence boundaries[cite: 3].
- Hardware & Service Proxies:
  - `LocationService.swift`: Native CoreLocation proxy supporting single-flight concurrency, high-accuracy GPS locks, and simulator relaxation[cite: 6, 9].
  - `WeatherService.swift`: Native Apple WeatherKit service proxy with non-blocking error handling and automatic unit conversion (°F / mph / inches)[cite: 5].
- Universal Coordinate Resolution Engine:
  - Captures weather for 100% of trips (including skunked / 0-catch sessions) via a 3-tier fallback hierarchy[cite: 5]:
    1. Last recorded catch GPS coordinates[cite: 5].
    2. Active device hardware location snapshot at trip closure[cite: 5].
    3. Central Reservoir geographic coordinates (`reservoir.latitude`, `reservoir.longitude`)[cite: 5].
- Presentation Views & Workflows Completed:
  - `ReservoirHome.swift`: Main dashboard with temporal filtering, summary telemetry cards, and value-based navigation[cite: 3].
  - `ReservoirDetailsView.swift`: Aggregate metrics, MapKit spatial catch map, and trip listing[cite: 3].
  - `TripDetailsView.swift` & `TripCatchMapView.swift`: Session overview, interactive MapKit spatial catch map, weather snapshot cards, and chronological catch log timeline[cite: 3].
  - `StartTripView.swift`: Configuration sheet launching live active sessions with explicit pre-insertion into `modelContext`[cite: 3].
  - `ActiveTripView.swift` & `ActiveTripViewModel.swift`: Real-time session workspace with active stopwatch mechanics and live catch timeline[cite: 3].
  - `RecordFishView.swift` & `RecordFishViewModel.swift`: Catch logging modal with native `LocationService` coordinate capture[cite: 3].
  - `EndTripView.swift` & `EndTripViewModel.swift`: Terminal state locking sheet triggering `resolveCoordinate()` and `WeatherService.shared.fetchCurrentWeather()` prior to committing atomic `modelContext.save()` transactions[cite: 3, 5].
  - `AnalyticsDashboardView.swift`: Diagnostic dashboard root with master temporal filtering (`CVYearPicker`)[cite: 3].
  - `AnglerTotalsView.swift`: High-density angler performance ledger[cite: 3].
  - `ReservoirLeaderboardView.swift`: Ranked top-10 heaviest landed fish matrix[cite: 3].
  - `SpeciesBreakdownView.swift` & `CatchTrendsView.swift`: Native Swift Charts spatial/volumetric and 12-month temporal density views[cite: 3].

## 3. Execution Ledger & Milestone Status

- Milestone 1 (Core Domain Engine): Completed[cite: 3].
- Milestone 2 (Data Ingestion Pipeline): Completed[cite: 3].
- Milestone 3 (Presentation Core & Infrastructure Bedrock): Completed[cite: 3].
  - Completed: Design Tokens, UI Container Primitives, Core Presentation Views, `LocationService.swift`, and `WeatherService.swift`[cite: 3, 5, 9].
- Milestone 4 (Live Operational Workflows): Completed[cite: 3].
- Milestone 5 (Analytical Dashboards): Completed[cite: 3].

## 4. Key Architecture & Design Learnings

- WeatherKit App ID Capabilities: Enabling WeatherKit in Xcode requires checking WeatherKit under both the **Capabilities** tab and the **App Services** tab on developer.apple.com to prevent JWT authentication errors (`WeatherDaemon error 2`)[cite: 3].
- Zero-Catch Environmental Intelligence: Resolving coordinates via the parent Reservoir as a fallback ensures environmental snapshots are captured for 0-catch trips, preserving crucial weather baseline data for sports performance analysis[cite: 4, 5].