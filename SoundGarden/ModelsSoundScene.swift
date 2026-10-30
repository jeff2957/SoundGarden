//
//  SoundScene.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation
import SwiftUI

/// Represents a complete spatial audio scene with multiple sources
struct SoundScene: Identifiable, Codable {
    let id: UUID
    var name: String
    var audioSources: [AudioSource]
    var circleRadius: CGFloat
    var userAvatarPosition: CGPoint
    var createdDate: Date
    
    init(
        id: UUID = UUID(),
        name: String = "Untitled Scene",
        audioSources: [AudioSource] = [],
        circleRadius: CGFloat = 150.0,
        userAvatarPosition: CGPoint = .zero,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.audioSources = audioSources
        self.circleRadius = circleRadius
        self.userAvatarPosition = userAvatarPosition
        self.createdDate = createdDate
    }
}
