//
//  SoundScapeViewModel.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation
import SwiftUI
import Observation

/// Main ViewModel managing the sound scene and audio engine
@Observable
final class SoundScapeViewModel {
    // MARK: - Properties
    var currentScene: SoundScene
    var selectedSource: AudioSource?
    var isPlaying = false
    var audioSources: [AudioSource] { currentScene.audioSources }
    
    let audioEngine: AudioEngine
    private let sceneManager: SceneManager
    
    // Debounce timer for parameter updates
    private var updateTimer: Timer?
    
    // MARK: - Initialization
    init() {
        self.audioEngine = AudioEngine()
        self.sceneManager = SceneManager()
        self.currentScene = SoundScene()
        
        // Start audio engine
        do {
            try audioEngine.startEngine()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    // MARK: - Audio Source Management
    func addAudioSource(name: String, audioFileURL: URL, position: CGPoint? = nil) -> AudioSource? {
        guard audioSources.count < AppConstants.maxAudioSources else {
            print("Maximum number of audio sources reached")
            return nil
        }
        
        let sourcePosition = position ?? randomPositionInCircle()
        let color = Color.nextSourceColor(for: audioSources.count)
        
        let source = AudioSource(
            name: name,
            position: sourcePosition,
            audioFileURL: audioFileURL,
            color: color
        )
        
        // Create audio source in engine
        do {
            try audioEngine.createAudioSource(id: source.id, fileURL: audioFileURL)
            
            // Update position
            audioEngine.updatePosition(
                id: source.id,
                position: source.position,
                circleRadius: currentScene.circleRadius
            )
            
            // Add to scene
            currentScene.audioSources.append(source)
            
            print("Added audio source: \(name)")
            return source
        } catch {
            print("Failed to add audio source: \(error)")
            return nil
        }
    }
    
    func removeAudioSource(id: UUID) {
        guard let index = currentScene.audioSources.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        // Stop and remove from engine
        audioEngine.stopSource(id: id)
        audioEngine.removeAudioSource(id: id)
        
        // Remove from scene
        currentScene.audioSources.remove(at: index)
        
        // Deselect if this was selected
        if selectedSource?.id == id {
            selectedSource = nil
        }
        
        print("Removed audio source: \(id)")
    }
    
    // MARK: - Position Management
    func updateSourcePosition(id: UUID, position: CGPoint) {
        guard let index = currentScene.audioSources.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        // Constrain to circle
        let constrainedPosition = sceneManager.constrainPosition(
            point: position,
            circleRadius: currentScene.circleRadius,
            center: currentScene.userAvatarPosition
        )
        
        currentScene.audioSources[index].position = constrainedPosition

        // Keep azimuth in sync with the new position
        let azimuth = Float(constrainedPosition.angle(from: currentScene.userAvatarPosition))
        currentScene.audioSources[index].azimuth = azimuth

        // Update audio engine with debounce
        debounceUpdate {
            self.audioEngine.updatePosition(
                id: id,
                position: constrainedPosition,
                circleRadius: self.currentScene.circleRadius
            )
        }

        // Update selected source if needed
        if selectedSource?.id == id {
            selectedSource?.position = constrainedPosition
            selectedSource?.azimuth = azimuth
        }
    }

    /// Rotate a source's position around the listener to match a target azimuth, preserving its distance
    func updateSourceAzimuth(id: UUID, azimuth: Float) {
        guard let index = currentScene.audioSources.firstIndex(where: { $0.id == id }) else {
            return
        }

        let center = currentScene.userAvatarPosition
        let currentPosition = currentScene.audioSources[index].position
        let distance = currentPosition.distance(to: center)
        let radians = Double(azimuth) * .pi / 180

        let rotatedPosition = CGPoint(
            x: center.x + distance * CGFloat(cos(radians)),
            y: center.y + distance * CGFloat(sin(radians))
        )

        updateSourcePosition(id: id, position: rotatedPosition)
    }

    /// Update a source's height above/below the horizontal plane
    func updateSourceElevation(id: UUID, elevation: Float) {
        guard let index = currentScene.audioSources.firstIndex(where: { $0.id == id }) else {
            return
        }

        currentScene.audioSources[index].elevation = elevation
        audioEngine.updateElevation(id: id, elevation: elevation)

        if selectedSource?.id == id {
            selectedSource?.elevation = elevation
        }
    }

    func isPositionValid(point: CGPoint) -> Bool {
        sceneManager.isPositionValid(
            point: point,
            circleRadius: currentScene.circleRadius,
            center: currentScene.userAvatarPosition
        )
    }
    
    // MARK: - Audio Parameters
    func updateSourceVolume(id: UUID, volume: Float) {
        guard let index = currentScene.audioSources.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        currentScene.audioSources[index].volume = volume
        audioEngine.updateVolume(id: id, volume: volume)

        if selectedSource?.id == id {
            selectedSource?.volume = volume
        }
    }
    
    func updateSourceReverb(id: UUID, reverbAmount: Float) {
        guard let index = currentScene.audioSources.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        currentScene.audioSources[index].reverbAmount = reverbAmount
        audioEngine.updateReverb(id: id, amount: reverbAmount)

        if selectedSource?.id == id {
            selectedSource?.reverbAmount = reverbAmount
        }
    }
    
    func updateSourcePan(id: UUID, pan: Float) {
        guard let index = currentScene.audioSources.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        currentScene.audioSources[index].pan = pan
        audioEngine.updatePan(id: id, pan: pan)

        if selectedSource?.id == id {
            selectedSource?.pan = pan
        }
    }
    
    func applyPreset(id: UUID, preset: AudioPreset) {
        let params = preset.parameters
        updateSourceVolume(id: id, volume: params.volume)
        updateSourceReverb(id: id, reverbAmount: params.reverbAmount)
        updateSourcePan(id: id, pan: params.pan)
    }
    
    // MARK: - Playback Control
    func playSource(id: UUID) {
        guard let index = currentScene.audioSources.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        currentScene.audioSources[index].isPlaying = true
        audioEngine.playSource(id: id)
        
        if selectedSource?.id == id {
            selectedSource?.isPlaying = true
        }
        
        updatePlayingState()
    }
    
    func stopSource(id: UUID) {
        guard let index = currentScene.audioSources.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        currentScene.audioSources[index].isPlaying = false
        audioEngine.stopSource(id: id)
        
        if selectedSource?.id == id {
            selectedSource?.isPlaying = false
        }
        
        updatePlayingState()
    }
    
    func toggleSourcePlayback(id: UUID) {
        guard let source = currentScene.audioSources.first(where: { $0.id == id }) else {
            return
        }
        
        if source.isPlaying {
            stopSource(id: id)
        } else {
            playSource(id: id)
        }
    }
    
    func playAllSources() {
        currentScene.audioSources.forEach { source in
            playSource(id: source.id)
        }
    }
    
    func stopAllSources() {
        currentScene.audioSources.forEach { source in
            stopSource(id: source.id)
        }
        audioEngine.stopAllSources()
    }
    
    private func updatePlayingState() {
        isPlaying = currentScene.audioSources.contains { $0.isPlaying }
    }
    
    // MARK: - Selection
    func selectSource(id: UUID) {
        selectedSource = currentScene.audioSources.first { $0.id == id }
    }
    
    func deselectSource() {
        selectedSource = nil
    }
    
    // MARK: - Scene Management
    func loadScene(_ scene: SoundScene) {
        // Stop all current sources
        stopAllSources()
        
        // Remove all sources
        currentScene.audioSources.forEach { source in
            audioEngine.removeAudioSource(id: source.id)
        }
        
        // Load new scene
        currentScene = scene
        
        // Create all audio sources
        for source in scene.audioSources {
            do {
                try audioEngine.createAudioSource(id: source.id, fileURL: source.audioFileURL)
                audioEngine.updatePosition(id: source.id, position: source.position, circleRadius: scene.circleRadius)
                audioEngine.updateVolume(id: source.id, volume: source.volume)
                audioEngine.updateReverb(id: source.id, amount: source.reverbAmount)
                
                if source.isPlaying {
                    audioEngine.playSource(id: source.id)
                }
            } catch {
                print("Failed to load audio source: \(error)")
            }
        }
        
        selectedSource = nil
        updatePlayingState()
    }
    
    func saveScene() throws {
        try sceneManager.saveScene(currentScene)
    }
    
    func loadScene(id: UUID) throws {
        let scene = try sceneManager.loadScene(id: id)
        loadScene(scene)
    }
    
    func newScene(name: String = "New Scene") {
        stopAllSources()
        currentScene.audioSources.forEach { source in
            audioEngine.removeAudioSource(id: source.id)
        }
        
        currentScene = SoundScene(name: name)
        selectedSource = nil
        isPlaying = false
    }
    
    // MARK: - Helpers
    private func randomPositionInCircle() -> CGPoint {
        let angle = Double.random(in: 0...(2 * .pi))
        let radius = Double.random(in: 0...1).squareRoot() * Double(currentScene.circleRadius * 0.8)
        
        return CGPoint(
            x: currentScene.userAvatarPosition.x + CGFloat(cos(angle) * radius),
            y: currentScene.userAvatarPosition.y + CGFloat(sin(angle) * radius)
        )
    }
    
    private func debounceUpdate(action: @escaping () -> Void) {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
            action()
        }
    }
}
