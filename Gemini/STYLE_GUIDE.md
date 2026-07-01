# STYLE_GUIDE.md

## 1. System Intent & Architecture Goals
The core purpose of this style guide is to enforce strict layout, spacing, color, and typographical consistency across all screens in CatchVault. It explicitly eliminates layout divergence between operational transactional screens (e.g., Active Trips, Logging Catches) and high-density statistical views (e.g., Analytics Dashboard, Leaderboards, Angler Totals). 

Every visual block must inherit its constraints directly from the semantic tokens defined below.

---

## 2. Semantic Token System

### 2.1 Color Tokens
Views must avoid referencing absolute platform color primitives (e.g., `Color.blue`, `Color.orange`). All presentation elements must map directly to this semantic matrix:

| Token | Purpose / Context | Light Mode Value | Dark Mode Value |
| :--- | :--- | :--- | :--- |
| `surfacePrimary` | Universal canvas background backdrop | Grouped System (`#F2F2F7`) | Pure Black (`#000000`) |
| `surfaceSecondary` | Base elevated elements / Cards / Matrix rows | White (`#FFFFFF`) | Dark Charcoal (`#1C1C1E`) |
| `surfaceTertiary` | Nested inner rows / Content cells / Selection pills | Light Gray (`#E5E5EA`) | Soft Obsidian (`#2C2C2E`) |
| `brandPrimary` | Navigation targets / Identity / Chrome elements | Deep Navy (`#1A2E40`) | Slate Teal (`#2C4A5E`) |
| `brandAccent` | Primary transaction controls (*Start*, *Record*) | Beacon Amber (`#D97706`) | Electric Amber (`#F59E0B`) |
| `statusActive` | Running background actions / Active live tracking | Emerald (`#16A34A`) | Neon Mint (`#10B981`) |
| `statusLocked` | Concluded history / Read-only / Migrated state | Slate (`#64748B`) | Steel (`#94A3B8`) |
| `textPrimary` | Primary headings, clear labels, critical outputs | `#000000` | `#FFFFFF` |
| `textSecondary` | Subheadings, validation remarks, dynamic metadata | `#3A3A3C` | `#EBEBF5` (60%) |

### 2.2 Typography Scale
Prose labels and structured text configurations utilize standard native proportional typography to optimize readability. Conversely, analytical tallies, weights, spatial coordinate properties, and time tracking readouts must enforce monospaced structural layout designs to ensure vertical text grid symmetry across arrays and list columns.

### swift
import SwiftUI

enum CVFont {
    static let largeHeader = Font.title2.bold()
    static let sectionHeader = Font.headline.weight(.semibold)
    static let rowItem = Font.body
    static let textSecondary = Font.subheadline
    
    // Telemetry Enforcements
    static let telemetryMain = Font.system(.subheadline, design: .monospaced).bold()
    static let telemetryValue = Font.system(.body, design: .monospaced)
    static let metadata = Font.system(.caption, design: .monospaced)
}

### 3. Elevation & Structural Layering Matrix
To systematically eliminate flat designs and prevent sibling interface drift, all screen structural frames must comply with this three-tier depth taxonomy:

Layer 0 (Base Canvas Backdrop): Enforced on full-screen view boundaries or root-level scrolling platforms using surfacePrimary.

Layer 1 (Card Containers / List Blocks): Groups summary components, query arrays, data filters, or standalone graphs using surfaceSecondary.

Corner Radius Invariant: Must configure a corner radius of exactly 12pt using continuous smoothing (.continuous).

Border Separation Rule: Must apply an overlay stroke configuration: .stroke(Color.primary.opacity(0.06), lineWidth: 1).

Layer 2 (Nested Records / Individual Item Cells): Embedded items within a Layer 1 chart container, ledger line item, or detail capsule must select surfaceTertiary.

Corner Radius Invariant: Must configure a corner radius of exactly 8pt using continuous smoothing (.continuous).

### 4. Operational & Tabular Layout Geometry
+---------------------------------------------------------+
|  <- (16pt padding) Screen Border                        |
|                                                         |
|   +-------------------------------------------------+   |
|   |  Layer 1: Card Container (Radius: 12pt)         |   |
|   |  <- (12pt internal padding)                     |   |
|   |                                                 |   |
|   |   +-----------------------------------------+   |   |
|   |   | Layer 2: Nested Row / Cell (Radius: 8pt)|   |   |
|   |   | Height: 44pt (Data) / 50pt (Button)     |   |   |
|   |   +-----------------------------------------+   |   |
|   |                                                 |   |
|   +-------------------------------------------------+   |
+---------------------------------------------------------+
### 4.1 Boundary Padding Constants
Outer Margins: Parent layout scrollviews and safety-area platforms enforce a uniform padding wrapper of 16pt.

Internal Margins: Nested item card element layouts apply an internal border padding constraint of exactly 12pt.

### 4.2 Interactive Target Boundaries
Primary Interactive Control Buttons: Transaction action mechanisms (Start Trip, Record Fish, End and Finalize) must occupy an explicit spatial height profile of exactly 50pt to prioritize clear touch fields.

Secondary Rows & Form Entry Parameters: Table lines, data select matrices, list elements, and inline selection parameters require an explicit operation height window of exactly 44pt.

### 5. Analytics & Data Visualization Enforcements
To anchor reporting and leaderboards into the master layout framework, analytical blocks are strictly banned from deploying disconnected full-screen configurations.

### 5.1 Graph Environments (Temporal Catch Trends, Spatial Distribution Profiles)
Every chart module must reside inside a standardized Layer 1 Card Container. Direct alignment on the Layer 0 Canvas is illegal.

Internal chart grid paths must lock styling visibility using uniform low-opacity values: .foregroundStyle(Color.secondary.opacity(0.15)).

Axis text variables, chart margins, and reference data labels must enforce the CVFont.metadata typography layout.

### 5.2 Tabular Ledgers & Leaderboard Views (High-Density Aggregation Arrays)
Text & Data Alignment: Column matrix headers must lock axis positions with row elements below. Informational strings align left. Numeric telemetry blocks (weights, quantities, trip counts) must align right.

Alternating Row Visuals: To improve ledger column legibility, sequential items must deploy distinct low-opacity alternating row backgrounds using surfaceTertiary or structural dividers instead of standard solid table layouts.

Nesting Rule Invariant: Sub-rows within leaderboard or tally lists must maintain structural vertical heights matching the 44pt row selection target.

### 6. Implementation Reference Blueprint
Use this declarative SwiftUI view layer layout wrapper configuration across the development architecture to enforce layout symmetry:

import SwiftUI

struct CVCardContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(12)
            .background(Color("surfaceSecondary"))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
    }
}