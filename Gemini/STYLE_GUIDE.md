# STYLE_GUIDE.md

## 1. System Intent & Architecture Goals
The core purpose of this style guide is to enforce strict layout, spacing, color, and typographical consistency across all screens in CatchVault. It explicitly eliminates layout divergence between operational transactional screens (e.g., Active Trips, Logging Catches) and high-density statistical views (e.g., Analytics Dashboard, Leaderboards, Angler Totals). 

Every visual block must inherit its constraints directly from the semantic tokens defined below.

---

## 2. Semantic Token System

### 2.1 Color Tokens
Views must avoid referencing absolute platform color primitives (e.g., `Color.blue`, `Color.orange`). All presentation elements must map directly to this semantic matrix:

| Token | Purpose / Context | Light Mode Value | Dark Mode Value | Contrast Rule |
| :--- | :--- | :--- | :--- | :--- |
| `surfacePrimary` | Universal canvas background backdrop | Grouped System (`#F2F2F7`) | Pure Black (`#000000`) | Legacy fallback canvas layer. |
| `backgroundMain` | Universal Layer 0 Canvas Backdrop | Deep Navy (`#10222D`) | Deep Navy (`#10222D`) | Elements resting directly on Layer 0 canvas must render in crisp white. |
| `surfaceSecondary` | Base elevated elements / Cards / Matrix rows | White (`#FFFFFF`) | Dark Charcoal (`#1C1C1E`) | Secondary action controls and input backdrops. |
| `surfaceCard` | Elevated Layer 1 Container Cards | Warm Sand (`#EADEC9`) | Warm Sand (`#EADEC9`) | Remains warm light sand in both appearance modes to retain depth. |
| `surfaceTertiary` | Nested inner rows / Content cells / Selection pills | Light Gray (`#E5E5EA`) | Soft Obsidian (`#2C2C2E`) | Nested row highlights and secondary selection fills. |
| `brandPrimary` | Navigation targets / Identity / Chrome elements | Deep Navy (`#1A2E40`) | Slate Teal (`#2C4A5E`) | Structural chrome and primary header accents. |
| `brandAccent` | Primary transaction controls (*Start*, *Record*) | Beacon Amber (`#D97706`) | Electric Amber (`#F59E0B`) | High-visibility primary action button fill. |
| `statusActive` | Running background actions / Active live tracking | Emerald (`#16A34A`) | Neon Mint (`#10B981`) | Live session status indicators and tracking pills. |
| `statusLocked` | Concluded history / Read-only / Migrated state | Slate (`#64748B`) | Steel (`#94A3B8`) | Concluded history and locked parameters. |
| `textPrimary` | Primary headings, clear labels, critical outputs | `#000000` | `#FFFFFF` | Layer 0 canvas text and navigation bar headings. |
| `textSecondary` | Subheadings, validation remarks, dynamic metadata | `#3A3A3C` | `#EBEBF5` (60%) | Subheadings and dynamic canvas metadata. |
| `textOnCardPrimary` | Primary Titles, Weights, Values inside Sand Cards | Deep Navy (`#10222D`) | Deep Navy (`#10222D`) | Trait-resolved to remain dark slate navy in Dark Mode. |
| `textOnCardSecondary`| Labels, Subtitles, Axis Labels inside Sand Cards | Muted Slate (`#4A5568`) | Muted Slate (`#4A5568`) | Trait-resolved to remain muted slate in Dark Mode. |

### 2.2 Typography Scale
Prose labels and structured text configurations utilize standard native proportional typography to optimize readability. Conversely, analytical tallies, weights, spatial coordinate properties, and time tracking readouts must enforce monospaced structural layout designs to ensure vertical text grid symmetry across arrays and list columns.

