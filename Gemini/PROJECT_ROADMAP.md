CatchVault Development Roadmap Checklist
🟩 Milestone 1: Core Domain Engine
Build the data layer bedrock first. Views cannot exist without valid, persistence-ready state containers.

[ ] 1.1 Entity Layout Initialization

Create the five baseline SwiftData files in Domain/Models/: Angler.swift, Reservoir.swift, Species.swift, Trip.swift, FishCatch.swift.

[ ] 1.2 Relationship & CloudKit Rule Enforcement

Apply explicit @Relationship(inverse: ...) macro ownership chains.

Structure all post-initialization attributes as optional primitives or assign explicit defaults in constructors.

[ ] 1.3 Cascade Validation Layer

Author schema integration verification unit tests to guarantee operational constraints (e.g., purging a Trip sweeps all associated FishCatch records; deleting a Reservoir safely nullifies relational references).

🟩 Milestone 2: Data Ingestion Pipeline (Anti-Corruption Bridge)
Establish secure, transaction-safe data boundaries before exposing ingestion layers to user input frameworks.

[ ] 2.1 Legacy Payload Decoders

Implement polymorphic decoders inside Features/Migration/Models/ to consume raw JSON formats (such as double/string variance variants for weights).

[ ] 2.2 Deterministic Trip Aggregator

Program the token-generation logic (YYYY-MM-DD-ReservoirName) that clusters floating legacy catch stamps into valid on-device synthetic parent Trip objects.

[ ] 2.3 Chunked Migration Executer

Implement the single-use MigrationManager pipeline using explicit try context.save() batch transactional constraints to completely neutralize memory performance tax.

[ ] 2.4 Deduplication Guardrails

Build validation mechanisms inside the active context to guarantee identity normalization (case-insensitive trim scans for Angler, Reservoir, and Species).

🟩 Milestone 3: Foundation Core Mechanics & Design Tokens
Unify your visual identity and telemetry engines so operational layouts look uniform.

[ ] 3.1 Semantic Token Layer

Implement the system colors (surfacePrimary, brandAccent, etc.) and font metrics structures directly matching STYLE_GUIDE.md.

[ ] 3.2 Custom UI Container Structure

Deploy the Layer 1 CVCardContainer container blueprint across layout files.

[ ] 3.3 Infrastructure Service Proxies

Author CoreLocation hardware location boundaries and build out weather data serialization engines.

🟩 Milestone 4: Operational Transactional Workflows (Live Logs)
Construct the data-mutation layer where active calculations occur in real time.

[ ] 4.1 Background Active Trip Timer

Program background mechanics to accurately monitor active session durations.

[ ] 4.2 Form Layout & Target Sizing Boundaries

Build input form components honoring 44pt target geometries.

[ ] 4.3 Direct Context Synchronization

Enforce atomic persistence rules that save entry parameters into local storage contexts right at transaction completion points.

🟩 Milestone 5: High-Density Analytical Views & Dashboards
Build read-heavy visualization models. Analytics are read-only windows processing the local database engine.

[ ] 5.1 Chart Layout Engine Implementation

Build layout parameters for the temporal trend charts using low-opacity graphic grid lines (opacity(0.15)).

[ ] 5.2 Tabular Ledger Realignment

Structure ledger components (Angler Totals, Leaderboards) using string-left and numeric telemetry right-aligned columns.

[ ] 5.3 Query Predicate Constraints

Optimize data queries using focused target predicates to evaluate local data matrices dynamically without missing feature tracking code contexts.