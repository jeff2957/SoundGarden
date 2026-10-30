//
//  AudioControlPanelView.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import SwiftUI

/// Control panel for individual audio source parameters
struct AudioControlPanelView: View {
    @Bindable var viewModel: SoundScapeViewModel
    let source: AudioSource
    
    @State private var showAdvancedControls = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Basic Controls
                    basicControlsSection
                    
                    // Reverb Control
                    reverbSection
                    
                    // Pan Control
                    panSection
                    
                    // Presets
                    presetsSection
                    
                    // Advanced Controls (collapsible)
                    advancedControlsSection
                    
                    // Delete Button
                    deleteButton
                }
                .padding()
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            // Color indicator
            Circle()
                .fill(source.color.color.gradient)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: source.isPlaying ? "speaker.wave.3.fill" : "speaker.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(source.name)
                    .font(.headline)
                
                Text(source.isPlaying ? "Playing" : "Paused")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Close button
            Button {
                withAnimation {
                    viewModel.deselectSource()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
    
    // MARK: - Basic Controls
    private var basicControlsSection: some View {
        VStack(spacing: 16) {
            // Play/Pause Button
            Button {
                viewModel.toggleSourcePlayback(id: source.id)
            } label: {
                HStack {
                    Image(systemName: source.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                    Text(source.isPlaying ? "Pause" : "Play")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(source.color.color.gradient)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Volume Control
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Volume", systemImage: "speaker.wave.2.fill")
                        .font(.subheadline.weight(.medium))
                    
                    Spacer()
                    
                    Text("\(Int(source.volume * 100))%")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                    
                    Text("(\(String(format: "%.1f", source.volume.toDecibels)) dB)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.tertiary)
                }
                
                Slider(
                    value: Binding(
                        get: { Double(source.volume) },
                        set: { viewModel.updateSourceVolume(id: source.id, volume: Float($0)) }
                    ),
                    in: 0...1
                )
                .tint(source.color.color)

            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Reverb Section
    private var reverbSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Reverb", systemImage: "waveform.path.ecg")
                    .font(.subheadline.weight(.medium))
                
                Spacer()
                
                Text("\(Int(source.reverbAmount * 100))%")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            
            Slider(
                value: Binding(
                    get: { Double(source.reverbAmount) },
                    set: { viewModel.updateSourceReverb(id: source.id, reverbAmount: Float($0)) }
                ),
                in: 0...1
            )
            .tint(source.color.color)
            
            // Reverb description
            Text(reverbDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var reverbDescription: String {
        switch source.reverbAmount {
        case 0..<0.2: return "Dry - No reverb"
        case 0.2..<0.4: return "Light reverb - Small room"
        case 0.4..<0.6: return "Medium reverb - Large room"
        case 0.6..<0.8: return "Heavy reverb - Concert hall"
        default: return "Cathedral - Very spacious"
        }
    }
    
    // MARK: - Pan Section
    private var panSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Pan", systemImage: "arrow.left.and.right")
                    .font(.subheadline.weight(.medium))
                
                Spacer()
                
                Text(panDescription)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("L")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                
                Slider(
                    value: Binding(
                        get: { Double(source.pan) },
                        set: { viewModel.updateSourcePan(id: source.id, pan: Float($0)) }
                    ),
                    in: -1...1
                )
                .tint(source.color.color)
                
                Text("R")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var panDescription: String {
        if abs(source.pan) < 0.1 {
            return "Center"
        } else if source.pan < 0 {
            return "L \(Int(abs(source.pan) * 100))%"
        } else {
            return "R \(Int(source.pan * 100))%"
        }
    }
    
    // MARK: - Presets Section
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Presets")
                .font(.subheadline.weight(.medium))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AudioPreset.allCases, id: \.self) { preset in
                        Button {
                            withAnimation {
                                viewModel.applyPreset(id: source.id, preset: preset)
                            }
                        } label: {
                            Text(preset.rawValue)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Advanced Controls
    private var advancedControlsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation {
                    showAdvancedControls.toggle()
                }
            } label: {
                HStack {
                    Text("Advanced Controls")
                        .font(.subheadline.weight(.medium))
                    
                    Spacer()
                    
                    Image(systemName: showAdvancedControls ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(.primary)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            if showAdvancedControls {
                VStack(spacing: 16) {
                    // Azimuth
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Azimuth (Direction)")
                            Spacer()
                            Text("\(Int(source.azimuth))°")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                        
                        Slider(
                            value: Binding(
                                get: { Double(source.azimuth) },
                                set: { viewModel.updateSourceAzimuth(id: source.id, azimuth: Float($0)) }
                            ),
                            in: 0...360
                        )
                        .tint(source.color.color)
                    }

                    // Elevation
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Elevation (Height)")
                            Spacer()
                            Text("\(Int(source.elevation))°")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)

                        Slider(
                            value: Binding(
                                get: { Double(source.elevation) },
                                set: { viewModel.updateSourceElevation(id: source.id, elevation: Float($0)) }
                            ),
                            in: -90...90
                        )
                        .tint(source.color.color)
                    }

                    Text("Azimuth rotates the source around you; elevation sets its height")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Delete Button
    private var deleteButton: some View {
        Button(role: .destructive) {
            withAnimation {
                viewModel.removeAudioSource(id: source.id)
            }
        } label: {
            Label("Remove Source", systemImage: "trash")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    AudioControlPanelView(
        viewModel: SoundScapeViewModel(),
        source: AudioSource(
            name: "Forest Ambience",
            audioFileURL: URL(string: "file://test.mp3")!,
            color: .green
        )
    )
    .padding()
}
