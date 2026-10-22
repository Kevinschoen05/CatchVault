# CatchVault — Post-Baseline Enhancement & Backlog Ledger

## 1. Data Quality & Legacy Data Utilities
- [ ] **Retroactive Session Duration Adjustment**: Allow users to manually edit `startTime` and `endTime` on migrated legacy trips where single-catch or sparse records result in minimal durations.
- [ ] **Legacy Data Cleanup Tool**: Administrative screen to review and merge duplicate Anglers, Reservoirs, or Species imported from early web-app snapshots.
- [ ] **Legacy Data Duration & Session Boundary Refinements**: Refine heuristics for legacy single-catch trips.
- [x] **Add Reservoir View (`AddReservoirView.swift`)**: Implemented modal sheet form triggered from `ReservoirHome` to onboard new water body entities with case-insensitive deduplication, name trimming, and optional GPS centerpoint coordinates.

## 2. Infrastructure & Hardware Service Enhancements
- [x] **Trip Details Spatial Catch Map**: Integrated MapKit interactive spatial map (`TripCatchMapView.swift`) into `TripDetailsView.swift` plotting GPS catch markers with callouts[cite: 21].
- [x] **Reservoir Details Spatial Catch Map**: Integrated MapKit interactive spatial map into `ReservoirDetailsView.swift` rendering species color-coded catch pins across all trips under the active year filter[cite: 21].
- [x] **CoreLocation GPS Catch Telemetry**: Implemented `LocationService.swift` to automatically capture off-grid hardware GPS coordinates when opening the `RecordFishView` sheet[cite: 21].
- [x] **WeatherKit Integration**: Native Apple WeatherKit service proxy (`WeatherService.swift`) integrated into `EndTripViewModel` to snapshot weather conditions on session closure[cite: 21].

## 3. Advanced Operational Workflows
- [ ] **Multi-Angler Catch Attribution**: Support logging co-landed fish or assigning catches to guest anglers dynamically during live trips.
- [x] **Photo Gallery & Storage Compression**: Implemented full-screen photo viewers and background image compression for locally attached catch media[cite: 21].
- [x] **Interactive Catch Map Filtering**: Filter map pins on `ReservoirDetailsView` by specific species or angler via interactive toggle pills with dynamic map camera recentering[cite: 3, 21].
- [x] **Quit Active Trip Without Saving (Discard Trip)**: Explicit, alert-confirmed action on `ActiveTripView` / `EndTripView` to discard an accidental or aborted session, executing a cascade delete on the pre-inserted `Trip` and its catches in `modelContext`[cite: 21].
- [ ] **Device Owner / User Profile Entity**: Evolve the core `Angler` domain model to support a primary app-owner identity (`isAppOwner: Bool` or `UserProfile` entity). Automatically pre-selects the device owner when launching a trip in `StartTripView`, powers personal best isolation in analytics, and maintains seamless backwards compatibility with existing multi-angler trip relationships.

## 4. Analytical & Export Enhancements
- [ ] **PDF & CSV Export**: Generate printable trip summaries or raw CSV exports of catch histories.
- [ ] **Personal Bests Matrix**: Add a dedicated "Personal Records" view highlighting the largest fish landed by species and reservoir.

## 5. MapKit & Spatial Visualization Enhancements
- [ ] **Interactive Time-Lapse Playback**: Animate catch pins appearing on the map sequentially based on landing timestamps.
- [x] **Full-Screen Map Modal**: Implemented `FullScreenMapView.swift` modal sheet allowing 180pt map cards to expand into interactive full-screen map views with style toggles, memory flushing, and auto-recenter controls.
- [x] **Interactive Callout Navigation**: Tapping a catch pin on reservoir maps opens a custom floating callout with direct navigation link handoff to `TripDetailsView`.

## 6. Low Priority / Edge Case Polish
- [ ] **Filter Bar Scalability for Large Roster/Species Lists**: Transition the horizontal map filter pill bar into collapsible/searchable `Menu` or popover sheets when `availableSpecies.count > 6` or `availableAnglers.count > 6` to keep large datasets easily searchable without excessive horizontal scrolling[cite: 3, 21].s