# CatchVault Development Roadmap Checklist

## Milestone 1: Core Domain Engine
- [x] 1.1 Entity Layout Initialization (Angler, Reservoir, Species, Trip, FishCatch)[cite: 11, 12]
- [x] 1.2 Relationship & CloudKit Rule Enforcement (@Relationship inverses, defaults)[cite: 11, 12]
- [x] 1.3 Cascade Validation Layer (Unit tests for delete rules and integrity constraints)[cite: 11, 12]

## Milestone 2: Data Ingestion Pipeline (Anti-Corruption Bridge)
- [x] 2.1 Legacy Payload Decoders (Polymorphic decoders for MongoDB JSON extracts)[cite: 11, 12]
- [x] 2.2 Deterministic Trip Aggregator (YYYY-MM-DD-ReservoirName synthetic parent keys)[cite: 11, 12]
- [x] 2.3 Chunked Migration Executer (MigrationManager execution and verification)[cite: 11, 12]

## Milestone 3: Presentation Core & Infrastructure Bedrock
- [x] 3.1 Design Token Architecture Setup (Colors.swift, Typography.swift)[cite: 11, 12]
- [x] 3.2 Custom UI Container Structure (CVCardContainer.swift)[cite: 11, 12]
- [x] 3.3 Interactive Core Presentation Views[cite: 11, 12]
  - [x] ReservoirHome.swift (Main Dashboard, Year filter, Reservoir list, Navigation routing)[cite: 11, 12]
  - [x] ReservoirDetailsView.swift (Aggregate metrics, MapKit spatial catch map, Chronological trip list, Navigation to TripDetails)[cite: 11, 12]
  - [x] TripDetailsView.swift (Session overview, MapKit spatial catch map integration, Weather snapshot card, Chronological catch timeline, Notes)[cite: 11, 12]
- [x] 3.4 Infrastructure Service Proxies[cite: 11, 12]
  - [x] CoreLocation hardware integration shell (LocationService.swift)[cite: 11, 12]
  - [x] Weather serialization and fetch framework (WeatherService.swift)[cite: 11, 12]

## Milestone 4: Operational Transactional Workflows (Live Logs)
- [x] 4.1 Active Trip Timer & ViewModel (ActiveTripViewModel.swift with persistent stopwatch state)[cite: 11, 12]
- [x] 4.2 Start Trip Configuration Sheet (StartTripView.swift)[cite: 11, 12]
- [x] 4.3 Live Active Workspace (ActiveTripView.swift with real-time timeline)[cite: 11, 12]
- [x] 4.4 Record Fish Entry Form (RecordFishView.swift with species search, weight entry, and GPS capture)[cite: 11, 12]
- [x] 4.5 End Trip Summary View (EndTripView.swift with final observations and state locking)[cite: 11, 12]

## Milestone 5: High-Density Analytical Views & Dashboards
- [x] 5.1 Analytics Dashboard Root (AnalyticsDashboardView.swift with temporal filter and baseline telemetry)[cite: 11, 12]
- [x] 5.2 Angler Totals Ledger (AnglerTotalsView.swift with zero-fish trip telemetry and zero-omission species ledger)[cite: 11, 12]
- [x] 5.3 Reservoir Leaderboard (ReservoirLeaderboardView.swift with top-10 heaviest landed fish matrix)[cite: 11, 12]
- [x] 5.4 Temporal Trends & Species Breakdown Charts[cite: 11, 12]
  - [x] SpeciesBreakdownView.swift (Spatial allocation & species landing volumes)[cite: 11, 12]
  - [x] CatchTrendsView.swift (12-month seasonal catch density across calendar cycles)[cite: 11, 12]