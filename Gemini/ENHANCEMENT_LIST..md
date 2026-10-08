# CatchVault — Post-Baseline Enhancement & Backlog Ledger

## 1. Data Quality & Legacy Data Utilities
- [ ] **Retroactive Session Duration Adjustment**: Allow users to manually edit `startTime` and `endTime` on migrated legacy trips where single-catch or sparse records result in minimal durations[cite: 6, 12].
- [ ] **Legacy Data Cleanup Tool**: Administrative screen to review and merge duplicate Anglers, Reservoirs, or Species imported from early web-app snapshots[cite: 6, 12].
- [ ] **Legacy Data Duration & Session Boundary Refinements**: Refine heuristics for legacy single-catch trips[cite: 6, 12].

## 2. Infrastructure & Hardware Service Enhancements
- [x] **Trip Details Spatial Catch Map**: Integrated MapKit interactive spatial map (`TripCatchMapView.swift`) into `TripDetailsView.swift` plotting GPS catch markers with callouts[cite: 6, 12].
- [x] **Reservoir Details Spatial Catch Map**: Integrated MapKit interactive spatial map into `ReservoirDetailsView.swift` rendering species color-coded catch pins across all trips under the active year filter[cite: 6, 22].
- [x] **CoreLocation GPS Catch Telemetry**: Implemented `LocationService.swift` to automatically capture off-grid hardware GPS coordinates when opening the `RecordFishView` sheet[cite: 6].
- [ ] **Weather API Integration**: Fetch historical weather snapshots via WeatherKit / Open-Meteo for past trips or live conditions during active sessions[cite: 6, 12].

## 3. Advanced Operational Workflows
- [ ] **Multi-Angler Catch Attribution**: Support logging co-landed fish or assigning catches to guest anglers dynamically during live trips[cite: 6, 12].
- [ ] **Photo Gallery & Storage Compression**: Implement full-screen photo viewers and background image compression for locally attached catch media[cite: 6, 12].

## 4. Analytical & Export Enhancements
- [ ] **PDF & CSV Export**: Generate printable trip summaries or raw CSV exports of catch histories[cite: 6, 12].
- [ ] **Personal Bests Matrix**: Add a dedicated "Personal Records" view highlighting the largest fish landed by species and reservoir[cite: 6, 12].

## 5. MapKit & Spatial Visualization Enhancements
- [ ] **Interactive Time-Lapse Playback**: Animate catch pins appearing on the map sequentially based on landing timestamps[cite: 6, 12].
- [ ] **Full-Screen Map Modal**: Allow expanding 180pt map cards into interactive full-screen map views[cite: 6, 12].
- [ ] **Interactive Callout Navigation**: Tapping a catch pin on reservoir maps opens a callout with a direct navigation link to `TripDetailsView`[cite: 6, 12].