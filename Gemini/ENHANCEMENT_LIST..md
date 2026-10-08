# CatchVault — Post-Baseline Enhancement & Backlog Ledger

## 1. Data Quality & Legacy Data Utilities
- [ ] **Retroactive Session Duration Adjustment**: Allow users to manually edit `startTime` and `endTime` on migrated legacy trips where single-catch or sparse records result in minimal durations.
- [ ] **Legacy Data Cleanup Tool**: Administrative screen to review and merge duplicate Anglers, Reservoirs, or Species imported from early web-app snapshots.
- [ ] **Legacy Data Duration & Session Boundary Refinements.**:

## 2. Infrastructure & Hardware Service Enhancements
- [ ] **Live MapKit Coordinates & Pin Clustering**: Upgrade placeholder containers in `ReservoirDetailsView` and `TripDetailsView` to interactive `MapKit` maps rendering catch pins.
- [ ] **Weather API Integration**: Fetch historical weather snapshots via WeatherKit for past trips or live conditions during active sessions.

## 3. Advanced Operational Workflows
- [ ] **Multi-Angler Catch Attribution**: Support logging co-landed fish or assigning catches to guest anglers dynamically during live trips.
- [ ] **Photo Gallery & Storage Compression**: Implement full-screen photo viewers and background image compression for locally attached catch media.

## 4. Analytical & Export Enhancements
- [ ] **PDF & CSV Export**: Generate printable trip summaries or raw CSV exports of catch histories.
- [ ] **Personal Bests Matrix**: Add a dedicated "Personal Records" view highlighting the largest fish landed by species and reservoir.