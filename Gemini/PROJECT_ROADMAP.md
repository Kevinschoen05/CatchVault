# CatchVault Development Roadmap Checklist

## Milestone 1: Core Domain Engine
- [x] 1.1 Entity Layout Initialization (Angler, Reservoir, Species, Trip, FishCatch)
- [x] 1.2 Relationship & CloudKit Rule Enforcement (@Relationship inverses, defaults)
- [x] 1.3 Cascade Validation Layer (Unit tests for delete rules and integrity constraints)

## Milestone 2: Data Ingestion Pipeline (Anti-Corruption Bridge)
- [x] 2.1 Legacy Payload Decoders (Polymorphic decoders for MongoDB JSON extracts)
- [x] 2.2 Deterministic Trip Aggregator (YYYY-MM-DD-ReservoirName synthetic parent keys)
- [x] 2.3 Chunked Migration Executer (MigrationManager execution and verification)

## Milestone 3: Presentation Core & Infrastructure Bedrock
- [x] 3.1 Design Token Architecture Setup (Colors.swift, Typography.swift)
- [x] 3.2 Custom UI Container Structure (CVCardContainer.swift)
- [x] 3.3 Interactive Core Presentation Views
  - [x] ReservoirHome.swift (Main Dashboard, Year filter, Reservoir list, Navigation routing)
  - [x] ReservoirDetailsView.swift (Aggregate metrics, CatchMap placeholder, Chronological trip list)
- [ ] 3.4 Infrastructure Service Proxies
  - [ ] CoreLocation hardware integration shell (`LocationService.swift`)
  - [ ] Weather serialization and fetch framework (`WeatherService.swift`)

## Milestone 4: Operational Transactional Workflows (Live Logs)
- [ ] 4.1 Active Trip Timer & ViewModel (`ActiveTripViewModel.swift` with persistent stopwatch state)
- [ ] 4.2 Start Trip Configuration Sheet (`StartTripView.swift`)
- [ ] 4.3 Live Active Workspace (`ActiveTripView.swift` with real-time timeline)
- [ ] 4.4 Record Fish Entry Form (`RecordFishView.swift` with species search and weight entry)
- [ ] 4.5 End Trip Summary View (`EndTripView.swift` with final observations and state locking)

## Milestone 5: High-Density Analytical Views & Dashboards
- [ ] 5.1 Analytics Dashboard Root (`AnalyticsDashboardView.swift`)
- [ ] 5.2 Angler Totals Ledger (`AnglerTotalsView.swift`)
- [ ] 5.3 Reservoir Leaderboard (`ReservoirLeaderboardView.swift`)
- [ ] 5.4 Temporal Trends & Species Breakdown Charts (`TemporalTrendsView.swift`, `SpeciesBreakdownView.swift`)