//
//  Constants.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation
import SwiftUI

enum AppConstants {
    // Audio Configuration
    static let maxAudioSources = 10
    static let defaultVolume: Float = 0.7
    static let defaultReverbAmount: Float = 0.2
    static let audioUpdateDebounceMS: Int = 50
    
    // Spatial Configuration
    static let defaultCircleRadius: CGFloat = 150.0
    static let minCircleRadius: CGFloat = 100.0
    static let maxCircleRadius: CGFloat = 250.0
    static let sourceNodeRadius: CGFloat = 30.0
    
    // Audio Formats
    static let supportedAudioFormats = ["mp3", "wav", "m4a", "aac", "caf"]
    
    // Colors
    static let sourceColors: [Color] = [
        .blue, .green, .orange, .purple, .pink,
        .red, .cyan, .mint, .indigo, .teal
    ]
    
    // File Storage
    static let presetsDirectoryName = "SoundScapePresets"
    static let presetFileExtension = "soundscape"
    
    // UI Animation
    static let standardAnimationDuration: Double = 0.3
    static let springAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
}

enum SpatialAudioConstants {
    static let minAzimuth: Float = 0.0
    static let maxAzimuth: Float = 360.0
    static let minElevation: Float = -90.0
    static let maxElevation: Float = 90.0
    static let minDistance: Float = 0.1
    static let maxDistance: Float = 100.0
}
