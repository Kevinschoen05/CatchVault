//
//  SpeciesColorProvider.swift
//  CatchVault
//
//  Created by Kevin Schoen on 10/8/26.
//

import SwiftUI

enum SpeciesColorProvider {
    // 1. Curated palette for high-frequency species
    private static let predefinedColors: [String: Color] = [
        "large mouth bass": Color(hex: "#10B981"), // Emerald Green
        "small mouth bass": Color(hex: "#8B5CF6"), // Purple / Violet
        "pickerel":         Color(hex: "#F59E0B"), // Amber / Orange
        "perch":            Color(hex: "#EAB308"), // Gold / Yellow
        "sunny":            Color(hex: "#06B6D4"), // Cyan
        "rock bass":        Color(hex: "#EC4899"), // Pink / Rose
        "white bass":       Color(hex: "#3B82F6")  // Blue
    ]
    
    // 2. Curated pool of high-contrast fallback colors for dynamic/new species
    private static let fallbackPalette: [Color] = [
        Color(hex: "#EF4444"), // Red
        Color(hex: "#14B8A6"), // Teal
        Color(hex: "#6366F1"), // Indigo
        Color(hex: "#84CC16"), // Lime
        Color(hex: "#F97316"), // Deep Orange
        Color(hex: "#D946EF")  // Fuchsia
    ]
    
    /// Resolves a consistent pin color for any species.
    static func color(for speciesName: String?) -> Color {
        guard let name = speciesName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !name.isEmpty else {
            return Color.secondary // Neutral fallback for unclassified catches
        }
        
        // Return explicit color if mapped
        if let color = predefinedColors[name] {
            return color
        }
        
        // Deterministic fallback based on name hash algorithm
        let hashIndex = abs(name.hashValue) % fallbackPalette.count
        return fallbackPalette[hashIndex]
    }
}

private extension Color {
    init(hex: String) {
        let hexCleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexCleaned).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hexCleaned.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}
