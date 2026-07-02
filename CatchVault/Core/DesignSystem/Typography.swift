//
//  Typography.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/2/26.
//
import SwiftUI

/// Semantic Typographical Layout Design Tokens for CatchVault
/// Built to guarantee legibility under outdoor environmental constraints.
public struct CVFont {
    
    /// Giant numeric telemetry readout (e.g., live running trip timers or massive catch weights)
    /// Enforces monospaced numeric tracking to avoid layout shaking during value mutations.
    public static let telemetryHeavy: Font = {
        Font.system(size: 34, weight: .bold, design: .rounded)
            .monospacedDigit()
    }()
    
    /// Standard row numeric vectors (e.g., column tallies, weights, quantities in ledgers)
    /// Enforces monospaced numeric tracking to guarantee absolute column alignment.
    public static let telemetryMedium: Font = {
        Font.system(size: 18, weight: .semibold, design: .rounded)
            .monospacedDigit()
    }()
    
    /// Primary header navigation views and high-level card section labels
    public static let sectionHeader: Font = {
        Font.system(size: 20, weight: .bold, design: .rounded)
    }()
    
    /// Base list content titles, entity identification fields, and descriptive forms
    public static let primaryBody: Font = {
        Font.system(size: 16, weight: .regular, design: .rounded)
    }()
    
    /// Interactive button strings and action target highlights (locks text focus)
    public static let actionLabel: Font = {
        Font.system(size: 16, weight: .semibold, design: .rounded)
    }()
    
    /// Low-density context labels, timestamp stamps, chart axes variables, and reference metrics
    public static let metadata: Font = {
        Font.system(size: 12, weight: .medium, design: .rounded)
    }()
}

// MARK: - View Modifiers for Declarative Ergonomics
public extension View {
    /// Enforces a standardized semantic CVFont onto a SwiftUI hierarchy
    @ViewBuilder
    func cvFont(_ font: Font) -> some View {
        self.font(font)
    }
}
