//
//  Extensions.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation
import SwiftUI

// MARK: - CGPoint Extensions
extension CGPoint {
    /// Calculate distance from another point
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    /// Calculate angle (in degrees) from another point
    func angle(from point: CGPoint) -> CGFloat {
        let deltaX = x - point.x
        let deltaY = y - point.y
        let radians = atan2(deltaY, deltaX)
        let degrees = radians * 180 / .pi
        return degrees >= 0 ? degrees : degrees + 360
    }
    
    /// Check if point is within a circular boundary
    func isWithin(radius: CGFloat, of center: CGPoint) -> Bool {
        distance(to: center) <= radius
    }
    
    /// Constrain point to circular boundary
    func constrained(to radius: CGFloat, around center: CGPoint) -> CGPoint {
        let dist = distance(to: center)
        if dist <= radius {
            return self
        }
        
        let angle = atan2(y - center.y, x - center.x)
        return CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }
}

// MARK: - Float Extensions
extension Float {
    /// Clamp value between min and max
    func clamped(min: Float, max: Float) -> Float {
        Swift.min(Swift.max(self, min), max)
    }
    
    /// Convert to decibels
    var toDecibels: Float {
        20 * log10(Swift.max(self, 0.001))
    }
    
    /// Format as percentage string
    var asPercentage: String {
        String(format: "%.0f%%", self * 100)
    }
}

// MARK: - URL Extensions
extension URL {
    /// Check if URL is a valid audio file
    var isAudioFile: Bool {
        AppConstants.supportedAudioFormats.contains(self.pathExtension.lowercased())
    }
}

// MARK: - Color Extensions
extension Color {
    /// Get next color from the palette
    static func nextSourceColor(for index: Int) -> Color {
        AppConstants.sourceColors[index % AppConstants.sourceColors.count]
    }
}
