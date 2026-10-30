//
//  SettingsView.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import SwiftUI

/// Settings and scene management view
struct SettingsView: View {
    @Bindable var viewModel: SoundScapeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showNewSceneDialog = false
    @State private var newSceneName = ""
    @State private var showSaveConfirmation = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationStack {
            Form {
                // Current Scene Section
                currentSceneSection

                // Scene Management
                sceneManagementSection

                // Appearance
                appearanceSection

                // Audio Settings
                audioSettingsSection

                // About
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("New Scene", isPresented: $showNewSceneDialog) {
                TextField("Scene name", text: $newSceneName)
                Button("Cancel", role: .cancel) {
                    newSceneName = ""
                }
                Button("Create") {
                    createNewScene()
                }
            } message: {
                Text("Create a new sound scene")
            }
            .alert("Scene Saved", isPresented: $showSaveConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your scene has been saved successfully")
            }
        }
    }
    
    // MARK: - Current Scene Section
    private var currentSceneSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.currentScene.name)
                        .font(.headline)
                    
                    Text("\(viewModel.audioSources.count) audio source\(viewModel.audioSources.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "music.note.list")
                    .font(.title2)
                    .foregroundStyle(.tint)
            }
            
            Button {
                saveCurrentScene()
            } label: {
                Label("Save Scene", systemImage: "square.and.arrow.down")
            }
        } header: {
            Text("Current Scene")
        }
    }
    
    // MARK: - Scene Management
    private var sceneManagementSection: some View {
        Section {
            Button {
                showNewSceneDialog = true
            } label: {
                Label("New Scene", systemImage: "plus.circle")
            }
            
            Button {
                clearCurrentScene()
            } label: {
                Label("Clear All Sources", systemImage: "trash")
            }
            .foregroundStyle(.red)
            .disabled(viewModel.audioSources.isEmpty)
            
        } header: {
            Text("Scene Management")
        } footer: {
            Text("Create a new scene or clear the current one to start fresh")
        }
    }
    
    // MARK: - Appearance
    private var appearanceSection: some View {
        Section {
            Toggle(isOn: $isDarkMode) {
                Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
            }
        } header: {
            Text("Appearance")
        }
    }

    // MARK: - Audio Settings
    private var audioSettingsSection: some View {
        Section {
            HStack {
                Text("Audio Sources")
                Spacer()
                Text("\(viewModel.audioSources.count) / \(AppConstants.maxAudioSources)")
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("Circle Radius")
                Spacer()
                Text("\(Int(viewModel.currentScene.circleRadius)) pt")
                    .foregroundStyle(.secondary)
            }
            
            Toggle("Audio Engine Running", isOn: .constant(viewModel.audioEngine.isEngineRunning))
                .disabled(true)
            
        } header: {
            Text("Audio Configuration")
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            
            Link(destination: URL(string: "https://apple.com")!) {
                HStack {
                    Text("Support")
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
        } header: {
            Text("About")
        } footer: {
            Text("SoundGarden - Spatial Audio Scene Creator\n© 2026 All rights reserved")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Actions
    private func saveCurrentScene() {
        do {
            try viewModel.saveScene()
            showSaveConfirmation = true
        } catch {
            print("Failed to save scene: \(error)")
        }
    }
    
    private func createNewScene() {
        let sceneName = newSceneName.isEmpty ? "New Scene" : newSceneName
        viewModel.newScene(name: sceneName)
        newSceneName = ""
        dismiss()
    }
    
    private func clearCurrentScene() {
        viewModel.stopAllSources()
        viewModel.currentScene.audioSources.forEach { source in
            viewModel.removeAudioSource(id: source.id)
        }
    }
}

#Preview {
    SettingsView(viewModel: SoundScapeViewModel())
}
