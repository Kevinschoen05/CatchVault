//
//  FullScreenPhotoViewer.swift
//

import SwiftUI

public struct FullScreenPhotoViewer: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    public init(image: UIImage) {
        self.image = image
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale = min(max(scale * delta, 1.0), 4.0)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            if scale < 1.0 {
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    offset = .zero
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    TapGesture(count: 2).onEnded {
                        withAnimation(.spring()) {
                            if scale > 1.5 {
                                scale = 1.0
                                offset = .zero
                            } else {
                                scale = 2.5
                            }
                        }
                    }
                )
            
            // Close Action Button Overlay
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.white.opacity(0.8))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
