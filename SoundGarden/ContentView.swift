//
//  ContentView.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = SoundScapeViewModel()
    @State private var showAudioLibrary = false
    @State private var showSettings = false
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showWelcome = false
    
    var body: some View {
        ZStack {
            // Main canvas
            SoundscapeCanvasView(viewModel: viewModel)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        viewModel.deselectSource()
                    }
                }
            
            // Overlay UI
            VStack {
                // Top toolbar
                topToolbar
                
                Spacer()
                
                // Control panel (bottom sheet)
                if let selectedSource = viewModel.selectedSource {
                    AudioControlPanelView(viewModel: viewModel, source: selectedSource)
                        .frame(maxHeight: 500)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Quick controls when no source selected
                    quickControlsBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedSource?.id)
        }
        .sheet(isPresented: $showAudioLibrary) {
            AudioLibraryView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showWelcome) {
            WelcomeView(viewModel: viewModel)
        }
        .onAppear {
            if !hasSeenWelcome {
                showWelcome = true
            }
        }
    }
    
    // MARK: - Top Toolbar
    private var topToolbar: some View {
        HStack {
            // Scene name
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.currentScene.name)
                    .font(.headline)
                
                Text("\(viewModel.audioSources.count) source\(viewModel.audioSources.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Master play/pause
            Button {
                if viewModel.isPlaying {
                    viewModel.stopAllSources()
                } else {
                    viewModel.playAllSources()
                }
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.tint)
            }
            .disabled(viewModel.audioSources.isEmpty)
            
            // Settings
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gear")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8)
        .padding()
    }
    
    // MARK: - Quick Controls Bar
    private var quickControlsBar: some View {
        HStack(spacing: 16) {
            // Add source button
            Button {
                showAudioLibrary = true
            } label: {
                Label("Add Sound", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
//                    .background(.tint.gradient)
                    .background(Color.accentColor.gradient)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            // Source count indicator (if any exist)
            if !viewModel.audioSources.isEmpty {
                VStack(spacing: 4) {
                    Text("\(viewModel.audioSources.count)")
                        .font(.title2.bold())
                    Text(viewModel.audioSources.count == 1 ? "Source" : "Sources")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 80)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 8)
        .padding()
    }
}

#Preview {
    ContentView()
}
