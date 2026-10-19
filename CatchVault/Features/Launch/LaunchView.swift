//
//  LaunchView.swift
//  CatchVault
//  Path: CatchVault/Features/Launch/LaunchView.swift
//

import SwiftUI

public struct LaunchView: View {
    @Binding var isAnimating: Bool
    
    // Scale and Opacity state properties
    @State private var emblemScale: CGFloat = 0.75
    @State private var emblemOpacity: Double = 0.0
    
    // Radar Pulse State Properties
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.8
    
    // Typography tracking
    @State private var trackingAmount: CGFloat = 2.0
    
    public init(isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
    }
    
    public var body: some View {
        ZStack {
            // Layer 0 Base Canvas Backdrop
            Color.backgroundMain
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                ZStack {
                    // Radar Pulse Ring (Expands & Fades Out)
                    Circle()
                        .stroke(Color.brandAccent.opacity(pulseOpacity), lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseScale)
                    
                    // Center Emblem Mark
                    Image("CatchVaultEmblem")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .scaleEffect(emblemScale)
                        .opacity(emblemOpacity)
                }
                
                // Monospaced Branded Title
                Text("CATCHVAULT")
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.brandAccent)
                    .tracking(trackingAmount)
                    .opacity(emblemOpacity)
            }
        }
        .onAppear {
            print("🚀 [LAUNCH DEBUG] LaunchView successfully mounted on screen!")
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        print("📍 [LAUNCH DEBUG] Starting pulse and scale sequence...")
        
        // Dispatch slightly after mount to guarantee frame 0 renders before animating
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            // 1. Spring in emblem and tracking letter-spacing
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                emblemScale = 1.0
                emblemOpacity = 1.0
                trackingAmount = 6.0
            }
            
            // 2. Continuous repeating radar pulse expansion
            withAnimation(
                .easeOut(duration: 1.2)
                .repeatForever(autoreverses: false)
            ) {
                pulseScale = 1.9
                pulseOpacity = 0.0
            }
            
            // 3. Complete launch sequence after 1.8s and dismiss overlay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                print("🏁 [LAUNCH DEBUG] Handing off to main dashboard...")
                withAnimation(.easeInOut(duration: 0.35)) {
                    isAnimating = false
                }
            }
        }
    }
}
