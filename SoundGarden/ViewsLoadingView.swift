//
//  LoadingView.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import SwiftUI

/// Loading indicator for async operations
struct LoadingView: View {
    let message: String
    
    init(_ message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 10)
    }
}

/// Audio wave animation for playing sources
struct AudioWaveView: View {
    let isPlaying: Bool
    let color: Color
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 2)
                        .scaleEffect(isPlaying ? 1.0 + CGFloat(index) * 0.3 : 0.5)
                        .opacity(isPlaying ? 0 : 0.5)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.3),
                            value: isPlaying
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

/// Empty state view
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: action) {
                Text(actionTitle)
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
//                    .background(.tint)
                    .background(Color.accentColor.gradient)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
}

/// Error view with retry option
struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            VStack(spacing: 8) {
                Text("Something Went Wrong")
                    .font(.headline)
                
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.tint)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

// MARK: - Previews
#Preview("Loading") {
    LoadingView("Loading audio files...")
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "music.note.list",
        title: "No Audio Sources",
        message: "Add your first sound source to create a soundscape",
        actionTitle: "Add Sound"
    ) {
        print("Add tapped")
    }
}

#Preview("Error") {
    ErrorView(error: AppError.audioEngineFailure("Failed to start")) {
        print("Retry tapped")
    }
}

#Preview("Audio Wave") {
    AudioWaveView(isPlaying: true, color: .blue)
        .frame(width: 100, height: 100)
}
