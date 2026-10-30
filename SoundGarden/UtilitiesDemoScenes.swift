//
//  DemoScenes.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation
import SwiftUI

/// Pre-configured demo scenes for quick testing and user onboarding
enum DemoScenes {
    
    /// Create a meditation garden scene
    static func meditationGarden() -> SoundScene? {
        guard let forestURL = AudioResources.url(for: .nature),
              let rainURL = AudioResources.url(for: .rain),
              let birdsURL = AudioResources.url(for: .chirping),
              let windURL = AudioResources.url(for: .ambience) else {
            return nil
        }
        
        let sources = [
            AudioSource(
                name: "Forest Ambience",
                position: CGPoint(x: -80, y: -80),
                volume: 0.6,
                reverbAmount: 0.4,
                audioFileURL: forestURL,
                color: .green
            ),
            AudioSource(
                name: "Gentle Rain",
                position: CGPoint(x: 80, y: -80),
                volume: 0.5,
                reverbAmount: 0.6,
                audioFileURL: rainURL,
                color: .cyan
            ),
            AudioSource(
                name: "Birds Singing",
                position: CGPoint(x: -80, y: 80),
                volume: 0.4,
                reverbAmount: 0.3,
                audioFileURL: birdsURL,
                color: .mint
            ),
            AudioSource(
                name: "Soft Wind",
                position: CGPoint(x: 80, y: 80),
                volume: 0.3,
                reverbAmount: 0.5,
                audioFileURL: windURL,
                color: .teal
            )
        ]
        
        return SoundScene(
            name: "Meditation Garden",
            audioSources: sources,
            circleRadius: 150.0
        )
    }
    
    /// Create an urban cafe scene
    static func urbanCafe() -> SoundScene? {
        guard let cityURL = AudioResources.url(for: .people),
              let rainURL = AudioResources.url(for: .rain) else {
            return nil
        }
        
        let sources = [
            AudioSource(
                name: "City Ambience",
                position: CGPoint(x: -100, y: 0),
                volume: 0.5,
                reverbAmount: 0.2,
                audioFileURL: cityURL,
                color: .orange
            ),
            AudioSource(
                name: "Rain Outside",
                position: CGPoint(x: 100, y: 0),
                volume: 0.6,
                reverbAmount: 0.7,
                audioFileURL: rainURL,
                color: .cyan
            )
        ]
        
        return SoundScene(
            name: "Urban Cafe",
            audioSources: sources,
            circleRadius: 150.0
        )
    }
    
    /// Create an ocean breeze scene
    static func oceanBreeze() -> SoundScene? {
        guard let oceanURL = AudioResources.url(for: .noise),
              let birdsURL = AudioResources.url(for: .chirping),
              let windURL = AudioResources.url(for: .ambience) else {
            return nil
        }
        
        let sources = [
            AudioSource(
                name: "Ocean Waves",
                position: CGPoint(x: 0, y: -120),
                volume: 0.8,
                reverbAmount: 0.5,
                audioFileURL: oceanURL,
                color: .blue
            ),
            AudioSource(
                name: "Seagulls",
                position: CGPoint(x: -60, y: 60),
                volume: 0.3,
                reverbAmount: 0.3,
                audioFileURL: birdsURL,
                color: .mint
            ),
            AudioSource(
                name: "Ocean Breeze",
                position: CGPoint(x: 60, y: 60),
                volume: 0.4,
                reverbAmount: 0.4,
                audioFileURL: windURL,
                color: .teal
            )
        ]
        
        return SoundScene(
            name: "Ocean Breeze",
            audioSources: sources,
            circleRadius: 150.0
        )
    }
    
    /// Create a rainy night scene
    static func rainyNight() -> SoundScene? {
        guard let rainURL = AudioResources.url(for: .rain),
              let windURL = AudioResources.url(for: .ambience) else {
            return nil
        }
        
        let sources = [
            AudioSource(
                name: "Heavy Rain",
                position: CGPoint(x: 0, y: -100),
                volume: 0.7,
                reverbAmount: 0.6,
                audioFileURL: rainURL,
                color: .cyan
            ),
            AudioSource(
                name: "Night Wind",
                position: CGPoint(x: -80, y: 50),
                volume: 0.4,
                reverbAmount: 0.7,
                audioFileURL: windURL,
                color: .indigo
            ),
            AudioSource(
                name: "Distant Rain",
                position: CGPoint(x: 80, y: 50),
                volume: 0.5,
                reverbAmount: 0.8,
                audioFileURL: rainURL,
                color: .blue
            )
        ]
        
        return SoundScene(
            name: "Rainy Night",
            audioSources: sources,
            circleRadius: 150.0
        )
    }
    
    /// Create a forest walk scene
    static func forestWalk() -> SoundScene? {
        guard let forestURL = AudioResources.url(for: .nature),
              let birdsURL = AudioResources.url(for: .chirping),
              let windURL = AudioResources.url(for: .ambience) else {
            return nil
        }
        
        let sources = [
            AudioSource(
                name: "Forest Floor",
                position: CGPoint(x: 0, y: -90),
                volume: 0.6,
                reverbAmount: 0.3,
                audioFileURL: forestURL,
                color: .green
            ),
            AudioSource(
                name: "Canopy Birds",
                position: CGPoint(x: -100, y: 0),
                volume: 0.5,
                reverbAmount: 0.4,
                audioFileURL: birdsURL,
                color: .mint
            ),
            AudioSource(
                name: "Tree Rustling",
                position: CGPoint(x: 100, y: 0),
                volume: 0.4,
                reverbAmount: 0.5,
                audioFileURL: windURL,
                color: .teal
            ),
            AudioSource(
                name: "Distant Birds",
                position: CGPoint(x: 0, y: 90),
                volume: 0.3,
                reverbAmount: 0.6,
                audioFileURL: birdsURL,
                color: .yellow
            )
        ]
        
        return SoundScene(
            name: "Forest Walk",
            audioSources: sources,
            circleRadius: 150.0
        )
    }
    
    /// Get all available demo scenes
    static func allDemoScenes() -> [SoundScene] {
        [
            meditationGarden(),
            urbanCafe(),
            oceanBreeze(),
            rainyNight(),
            forestWalk()
        ].compactMap { $0 }
    }
}
