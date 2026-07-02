CatchVault/
│
├── App/
│   └── CatchVaultApp.swift             # Program entry point, App Session check
│
├── Core/
│   ├── DesignSystem/
│   │   ├── Colors.swift                # Semantic Color Design Tokens
│   │   ├── Typography.swift            # CVFont configuration matrices
│   │   └── Components/
│   │       └── CVCardContainer.swift   # Layer 1 card presentation frame
│   │
│   └── Infrastructure/
│       ├── LocationService.swift       # CoreLocation tracking framework
│       └── WeatherService.swift        # Aggregated weather serialization
│
├── Domain/
│   └── Models/                         # SwiftData Schema Bedrock
│       ├── Angler.swift
│       ├── Reservoir.swift
│       ├── Species.swift
│       ├── Trip.swift
│       └── FishCatch.swift
│
└── Features/                           # Flattened operational view modules
    ├── Migration/
    │   ├── MigrationManager.swift      # Ingestion Engine
    │   └── LegacyPayload.swift         # Polymorphic decoders
    │
    ├── ReservoirHome/                  # Main Dashboard Group
    │   ├── ReservoirHomeView.swift
    │   └── ReservoirHomeViewModel.swift
    │
    ├── ReservoirDetails/               # Reservoir History ledger
    │   ├── ReservoirDetailsView.swift
    │   └── ReservoirDetailsViewModel.swift
    │
    ├── AddReservoir/                   # Reservoir Creation Form
    │   └── AddReservoirView.swift
    │
    ├── ActiveTrip/                     # Persistent Core Session Log
    │   ├── ActiveTripView.swift
    │   └── ActiveTripViewModel.swift
    │
    ├── StartTrip/                      # Ingestion Launchpad View
    │   └── StartTripView.swift
    │
    ├── RecordFish/                     # Telemetry Ingestion Form View
    │   └── RecordFishView.swift
    │
    ├── EndTrip/                        # Session Closeout Workflow
    │   └── EndTripView.swift
    │
    └── Analytics/                      # Read-Heavy Diagnostic Views
        ├── AnalyticsDashboardView.swift
        ├── AnglerTotalsView.swift
        ├── ReservoirLeaderboardView.swift
        ├── SpeciesBreakdownView.swift
        └── CatchTrendsView.swift
│
└── Gemini/                               # Local reference copies of specifications
    ├── RULES.md
    ├── PROJECT_MEMORY.md
    ├── DATA_MODEL.md
    └── STYLE_GUIDE.md
    └── Project Structure.md