# CatchVault — Project Memory & State

## 1. System Intent & Mission
* **Objective:** Evolve a 5-year-old production web application ("Reservoir Fishing") into an optimized, local-first, native iOS application built with SwiftUI and SwiftData.
* **Key Vectors:**
    * Leverage native hardware & platform capabilities (MapKit, local notifications, background timers, push notifications).
    * Modernize and optimize the UI/UX using a strict declarative, state-driven paradigm.
    * Implement a highly resilient, offline-ready local database configuration mapped cleanly to iCloud via CloudKit.

## 2. Architectural Baseline (Iteration 0)
* **Data Persistence:** SwiftData acts as the absolute on-device engine and local source of truth. Programmatic `try context.save()` boundaries are explicitly enforced during data operations to avoid relying on unstable implicit container cycles.
* **Ingestion Strategy:** Static text data migration from production MongoDB exports via an intentional, chunked, heavily validated `MigrationManager` acting as an Anti-Corruption Layer (ACL).
* **Codebase Posture:** Clean greenfield implementation utilizing CatchVault V1 models as structural blueprints, rewritten to enforce strict multi-entity inverse macros and deterministic data laws.

## 3. Project Documentation Matrix
The project state is governed by six core reference files, which serve as our absolute test oracles and architectural guidelines:
1. `RULES.md`: Enforces system posture, conversational constraints, development practices, and strict communication invariants.
2. `PROJECT_MEMORY.md`: (This file) Tracks system evolution, architectural milestones, active state parameters, and strategic development progress.
3. `USER_REQUIREMENTS_v1.md`: Outlines the active transactional workflows, operational logging constraints, metrics calculations, and visual charts paradigms.
4. `DATA_MODEL.md`: Defines the precise schema configurations, relationship properties, cascade rules, and on-device deduplication requirements.
5. `STYLE_GUIDE.md`: Formally codifies semantic design tokens, color constraints, typographical configurations, and high-density layout rules.
6. `Project Structure.md`: Mandates physical group separation within the Xcode workspace to isolate the domain logic from presentation and migration layers.

## 4. Physical Group & File Structure
To maintain clean boundaries and prevent compilation leakages, the greenfield Xcode project strictly follows this directory layout:
```text
CatchVault/
│
├── App/
│   └── CatchVaultApp.swift             # Core entry point, ModelContainer setup
│
├── Core/
│   ├── DesignSystem/
│   │   ├── Colors.swift                # Semantic Color Tokens (surfacePrimary, etc.)
│   │   ├── Typography.swift            # CVFont structures
│   │   └── Components/
│   │       └── CVCardContainer.swift   # Layer 1 layout container wrapper
│   │
│   └── Infrastructure/
│       ├── LocationService.swift       # GPS tracking shell
│       └── WeatherService.swift        # Weather serialization framework
│
├── Domain/
│   └── Models/
│       ├── Angler.swift                # @Model definition
│       ├── Reservoir.swift             # @Model definition
│       ├── Species.swift               # @Model definition
│       ├── Trip.swift                  # @Model definition
│       └── FishCatch.swift             # @Model definition
│
├── Features/
│   ├── Migration/
│   │   ├── MigrationManager.swift      # Anti-Corruption Ingestion Layer
│   │   └── Models/
│   │       └── LegacyPayload.swift     # Decodable variants & structures
│   │
│   ├── ActiveTrip/                     # Live Logging Transactional Workflow
│   │   ├── ActiveTripView.swift
│   │   └── ActiveTripViewModel.swift
│   │
│   └── Analytics/                      # High-Density Diagnostic Views
│       ├── AnglerTotalsView.swift
│       ├── ReservoirLeaderboardView.swift
│       └── TemporalTrendsView.swift