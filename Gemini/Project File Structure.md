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
│
└── Gemini/                               # Local reference copies of specifications
    ├── RULES.md
    ├── PROJECT_MEMORY.md
    ├── DATA_MODEL.md
    └── STYLE_GUIDE.md
    └── Project Structure.md