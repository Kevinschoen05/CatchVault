//
//  Colors.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/2/26.
//
import SwiftUI
import UIKit

public extension Color {
    /// Semantic Design Tokens for CatchVault Layout Architecture
    /// Theme Profile: Lakeside Utility (Rugged & Professional Outdoor Optimization)
    struct Canvas {
        /// Low-glare canvas base: Matte Light Gray (#EBF0F2) / Deep Slate Mud (#12181A)
        public static let surfacePrimary = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: "12181A") : UIColor(hex: "EBF0F2")
        })
        
        /// Elevated container backgrounds (Cards, rows): Crisp Sand-White (#FFFFFF) / Dark Charcoal Charcoal (#1C2326)
        public static let surfaceSecondary = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: "1C2326") : UIColor.white
        })
        
        /// Embedded selection elements & table dividers: Light Silver Pebble (#DDE4E7) / Soft Obsidian Shadow (#2A3438)
        public static let surfaceTertiary = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: "2A3438") : UIColor(hex: "DDE4E7")
        })
        
        /// Navigation frames, headers, identity layout: Deep Maritime Blue (#1C354D) / Glacial Teal Blue (#3A5D7C)
        public static let brandPrimary = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: "3A5D7C") : UIColor(hex: "1C354D")
        })
        
        /// Transaction critical actions (Start, Record, Save): High-Visibility Safety Orange (#E65C00) / Vivid Beacon Amber (#FF7518)
        public static let brandAccent = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: "FF7518") : UIColor(hex: "E65C00")
        })
        
        /// Active background tracking state / Live session indications: Forest Pine Green (#1E5631) / Neon Moss Green (#4E9F3D)
        public static let statusActive = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: "4E9F3D") : UIColor(hex: "1E5631")
        })
    }
}

// MARK: - Private Hex Serialization Helper
private extension UIColor {
    convenience init(hex: String) {
        let hexClean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hexClean).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexClean.count {
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
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
