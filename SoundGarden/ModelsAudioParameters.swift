//
//  AudioParameters.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation

/// Represents adjustable audio parameters for a sound source
struct AudioParameters: Codable {
    var volume: Float // 0.0 - 1.0
    var reverbAmount: Float // 0.0 - 1.0
    var pan: Float // -1.0 (left) to 1.0 (right)
    var azimuth: Float // 0-360 degrees
    var elevation: Float // -90 to 90 degrees
    
    init(
        volume: Float = 0.7,
        reverbAmount: Float = 0.2,
        pan: Float = 0.0,
        azimuth: Float = 0.0,
        elevation: Float = 0.0
    ) {
        self.volume = volume
        self.reverbAmount = reverbAmount
        self.pan = pan
        self.azimuth = azimuth
        self.elevation = elevation
    }
    
    /// Convert to decibels for display
    var volumeInDB: Float {
        20 * log10(max(volume, 0.001))
    }
}

/// Preset configurations for common audio scenarios
enum AudioPreset: String, CaseIterable {
    case dry = "Dry"
    case lightReverb = "Light Reverb"
    case mediumReverb = "Medium Reverb"
    case heavyReverb = "Heavy Reverb"
    case cathedral = "Cathedral"
    
    var parameters: AudioParameters {
        switch self {
        case .dry:
            return AudioParameters(volume: 0.7, reverbAmount: 0.0, pan: 0.0)
        case .lightReverb:
            return AudioParameters(volume: 0.7, reverbAmount: 0.2, pan: 0.0)
        case .mediumReverb:
            return AudioParameters(volume: 0.7, reverbAmount: 0.5, pan: 0.0)
        case .heavyReverb:
            return AudioParameters(volume: 0.7, reverbAmount: 0.8, pan: 0.0)
        case .cathedral:
            return AudioParameters(volume: 0.6, reverbAmount: 0.95, pan: 0.0)
        }
    }
}
