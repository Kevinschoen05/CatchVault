# CatchVault Development Roadmap Checklist

## Milestone 1: Core Domain Engine
- [x] 1.1 Entity Layout Initialization (Angler, Reservoir, Species, Trip, FishCatch)
- [x] 1.2 Relationship & CloudKit Rule Enforcement (@Relationship inverses, defaults)
- [x] 1.3 Cascade Validation Layer (Unit tests for delete rules and integrity constraints)

## Milestone 2: Data Ingestion Pipeline (Anti-Corruption Bridge)
- [x] 2.1 Legacy Payload Decoders (Polymorphic decoders for MongoDB JSON extracts)
- [x] 2.2 Deterministic Trip Aggregator (YYYY-MM-DD-ReservoirName synthetic parent keys)[cite: 6]
- [x] 2.3 Chunked Migration Executer (MigrationManager execution and verification)[cite: 6]

## Milestone 3: Presentation Core & Infrastructure Bedrock
- [x] 3.1 Design Token Architecture Setup (Colors.swift, Typography.swift)[cite: 6]
- [x] 3.2 Custom UI Container Structure (CVCardContainer.swift)[cite: 6]
- [x] 3.3 Interactive Core Presentation Views (ReservoirHome, ReservoirDetails, TripDetails)[cite: 6]
- [x] 3.4 Infrastructure Service Proxies[cite: 6]
  - [x] CoreLocation hardware integration shell (LocationService.swift)[cite: 6]
  - [x] Weather serialization and fetch framework (WeatherService.swift)[cite: 6]

## Milestone 4: Operational Transactional Workflows (Live Logs)
- [x] 4.1 Active Trip Timer & ViewModel (ActiveTripViewModel.swift)[cite: 6]
- [x] 4.2 Start Trip Configuration Sheet (StartTripView.swift)[cite: 6]
- [x] 4.3 Live Active Workspace (ActiveTripView.swift)[cite: 6]
- [x] 4.4 Record Fish Entry Form (RecordFishView.swift)[cite: 6]
- [x] 4.5 End Trip Summary View (EndTripView.swift with WeatherKit Integration)[cite: 6]

## Milestone 5: High-Density Analytical Views & Dashboards
- [x] 5.1 Analytics Dashboard Root (AnalyticsDashboardView.swift)[cite: 6]
- [x] 5.2 Angler Totals Ledger (AnglerTotalsView.swift)[cite: 6]
- [x] 5.3 Reservoir Leaderboard (ReservoirLeaderboardView.swift)[cite: 6]
- [x] 5.4 Temporal Trends & Species Breakdown Charts (SpeciesBreakdown, CatchTrends)[cite: 6]

## Milestone 6: Minimum Testing Product (MTP) & Beta Deployment

### 6.1 Hardware & Service Verification
- [x] 6.1.1 Verify live WeatherKit API responses in physical/simulator runtime under paid developer account[cite: 7]
- [ ] 6.1.2 Verify CoreLocation GPS fix and fallback cascade (Catch GPS -> Device GPS -> Reservoir fallback)[cite: 6]
- [ ] 6.1.3 Test offline/airplane mode edge cases to confirm non-blocking save behavior[cite: 6]

### 6.2 Target Screen UI Polish & Ergonomic Audit
- [ ] 6.2.1 Audit card container geometry, padding symmetry, and 44pt touch targets across screens[cite: 6]
- [ ] 6.2.2 Audit empty states and nil fallbacks (e.g., zero-catch trips, missing weather data)[cite: 6]
- [ ] 6.2.3 Review contrast and legibility across Light and Dark system modes[cite: 6]

### 6.3 Brand Assets & Display Setup
- [x] 6.3.1 Generate 1024x1024 App Icon asset catalog (`AppIcon`)[cite: 6]
- [x] 6.3.2 Configure branded Launch Screen backdrop and logo presentation[cite: 6]

### 6.4 App Store Connect & TestFlight Provisioning
- [x] 6.4.1 Configure Signing & Capabilities with paid Apple Developer Team certificate[cite: 6]
- [ ] 6.4.2 Set up Privacy Usage Descriptions in `Info.plist` (Location & Photo Access)[cite: 6]
- [ ] 6.4.3 Archive release binary (.ipa) in Xcode and upload to App Store Connect[cite: 6]
- [ ] 6.4.4 Set up Internal/External TestFlight Beta group and issue invite link to target users[cite: 6]