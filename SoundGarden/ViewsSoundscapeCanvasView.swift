//
//  SoundscapeCanvasView.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import SwiftUI

/// Interactive circular canvas showing spatial audio sources
struct SoundscapeCanvasView: View {
    @Bindable var viewModel: SoundScapeViewModel
    
    @State private var canvasSize: CGSize = .zero
    @State private var draggedSourceID: UUID?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                RadialGradient(
                    colors: [
                        Color(uiColor: .systemBackground),
                        Color(uiColor: .secondarySystemBackground)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: geometry.size.width / 2
                )
                .ignoresSafeArea()
                
                // Spatial field visualization
                spatialFieldView(size: geometry.size)
                
                // Audio sources
                ForEach(viewModel.audioSources) { source in
                    audioSourceNode(
                        source: source,
                        canvasSize: geometry.size,
                        circleRadius: viewModel.currentScene.circleRadius
                    )
                }
                
                // User avatar at center
                userAvatarView
            }
            .onAppear {
                canvasSize = geometry.size
            }
        }
    }
    
    // MARK: - Spatial Field View
    @ViewBuilder
    private func spatialFieldView(size: CGSize) -> some View {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = viewModel.currentScene.circleRadius

        ZStack {
            if #available(iOS 26.0, *) {
                liquidGlassField(center: center, radius: radius)
            } else {
                legacyField(center: center, radius: radius)
            }

            // Cardinal direction indicators
            directionIndicators(center: center, radius: radius)
        }
    }

    /// Three concentric Liquid Glass planes: outer boundary at the bottom, innermost ring on top.
    @available(iOS 26.0, *)
    private func liquidGlassField(center: CGPoint, radius: CGFloat) -> some View {
        GlassEffectContainer {
            ZStack {
                // Outer plane (bottom layer)
                Circle()
                    .fill(.clear)
                    .frame(width: radius * 2, height: radius * 2)
                    .glassEffect(.regular, in: Circle())
                    .position(center)

                // Middle plane
                Circle()
                    .fill(.clear)
                    .frame(width: radius * 2 * 0.66, height: radius * 2 * 0.66)
                    .glassEffect(.regular, in: Circle())
                    .position(center)

                // Inner plane (top layer)
                Circle()
                    .fill(.clear)
                    .frame(width: radius * 2 * 0.33, height: radius * 2 * 0.33)
                    .glassEffect(.regular, in: Circle())
                    .position(center)
            }
        }
    }

    private func legacyField(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            // Outer circle boundary
            Circle()
                .stroke(Color.primary.opacity(0.2), lineWidth: 2)
                .frame(width: radius * 2, height: radius * 2)
                .position(center)

            // Inner distance rings
            ForEach([0.33, 0.66], id: \.self) { ratio in
                Circle()
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    .frame(width: radius * 2 * ratio, height: radius * 2 * ratio)
                    .position(center)
            }
        }
    }
    
    @ViewBuilder
    private func directionIndicators(center: CGPoint, radius: CGFloat) -> some View {
        let directions: [(String, CGFloat)] = [
            ("N", 0),
            ("E", 90),
            ("S", 180),
            ("W", 270)
        ]
        
        ForEach(directions, id: \.0) { label, angle in
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .position(
                    x: center.x + (radius + 20) * cos((angle - 90) * .pi / 180),
                    y: center.y + (radius + 20) * sin((angle - 90) * .pi / 180)
                )
        }
    }
    
    // MARK: - User Avatar
    private var userAvatarView: some View {
        ZStack {
            Circle()
                .fill(.tint)
                .frame(width: 40, height: 40)

            Image(systemName: "person.fill")
                .font(.title3)
                .foregroundStyle(.white)
        }
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Audio Source Node
    @ViewBuilder
    private func audioSourceNode(
        source: AudioSource,
        canvasSize: CGSize,
        circleRadius: CGFloat
    ) -> some View {
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let position = CGPoint(
            x: center.x + source.position.x,
            y: center.y + source.position.y
        )
        
        let isSelected = viewModel.selectedSource?.id == source.id
        let isDragging = draggedSourceID == source.id
        
        ZStack {
            // Outer glow when playing
            if source.isPlaying {
                PulsingGlowView(color: source.color.color, isSelected: isSelected)
            }
            
            // Main node
            Circle()
                .fill(source.color.color.gradient)
                .frame(width: 44, height: 44)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: isSelected ? 3 : 2)
                }
            
            // Icon
            Image(systemName: source.isPlaying ? "speaker.wave.3.fill" : "speaker.fill")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            
            // Label
            if !isDragging {
                Text(source.name)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .offset(y: 35)
            }
        }
        .scaleEffect(isDragging ? 1.2 : (isSelected ? 1.1 : 1.0))
        .shadow(color: .black.opacity(0.3), radius: isDragging ? 12 : 8)
        .position(position)
        .gesture(
            DragGesture()
                .onChanged { value in
                    draggedSourceID = source.id
                    
                    // Convert to relative position from center
                    let newPosition = CGPoint(
                        x: value.location.x - center.x,
                        y: value.location.y - center.y
                    )
                    
                    viewModel.updateSourcePosition(id: source.id, position: newPosition)
                }
                .onEnded { _ in
                    draggedSourceID = nil
                }
        )
        .onTapGesture {
            withAnimation(AppConstants.springAnimation) {
                viewModel.selectSource(id: source.id)
            }
        }
        .animation(AppConstants.springAnimation, value: isSelected)
        .animation(AppConstants.springAnimation, value: isDragging)
        .animation(AppConstants.springAnimation, value: source.position)
    }
}

#Preview {
    SoundscapeCanvasView(viewModel: SoundScapeViewModel())
}

// MARK: - Pulsing Glow
/// Isolated so its infinite repeatForever animation doesn't leak into sibling gestures (e.g. slider drags).
private struct PulsingGlowView: View {
    let color: Color
    let isSelected: Bool

    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .frame(width: 60, height: 60)
            .scaleEffect((isSelected ? 1.2 : 1.0) * (isPulsing ? 1.15 : 1.0))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            .onDisappear {
                isPulsing = false
            }
    }
}
