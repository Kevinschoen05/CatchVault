//
//  Colors.swift
//  CatchVault
//

import SwiftUI
import UIKit

public extension Color {
    // MARK: - Card-Scoped Semantic Tokens
    
    /// Primary high-contrast text color for elements resting inside surfaceCard (Deep Navy Slate)
    static let textOnCardPrimary = Color(uiColor: UIColor { _ in
        // surfaceCard remains warm light sand in both Light and Dark modes, so text on card stays deep navy
        return UIColor(red: 16/255.0, green: 34/255.0, blue: 45/255.0, alpha: 1.0)
    })
    
    /// Secondary label and icon color for elements resting inside surfaceCard (Muted Slate)
    static let textOnCardSecondary = Color(uiColor: UIColor { _ in
        return UIColor(red: 74/255.0, green: 85/255.0, blue: 104/255.0, alpha: 1.0)
    })
}
