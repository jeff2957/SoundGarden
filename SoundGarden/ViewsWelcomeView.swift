//
//  WelcomeView.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import SwiftUI

/// Welcome screen shown on first launch
struct WelcomeView: View {
    @Bindable var viewModel: SoundScapeViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    @State private var currentPage = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    welcomePage
                        .tag(0)
                    
                    howItWorksPage
                        .tag(1)
                    
                    demoScenesPage
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                // Bottom buttons
                bottomButtons
                    .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
    
    // MARK: - Pages
    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App icon placeholder
            ZStack {
                Circle()
//                    .fill(.tint.gradient)
                    .background(Color.accentColor.gradient)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.2), radius: 20)
            
            VStack(spacing: 12) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text("SoundGarden")
                    .font(.system(size: 44, weight: .bold))
                
                Text("Create immersive spatial audio soundscapes")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var howItWorksPage: some View {
        VStack(spacing: 32) {
            Text("How It Works")
                .font(.largeTitle.bold())
            
            VStack(spacing: 24) {
                FeatureRow(
                    icon: "plus.circle.fill",
                    color: .blue,
                    title: "Add Sounds",
                    description: "Choose from built-in ambient sounds or import your own audio files"
                )
                
                FeatureRow(
                    icon: "hand.draw.fill",
                    color: .green,
                    title: "Position in Space",
                    description: "Drag sound sources around the circular canvas to create your scene"
                )
                
                FeatureRow(
                    icon: "slider.horizontal.3",
                    color: .orange,
                    title: "Fine-Tune",
                    description: "Adjust volume, reverb, and pan for each source individually"
                )
                
                FeatureRow(
                    icon: "headphones",
                    color: .purple,
                    title: "Experience",
                    description: "Enjoy immersive 3D spatial audio with headphones"
                )
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var demoScenesPage: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Try a Demo Scene")
                    .font(.largeTitle.bold())
                
                Text("Start with a pre-configured soundscape")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(DemoScenes.allDemoScenes()) { scene in
                        Button {
                            loadDemoScene(scene)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(scene.name)
                                        .font(.headline)
                                    Text("\(scene.audioSources.count) sound sources")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button {
                        startFromScratch()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Start from Scratch")
                                    .font(.headline)
                                Text("Create your own scene")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "sparkles")
                                .font(.title2)
                        }
                        .padding()
//                        .background(Color.tint.opacity(0.1))
                        .background(Color.accentColor.gradient.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        HStack {
            if currentPage > 0 {
                Button("Back") {
                    withAnimation {
                        currentPage -= 1
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            if currentPage < 2 {
                Button("Next") {
                    withAnimation {
                        currentPage += 1
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Get Started") {
                    startFromScratch()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    // MARK: - Actions
    private func loadDemoScene(_ scene: SoundScene) {
        viewModel.loadScene(scene)
        hasSeenWelcome = true
        dismiss()
    }
    
    private func startFromScratch() {
        hasSeenWelcome = true
        dismiss()
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.gradient)
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView(viewModel: SoundScapeViewModel())
}
