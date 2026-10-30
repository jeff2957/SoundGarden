//
//  AudioLibraryView.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import SwiftUI
import UniformTypeIdentifiers

/// View for selecting and managing audio files
struct AudioLibraryView: View {
    @Bindable var viewModel: SoundScapeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showFilePicker = false
    @State private var selectedPreset: BuiltInSound?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Import from files
                    importSection
                    
                    // Built-in sounds
                    builtInSoundsSection
                }
                .padding()
            }
            .navigationTitle("Audio Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
        }
    }
    
    // MARK: - Import Section
    private var importSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import Audio")
                .font(.headline)
            
            Button {
                showFilePicker = true
            } label: {
                HStack {
                    Image(systemName: "folder.badge.plus")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose Audio File")
                            .font(.headline)
                        Text("Supports MP3, WAV, M4A, AAC")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Built-in Sounds
    private var builtInSoundsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Built-in Sounds")
                .font(.headline)
            
            Text("Tap to add a sound source to your scene")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(BuiltInSound.allCases) { sound in
                    builtInSoundCard(sound)
                }
            }
        }
    }
    
    @ViewBuilder
    private func builtInSoundCard(_ sound: BuiltInSound) -> some View {
        Button {
            addBuiltInSound(sound)
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(sound.color.gradient)
                        .frame(height: 80)
                    
                    Image(systemName: sound.iconName)
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 4) {
                    Text(sound.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    Text(sound.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.bottom, 8)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Check if file is accessible and is audio
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access file")
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Get filename without extension
            let filename = url.deletingPathExtension().lastPathComponent
            
            // Add to scene
            if viewModel.addAudioSource(name: filename, audioFileURL: url) != nil {
                dismiss()
            }
            
        case .failure(let error):
            print("File import failed: \(error)")
        }
    }
    
    private func addBuiltInSound(_ sound: BuiltInSound) {
        // Get URL from audio resources helper
        guard let url = AudioResources.url(for: sound) else {
            print("Built-in sound file not found: \(sound.filename)")
            return
        }
        
        if viewModel.addAudioSource(name: sound.displayName, audioFileURL: url) != nil {
            dismiss()
        }
    }
}

// MARK: - Built-in Sounds
enum BuiltInSound: String, CaseIterable, Identifiable {
    case ambience = "_ambience"
    case campfire = "_campfire"
    case chirping = "_chirpping"
    case footsteps = "_footsteps"
    case nature = "_nature"
    case noise = "_noise"
    case people = "_people"
    case rain = "_rain"
    case thunder = "_thunder"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ambience: return "Ambience"
        case .campfire: return "Campfire"
        case .chirping: return "Birds Chirping"
        case .footsteps: return "Footsteps"
        case .nature: return "Nature"
        case .noise: return "White Noise"
        case .people: return "People"
        case .rain: return "Rain"
        case .thunder: return "Thunder"
        }
    }

    var description: String {
        switch self {
        case .ambience: return "Background ambience"
        case .campfire: return "Crackling flames"
        case .chirping: return "Chirping and singing"
        case .footsteps: return "Walking footsteps"
        case .nature: return "Nature ambience"
        case .noise: return "Steady background noise"
        case .people: return "Crowd and voices"
        case .rain: return "Gentle rainfall"
        case .thunder: return "Rolling thunder"
        }
    }

    var iconName: String {
        switch self {
        case .ambience: return "waveform"
        case .campfire: return "flame.fill"
        case .chirping: return "bird.fill"
        case .footsteps: return "figure.walk"
        case .nature: return "leaf.fill"
        case .noise: return "waveform.path"
        case .people: return "person.2.fill"
        case .rain: return "cloud.rain.fill"
        case .thunder: return "cloud.bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .ambience: return .gray
        case .campfire: return .red
        case .chirping: return .mint
        case .footsteps: return .brown
        case .nature: return .green
        case .noise: return .gray
        case .people: return .orange
        case .rain: return .cyan
        case .thunder: return .purple
        }
    }

    var filename: String {
        rawValue
    }
}

#Preview {
    AudioLibraryView(viewModel: SoundScapeViewModel())
}
