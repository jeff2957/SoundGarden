//
//  AudioResources.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation
import AVFoundation

/// Helper for managing built-in audio resources
enum AudioResources {
    
    /// Get URL for a built-in audio resource
    static func url(for sound: BuiltInSound) -> URL? {
        // Try to find in bundle
        if let url = Bundle.main.url(forResource: sound.filename, withExtension: "mp3") {
            return url
        }
        
        // Fallback: Generate a silent audio file for demonstration
        return generateSilentAudioFile(name: sound.filename)
    }
    
    /// Generate a silent audio file for testing/placeholder purposes
    private static func generateSilentAudioFile(name: String, duration: TimeInterval = 10.0) -> URL? {
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "\(name)_silent.m4a"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        // Check if already exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        
        do {
            let audioFile = try AVAudioFile(
                forWriting: fileURL,
                settings: settings,
                commonFormat: .pcmFormatFloat32,
                interleaved: false
            )
            
            // Create silent buffer (10 seconds at 44.1kHz)
            let frameCount = AVAudioFrameCount(duration * 44100.0)
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: frameCount
            ) else {
                return nil
            }
            
            buffer.frameLength = frameCount
            
            // Write silent buffer to file
            try audioFile.write(from: buffer)
            
            print("Generated silent audio file: \(fileURL.lastPathComponent)")
            return fileURL
            
        } catch {
            print("Failed to generate audio file: \(error)")
            return nil
        }
    }
    
    /// Check if all built-in sounds are available
    static func checkBuiltInSounds() -> [BuiltInSound: Bool] {
        var availability: [BuiltInSound: Bool] = [:]
        
        for sound in BuiltInSound.allCases {
            availability[sound] = url(for: sound) != nil
        }
        
        return availability
    }
}

// MARK: - Audio File Validator
extension URL {
    /// Validate that this URL points to a valid audio file
    func validateAudioFile() -> Bool {
        guard self.isFileURL else { return false }
        
        do {
            let _ = try AVAudioFile(forReading: self)
            return true
        } catch {
            print("Invalid audio file: \(error)")
            return false
        }
    }
    
    /// Get duration of audio file
    var audioDuration: TimeInterval? {
        do {
            let audioFile = try AVAudioFile(forReading: self)
            let frames = Double(audioFile.length)
            let sampleRate = audioFile.fileFormat.sampleRate
            return frames / sampleRate
        } catch {
            return nil
        }
    }
}
