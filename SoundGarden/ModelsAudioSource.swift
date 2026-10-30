//
//  AudioSource.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation
import SwiftUI

/// Represents an individual audio source in the spatial audio scene
struct AudioSource: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var position: CGPoint
    var volume: Float // 0.0 - 1.0
    var reverbAmount: Float // 0.0 - 1.0
    var pan: Float // -1.0 (left) to 1.0 (right)
    var azimuth: Float // 0-360 degrees
    var elevation: Float // -90 to 90 degrees
    var isPlaying: Bool
    var audioFileURL: URL
    var color: CodableColor
    
    init(
        id: UUID = UUID(),
        name: String,
        position: CGPoint = .zero,
        volume: Float = 0.7,
        reverbAmount: Float = 0.2,
        pan: Float = 0.0,
        azimuth: Float = 0.0,
        elevation: Float = 0.0,
        isPlaying: Bool = false,
        audioFileURL: URL,
        color: Color = .blue
    ) {
        self.id = id
        self.name = name
        self.position = position
        self.volume = volume
        self.reverbAmount = reverbAmount
        self.pan = pan
        self.azimuth = azimuth
        self.elevation = elevation
        self.isPlaying = isPlaying
        self.audioFileURL = audioFileURL
        self.color = CodableColor(color: color)
    }
}

// Helper to make Color Codable for AudioSource
struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    init(color: Color) {
        // Default RGB values - we'll use a limited palette
        // In production, you'd want to extract actual RGB values
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
