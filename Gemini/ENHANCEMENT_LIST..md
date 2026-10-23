# CatchVault — Post-Baseline Enhancement & Backlog Ledger

## 1. Data Quality & Core Data Workflows
- [x] **Standard Data Editing Workflows**: General UI facilities for users to retroactively edit saved `Trip` and `FishCatch` parameters.
- [ ] **Legacy Data Duration & Session Boundary Refinements**: Refine heuristics for legacy single-catch trips.
- [x] **Add Reservoir View (`AddReservoirView.swift`)**: Modal sheet form triggered from `ReservoirHome` to onboard new water bodies.

## 2. Infrastructure & Hardware Service Enhancements
- [x] **Trip Details Spatial Catch Map**: MapKit interactive spatial map plotting GPS catch markers.
- [x] **Reservoir Details Spatial Catch Map**: MapKit interactive spatial map rendering species color-coded catch pins.
- [x] **CoreLocation GPS Catch Telemetry**: Automatic off-grid hardware GPS coordinate capture[cite: 20].
- [x] **WeatherKit Integration**: Native Apple WeatherKit service proxy to snapshot weather conditions[cite: 20].

## 3. Advanced Operational Workflows
- [x] **Photo Gallery & Storage Compression**: Full-screen photo viewers and background image compression[cite: 20].
- [x] **Interactive Catch Map Filtering**: Filter map pins on `ReservoirDetailsView` by specific species or angler[cite: 20].
- [x] **Quit Active Trip Without Saving (Discard Trip)**: Explicit, alert-confirmed action to discard an accidental session[cite: 20].
- [ ] **Device Owner / User Profile Entity**: Evolve the core `Angler` domain model to support a primary app-owner identity[cite: 20].

## 4. Analytical & Export Enhancements
- [ ] **PDF & CSV Export**: Generate printable trip summaries or raw CSV exports of catch histories[cite: 20].
- [ ] **Personal Bests Matrix**: Dedicated "Personal Records" view highlighting the largest fish landed[cite: 20].

## 5. MapKit & Spatial Visualization Enhancements
- [ ] **Interactive Time-Lapse Playback**: Animate catch pins appearing on the map sequentially[cite: 20].
- [x] **Full-Screen Map Modal**: 180pt map cards expand into interactive full-screen map views[cite: 20].
- [x] **Interactive Callout Navigation**: Tapping a catch pin on reservoir maps opens a direct navigation link handoff[cite: 20].

## 6. Low Priority / Edge Case Polish
- [ ] **Filter Bar Scalability for Large Roster/Species Lists**: Transition the horizontal map filter pill bar into collapsible `Menu` sheets[cite: 20].