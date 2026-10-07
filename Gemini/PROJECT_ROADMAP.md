# CatchVault Development Roadmap Checklist

## Milestone 1: Core Domain Engine
- [x] 1.1 Entity Layout Initialization (Angler, Reservoir, Species, Trip, FishCatch)[cite: 1, 30]
- [x] 1.2 Relationship & CloudKit Rule Enforcement (@Relationship inverses, defaults)[cite: 1, 30]
- [x] 1.3 Cascade Validation Layer (Unit tests for delete rules and integrity constraints)[cite: 1, 30]

## Milestone 2: Data Ingestion Pipeline (Anti-Corruption Bridge)
- [x] 2.1 Legacy Payload Decoders (Polymorphic decoders for MongoDB JSON extracts)[cite: 1, 30]
- [x] 2.2 Deterministic Trip Aggregator (YYYY-MM-DD-ReservoirName synthetic parent keys)[cite: 1, 30]
- [x] 2.3 Chunked Migration Executer (MigrationManager execution and verification)[cite: 1, 30]

## Milestone 3: Presentation Core & Infrastructure Bedrock
- [x] 3.1 Design Token Architecture Setup (Colors.swift, Typography.swift)[cite: 1, 30]
- [x] 3.2 Custom UI Container Structure (CVCardContainer.swift)[cite: 1, 30]
- [x] 3.3 Interactive Core Presentation Views[cite: 1, 30]
  - [x] ReservoirHome.swift (Main Dashboard, Year filter, Reservoir list, Navigation routing)[cite: 1, 30]
  - [x] ReservoirDetailsView.swift (Aggregate metrics, CatchMap placeholder, Chronological trip list)[cite: 1, 30]
- [ ] 3.4 Infrastructure Service Proxies[cite: 1, 30]
  - [ ] CoreLocation hardware integration shell (LocationService.swift)[cite: 1, 30]
  - [ ] Weather serialization and fetch framework (WeatherService.swift)[cite: 1, 30]

## Milestone 4: Operational Transactional Workflows (Live Logs)
- [x] 4.1 Active Trip Timer & ViewModel (ActiveTripViewModel.swift with persistent stopwatch state)[cite: 1, 30]
- [x] 4.2 Start Trip Configuration Sheet (StartTripView.swift)[cite: 1, 30]
- [x] 4.3 Live Active Workspace (ActiveTripView.swift with real-time timeline)[cite: 1, 30]
- [x] 4.4 Record Fish Entry Form (RecordFishView.swift with species search and weight entry)[cite: 1, 30]
- [x] 4.5 End Trip Summary View (EndTripView.swift with final observations and state locking)[cite: 1, 30]

## Milestone 5: High-Density Analytical Views & Dashboards
- [ ] 5.1 Analytics Dashboard Root (AnalyticsDashboardView.swift)[cite: 1, 30]
- [ ] 5.2 Angler Totals Ledger (AnglerTotalsView.swift)[cite: 1, 30]
- [ ] 5.3 Reservoir Leaderboard (ReservoirLeaderboardView.swift)[cite: 1, 30]
- [ ] 5.4 Temporal Trends & Species Breakdown Charts (TemporalTrendsView.swift, SpeciesBreakdownView.swift)[cite: 1, 30]