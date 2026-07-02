//
//  CVCardContainer.swift
//  CatchVault
//
//  Created by Kevin Schoen on 7/2/26.
//
import SwiftUI

/// Layer 1 Container Component for CatchVault Visual Architecture.
/// Enforces layout symmetry, custom rendering depth, and continuous edge smoothing.
public struct CVCardContainer<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    
    /// Initializes a standardized structural card layout wrapper.
    /// - Parameters:
    ///   - padding: Inner content bounding margin. Defaults to standard 16pt geometry.
    ///   - content: View builder supplying the enclosed visual layout.
    public init(
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(Color.Canvas.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