```swift
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

3. Elevation, Structural Layering & Contrast Invariants
3.1 Elevation Depth Hierarchy
To systematically eliminate flat designs and prevent sibling interface drift, all screen structural frames must comply with this three-tier depth taxonomy:

Layer 0 (Base Canvas Backdrop): Enforced on full-screen view boundaries or root-level scrolling platforms using Color.backgroundMain (#10222D Deep Slate Navy) or Color.surfacePrimary. Controls resting directly on Layer 0 (e.g., Navigation Titles, CVYearPicker pills, section headers) MUST use crisp white (Color.white or Color.primary in Dark Mode) for maximum contrast.

Layer 1 (Card Containers / List Blocks): Groups summary components, query arrays, data filters, or standalone graphs using CVCardContainer / Color.surfaceCard (#EADEC9 Warm Sand).

Corner Radius Invariant: Must configure a corner radius of exactly 12pt using continuous smoothing (.continuous).

Border Separation Rule: Must apply an overlay stroke configuration: .stroke(Color.primary.opacity(0.06), lineWidth: 1).

Color Invariant: surfaceCard remains a warm light sand surface in both Light Mode and Dark Mode to maintain tactile depth.

Layer 2 (Nested Records / Individual Item Cells): Embedded items within a Layer 1 chart container, ledger line item, or detail capsule select Color.surfaceTertiary or low-opacity dark slate fills (Color.surfaceSecondary.opacity(0.12–0.15)).

Corner Radius Invariant: Must configure a corner radius of exactly 8pt using continuous smoothing (.continuous).

3.2 Light & Dark Mode Contrast Rules
Rule 1: Card-Scoped Trait-Resolved Text Tokens

Because Layer 1 card containers (CVCardContainer / Color.surfaceCard) retain a light sand background in both Light Mode and Dark Mode, standard system text modifiers (Color.primary and Color.secondary) MUST NOT be used inside cards. System primary/secondary text flips to solid white in Dark Mode, creating illegible low contrast on sand cards. All text, numbers, icons, and dividers inside CVCardContainer must explicitly bind to Color.textOnCardPrimary or Color.textOnCardSecondary.

Rule 2: Explicit Text Field & Multiline Prompt Locking

Standard SwiftUI TextField and text editor prompts automatically inherit system dark-mode opacity rules, turning faint gray or white in Dark Mode. Text fields sitting inside cards must explicitly style their input text and prompt parameters, and avoid native .textFieldStyle(.roundedBorder) (which injects system dark backgrounds in Dark Mode):

Swift
TextField(
    "",
    text: $inputText,
    prompt: Text("Placeholder...").foregroundStyle(Color.textOnCardSecondary.opacity(0.6))
)
.foregroundStyle(Color.textOnCardPrimary)
.padding(.horizontal, 10)
.padding(.vertical, 8)
.background(Color.surfaceSecondary.opacity(0.15))
.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
Rule 3: Swift Charts Axis Labeling

Swift Charts (Chart) default to system AxisValueLabel colors, which turn white in Dark Mode. All chart X-axis and Y-axis marks rendered inside cards must explicitly apply Color.textOnCardSecondary:

Swift
.chartXAxis {
    AxisMarks(position: .bottom) { _ in
        AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
            .foregroundStyle(Color.textOnCardSecondary.opacity(0.15))
        AxisValueLabel()
            .foregroundStyle(Color.textOnCardSecondary)
    }
}
.chartYAxis {
    AxisMarks(position: .leading) { _ in
        AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
            .foregroundStyle(Color.textOnCardSecondary.opacity(0.15))
        AxisValueLabel()
            .foregroundStyle(Color.textOnCardSecondary)
    }
}
4. Operational & Tabular Layout Geometry
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
4.1 Boundary Padding Constants
Outer Margins: Parent layout scrollviews and safety-area platforms enforce a uniform padding wrapper of 16pt.

Internal Margins: Nested item card element layouts apply an internal border padding constraint of exactly 12pt.

4.2 Interactive Target Boundaries
Primary Interactive Control Buttons: Transaction action mechanisms (Start Trip, Record Fish, End and Finalize) must occupy an explicit spatial height profile of exactly 50pt to prioritize clear touch fields.

Secondary Rows & Form Entry Parameters: Table lines, data select matrices, list elements, and inline selection parameters require an explicit operation height window of exactly 44pt.

5. Analytics & Data Visualization Enforcements
To anchor reporting and leaderboards into the master layout framework, analytical blocks are strictly banned from deploying disconnected full-screen configurations.

5.1 Graph Environments (Temporal Catch Trends, Spatial Distribution Profiles)
Every chart module must reside inside a standardized Layer 1 Card Container. Direct alignment on the Layer 0 Canvas is illegal.

Internal chart grid paths must lock styling visibility using uniform low-opacity values: .foregroundStyle(Color.textOnCardSecondary.opacity(0.15)).

Axis text variables, chart margins, and reference data labels must enforce the CVFont.metadata typography layout and explicitly declare .foregroundStyle(Color.textOnCardSecondary).

5.2 Tabular Ledgers & Leaderboard Views (High-Density Aggregation Arrays)
Text & Data Alignment: Column matrix headers must lock axis positions with row elements below. Informational strings align left. Numeric telemetry blocks (weights, quantities, trip counts) must align right.

Alternating Row Visuals: To improve ledger column legibility, sequential items must deploy distinct low-opacity alternating row backgrounds using surfaceTertiary or structural dividers instead of standard solid table layouts.

Nesting Rule Invariant: Sub-rows within leaderboard or tally lists must maintain structural vertical heights matching the 44pt row selection target.

6. Implementation Reference Blueprint
Use this declarative SwiftUI view layer layout wrapper configuration across the development architecture to enforce layout symmetry:

Swift
import SwiftUI

struct CVCardContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(12)
            .background(Color("surfaceCard"))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
    }
}