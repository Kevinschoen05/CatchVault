# CatchVault Development Roadmap Checklist

## Milestone 1: Core Domain Engine
- [x] 1.1 Entity Layout Initialization (Angler, Reservoir, Species, Trip, FishCatch)[cite: 3, 13, 36]
- [x] 1.2 Relationship & CloudKit Rule Enforcement (@Relationship inverses, defaults)[cite: 3, 13, 36]
- [x] 1.3 Cascade Validation Layer (Unit tests for delete rules and integrity constraints)[cite: 3, 13, 36]

## Milestone 2: Data Ingestion Pipeline (Anti-Corruption Bridge)
- [x] 2.1 Legacy Payload Decoders (Polymorphic decoders for MongoDB JSON extracts)[cite: 3, 13, 36]
- [x] 2.2 Deterministic Trip Aggregator (YYYY-MM-DD-ReservoirName synthetic parent keys)[cite: 3, 13, 36]
- [x] 2.3 Chunked Migration Executer (MigrationManager execution and verification)[cite: 3, 13, 36]

## Milestone 3: Presentation Core & Infrastructure Bedrock
- [x] 3.1 Design Token Architecture Setup (Colors.swift, Typography.swift)[cite: 3, 13, 36]
- [x] 3.2 Custom UI Container Structure (CVCardContainer.swift)[cite: 3, 13, 36]
- [x] 3.3 Interactive Core Presentation Views[cite: 3, 13, 36]
  - [x] ReservoirHome.swift (Main Dashboard, Year filter, Reservoir list, Navigation routing)[cite: 3, 13, 36]
  - [x] ReservoirDetailsView.swift (Aggregate metrics, CatchMap placeholder, Chronological trip list)[cite: 3, 13, 36]
- [ ] 3.4 Infrastructure Service Proxies[cite: 3, 13, 36]
  - [ ] CoreLocation hardware integration shell (LocationService.swift)[cite: 3, 13, 36]
  - [ ] Weather serialization and fetch framework (WeatherService.swift)[cite: 3, 13, 36]

## Milestone 4: Operational Transactional Workflows (Live Logs)
- [x] 4.1 Active Trip Timer & ViewModel (ActiveTripViewModel.swift with persistent stopwatch state)[cite: 3, 13, 36]
- [x] 4.2 Start Trip Configuration Sheet (StartTripView.swift)[cite: 3, 13, 36]
- [x] 4.3 Live Active Workspace (ActiveTripView.swift with real-time timeline)[cite: 3, 13, 36]
- [x] 4.4 Record Fish Entry Form (RecordFishView.swift with species search and weight entry)[cite: 3, 13, 36]
- [x] 4.5 End Trip Summary View (EndTripView.swift with final observations and state locking)[cite: 3, 13, 36]

## Milestone 5: High-Density Analytical Views & Dashboards
- [x] 5.1 Analytics Dashboard Root (AnalyticsDashboardView.swift with temporal filter and baseline telemetry)[cite: 3, 13, 36]
- [x] 5.2 Angler Totals Ledger (AnglerTotalsView.swift with zero-fish trip telemetry and zero-omission species ledger)[cite: 3, 20]
- [ ] 5.3 Reservoir Leaderboard (ReservoirLeaderboardView.swift)[cite: 3, 20]
- [ ] 5.4 Temporal Trends & Species Breakdown Charts (TemporalTrendsView.swift, SpeciesBreakdownView.swift)[cite: 3, 20]