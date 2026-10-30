//
//  AudioEngine.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation
import AVFoundation
import Observation

/// Core audio engine managing spatial audio playback and 3D positioning
@Observable
final class AudioEngine {
    // MARK: - Properties
    private let engine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()
    private var playerNodes: [UUID: AVAudioPlayerNode] = [:]
    private var reverbNodes: [UUID: AVAudioUnitReverb] = [:]
    private var audioFiles: [UUID: AVAudioFile] = [:]
    
    private let mainMixer: AVAudioMixerNode
    var isEngineRunning = false
    
    // MARK: - Initialization
    init() {
        self.mainMixer = engine.mainMixerNode
        setupAudioEngine()
    }
    
    // MARK: - Audio Engine Setup
    private func setupAudioEngine() {
        // Attach environment node for 3D audio
        engine.attach(environment)
        
        // Connect environment to main mixer
        engine.connect(environment, to: mainMixer, format: nil)
        
        // Configure environment for spatial audio
        environment.distanceAttenuationParameters.maximumDistance = 100.0
        environment.distanceAttenuationParameters.referenceDistance = 1.0
        environment.reverbParameters.enable = true
        environment.reverbParameters.level = 0.0
        
        // Set listener position at origin
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        
        // Configure audio session for spatial playback
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Configure for spatial audio playback
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.allowBluetooth, .allowBluetoothA2DP]
            )
            
            // Set preferred IO buffer duration for low latency
            try audioSession.setPreferredIOBufferDuration(0.01)
            
            // Activate session
            try audioSession.setActive(true)
            
            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Engine Control
    func startEngine() throws {
        guard !isEngineRunning else { return }
        
        engine.prepare()
        try engine.start()
        isEngineRunning = true
        print("Audio engine started successfully")
    }
    
    func stopEngine() {
        guard isEngineRunning else { return }
        
        engine.stop()
        isEngineRunning = false
        print("Audio engine stopped")
    }
    
    // MARK: - Source Management
    /// Create a new audio source and load the audio file
    func createAudioSource(id: UUID, fileURL: URL) throws {
        // Load audio file
        let audioFile = try AVAudioFile(forReading: fileURL)
        audioFiles[id] = audioFile
        
        // Create player node
        let playerNode = AVAudioPlayerNode()
        playerNodes[id] = playerNode
        
        // Create reverb node
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.mediumHall)
        reverbNode.wetDryMix = 0.0 // Start with no reverb
        reverbNodes[id] = reverbNode
        
        // Attach nodes to engine
        engine.attach(playerNode)
        engine.attach(reverbNode)
        
        // Connect: player -> reverb -> environment
        let format = audioFile.processingFormat
        engine.connect(playerNode, to: reverbNode, format: format)
        engine.connect(reverbNode, to: environment, format: format)
        
        // Schedule file for looping
        scheduleAudioFile(for: id)
        
        print("Created audio source: \(id)")
    }
    
    private func scheduleAudioFile(for id: UUID) {
        guard let playerNode = playerNodes[id],
              let audioFile = audioFiles[id] else { return }
        
        playerNode.scheduleFile(audioFile, at: nil) { [weak self] in
            // Loop the audio by rescheduling
            self?.scheduleAudioFile(for: id)
        }
    }
    
    /// Remove an audio source
    func removeAudioSource(id: UUID) {
        if let playerNode = playerNodes[id] {
            playerNode.stop()
            engine.detach(playerNode)
            playerNodes.removeValue(forKey: id)
        }
        
        if let reverbNode = reverbNodes[id] {
            engine.detach(reverbNode)
            reverbNodes.removeValue(forKey: id)
        }
        
        audioFiles.removeValue(forKey: id)
        
        print("Removed audio source: \(id)")
    }
    
    // MARK: - Playback Control
    func playSource(id: UUID) {
        guard let playerNode = playerNodes[id] else { return }
        
        if !playerNode.isPlaying {
            playerNode.play()
            print("Playing source: \(id)")
        }
    }
    
    func stopSource(id: UUID) {
        guard let playerNode = playerNodes[id] else { return }
        
        if playerNode.isPlaying {
            playerNode.pause()
            print("Stopped source: \(id)")
        }
    }
    
    func stopAllSources() {
        playerNodes.values.forEach { $0.pause() }
    }
    
    // MARK: - Spatial Positioning
    /// Update 3D position of audio source (preserves current elevation/z)
    func updatePosition(id: UUID, position: CGPoint, circleRadius: CGFloat) {
        guard let playerNode = playerNodes[id] else { return }

        // Convert 2D canvas position to 3D coordinates
        let x = Float(position.x / circleRadius) * 10.0 // Scale to reasonable 3D space
        let y = Float(position.y / circleRadius) * 10.0
        let z = playerNode.position.z // Keep existing elevation

        playerNode.position = AVAudio3DPoint(x: x, y: y, z: z)
    }

    /// Update height/elevation of audio source (-90...90 degrees mapped to z axis)
    func updateElevation(id: UUID, elevation: Float) {
        guard let playerNode = playerNodes[id] else { return }

        let current = playerNode.position
        let z = (elevation / 90.0) * 10.0

        playerNode.position = AVAudio3DPoint(x: current.x, y: current.y, z: z)
    }

    // MARK: - Parameter Updates
    func updateVolume(id: UUID, volume: Float) {
        guard let playerNode = playerNodes[id] else { return }
        playerNode.volume = volume.clamped(min: 0.0, max: 1.0)
    }
    
    func updateReverb(id: UUID, amount: Float) {
        guard let reverbNode = reverbNodes[id] else { return }
        let clampedAmount = amount.clamped(min: 0.0, max: 1.0)
        reverbNode.wetDryMix = clampedAmount * 100.0 // AVAudioUnitReverb uses 0-100
    }
    
    func updatePan(id: UUID, pan: Float) {
        guard let playerNode = playerNodes[id] else { return }
        playerNode.pan = pan.clamped(min: -1.0, max: 1.0)
    }
    
    // MARK: - Cleanup
    deinit {
        stopAllSources()
        stopEngine()
    }
}

// MARK: - AVAudio3DPoint Extension
extension AVAudio3DPoint {
    init(x: Float, y: Float, z: Float) {
        self.init()
        self.x = x
        self.y = y
        self.z = z
    }
}
