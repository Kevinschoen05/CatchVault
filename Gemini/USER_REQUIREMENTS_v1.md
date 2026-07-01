# CatchVault — User Requirements

The primary purpose of CatchVault is to allow anglers to record operational details of their fishing activities in real time using a local-first, native iOS architecture. Captured data is preserved locally in an absolute state layer and visualized via diagnostic views and dashboards.

---

## 1. CORE DOMAIN ENTITIES & RELATIONSHIPS

### Trip Lifecycle
- A **Trip** represents a localized fishing session defined by an explicit start time and an optional end time.
- A Trip occurs at exactly one **Reservoir**.
- A Trip can include one or many **Anglers** present during the session.
- A Trip aggregates zero or many **FishCatch** entries recorded during its active duration.
- Weather data (temperature, wind speed, precipitation, and a structural text summary) is fetched and consolidated into static parameters on the `Trip` entity when the record is locked or concluded.

### FishCatch Attribution
- A **FishCatch** captures structural telemetry at the specific moment of landing a fish: exact timestamp, precise decimal weight, optional GPS coordinates (`Latitude`, `Longitude`), an optional local storage image path, and freeform text comments.
- Every `FishCatch` maps exclusively to exactly **one Angler** and exactly **one Species**.

---

## 2. WORKFLOWS & DATA INTEGRITY GUARDRAILS

### Single-Use Ingestion & Migration Layer (Anti-Corruption Bridge)
- **One-Time Cutover Rule:** Migration from the legacy production web app is a non-replicable, atomic event. The app transitions cleanly to a hard cutover state upon successful completion.
- **Deterministic Grouping Rule:** Flat legacy records sharing the same calendar day (`YYYY-MM-DD`) and the same `Reservoir` must be compressed into a single parent `Trip` record. 
- Individual legacy catches retain their distinct single `Angler` relationship within that shared multi-angler trip.
- Polymorphic string-to-double parsing handlers convert legacy coordinates and variable weight formats cleanly into type-safe Swift primitives.
- **State Finalization:** Upon verified verification of data writes into SwiftData, a global persistent flag (`isMigrated`) is toggled true. The migration runtime engine is completely skipped on all subsequent app executions.

### Data Redundancy & iCloud Persistence
- To protect historical data against hardware damage or device loss, the data persistence layer combines local-first execution with automated cloud duplication.
- **Synchronization Policy:** The SwiftData architecture utilizes a private iCloud CloudKit container to continuously mirror state delta records in the background. 
- **Offline Posture:** Network unavailability must never block application modifications or operational entry flows. All writes cache to the local container and flush upstream automatically upon reconnection.

### Inline Entity Creation Guardrails
- Users can dynamically add a new `Angler`, `Species`, or `Reservoir` inline from setup fields or active trip panels.
- To prevent text pollution and structural duplication, all new inputs are passed through a sanitation engine:
  1. Trimming of all leading, trailing, and redundant consecutive internal spaces.
  2. Case-insensitive deduplication check against existing records in the SwiftData context.
  3. Enforce a 2-character structural minimum.

### Lifecycle Recovery & State Resilience
- **Crash Recovery:** Upon cold boot, the application checks for the presence of an active `Trip` (`endTime == nil`). If an interrupted session is detected, the application automatically bypasses the dashboard and reinstates the active trip view, continuing the elapsed session clock.
- **Abandonment Management:** If an active trip crosses a 24-hour threshold without user intervention, it is categorized as stale. Upon subsequent application launch, a recovery modal forces resolution: allowing the user to explicitly backdate and save the completion parameters or discard the stale trip entirely to clean local state.

---

## 3. USER INTERFACE & NAVIGATION ARCHITECTURE

### Dashboard Matrix
- **Reservoir Explorer View:** Displays a grid of localized cards representing distinct bodies of water. Selecting a card filters historical summaries for that location.
- **One-Time Actions Interface:** Provides an initialization layout to trigger the single-use data migration. If `isMigrated == true`, this configuration panel is completely excluded from the UI hierarchy, exposing only standard operational workflows.
- **System Status Indicator:** Subdued UI element rendering cloud sync connectivity state (e.g., Synced, Syncing, Offline Mode).

### Start Trip Configuration Sheet
- Setup workflow prompting selection of a target `Reservoir` (Dropdown with text filter / Add New capability).
- Selection of one or more participating `Anglers` via a multi-select check interface or inline creation input.
- Confirmation initializes the session timer, instantiates the local `Trip` entity with an explicit `startTime`, and pushes the active workspace into view.

### Active Workspace View
- Displays a continuous, real-time stopwatch tracking active trip duration.
- Lists an append-only scrollable timeline of catches logged during the current session.
- Primary CTA triggers the **Record Fish View** modally.
- Secondary CTA exposes the **End Trip** interface to verify notes, append final observations, and cleanly write aggregated telemetry before closing state.

### Record Fish View
- An optimized entry form configured for low-friction real-time logging.
- Species dropdown selection with inline structural search and "Add New Species" configuration.
- Single-angler attribution selector populated only by the anglers selected during trip initialization.
- Numeric decimal entry for weight.
- Automated core hardware triggers to grab current `CoreLocation` coordinates and store image data to disk space.

---

## 4. ANALYTICS & DIAGNOSTIC VIEWS

The analytics engine operates as an extendable interface evaluating the local SwiftData storage layer.

### Angler Totals Panel
- Aggregates total fish counts separated per angler.
- **Filtering Boundaries:** Filterable by a specific reservoir, a specific calendar year, or an unrestricted "All" evaluation window.
- **High-Level Analytics:** Displays total fish landed, total distinct trips, catch-per-trip averages, and mean weight calculations.
- Includes a breakdown of catch frequency grouped by fish species. Species with zero historical catches for the active filter parameters are completely omitted from the layout.

### Reservoir Leaderboard
- Computes a top-10 ledger tracking the heaviest fish captured inside each individual Reservoir boundary.
- Filterable universally by calendar year or across all historical records.
- Outputs a matrix containing Angler identity, Species, precise Weight metrics, and the calendar year of the catch.

### Species Spatial Distribution
- Maps individual species profiles against total volumes landed across different reservoirs.
- Filterable universally by calendar year or across all historical records.

### Temporal Catch Trends
- Prompt-driven interface where selecting a target `Species` renders a monthly distribution chart across a calendar cycle, exposing seasonal trends and high-density catch windows.