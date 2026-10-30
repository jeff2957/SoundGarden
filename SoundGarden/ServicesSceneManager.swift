//
//  SceneManager.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation
import SwiftUI

/// Manages sound scenes including persistence and validation
final class SceneManager {
    // MARK: - Properties
    private let fileManager = FileManager.default
    private let presetsDirectory: URL
    
    // MARK: - Initialization
    init() {
        // Setup presets directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        presetsDirectory = documentsPath.appendingPathComponent(AppConstants.presetsDirectoryName)
        
        createPresetsDirectoryIfNeeded()
    }
    
    private func createPresetsDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: presetsDirectory.path) {
            try? fileManager.createDirectory(at: presetsDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Scene Validation
    /// Validate that a position is within the circular boundary
    func isPositionValid(point: CGPoint, circleRadius: CGFloat, center: CGPoint = .zero) -> Bool {
        point.isWithin(radius: circleRadius, of: center)
    }
    
    /// Constrain position to circular boundary
    func constrainPosition(point: CGPoint, circleRadius: CGFloat, center: CGPoint = .zero) -> CGPoint {
        point.constrained(to: circleRadius, around: center)
    }
    
    // MARK: - Scene Persistence
    func saveScene(_ scene: SoundScene) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(scene)
        let filename = "\(scene.id.uuidString).\(AppConstants.presetFileExtension)"
        let fileURL = presetsDirectory.appendingPathComponent(filename)
        
        try data.write(to: fileURL)
        print("Saved scene: \(scene.name) to \(fileURL)")
    }
    
    func loadScene(id: UUID) throws -> SoundScene {
        let filename = "\(id.uuidString).\(AppConstants.presetFileExtension)"
        let fileURL = presetsDirectory.appendingPathComponent(filename)
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let scene = try decoder.decode(SoundScene.self, from: data)
        
        print("Loaded scene: \(scene.name)")
        return scene
    }
    
    func loadAllScenes() throws -> [SoundScene] {
        let files = try fileManager.contentsOfDirectory(at: presetsDirectory, includingPropertiesForKeys: nil)
        let sceneFiles = files.filter { $0.pathExtension == AppConstants.presetFileExtension }
        
        var scenes: [SoundScene] = []
        for fileURL in sceneFiles {
            do {
                let data = try Data(contentsOf: fileURL)
                let scene = try JSONDecoder().decode(SoundScene.self, from: data)
                scenes.append(scene)
            } catch {
                print("Failed to load scene from \(fileURL): \(error)")
            }
        }
        
        return scenes.sorted { $0.createdDate > $1.createdDate }
    }
    
    func deleteScene(id: UUID) throws {
        let filename = "\(id.uuidString).\(AppConstants.presetFileExtension)"
        let fileURL = presetsDirectory.appendingPathComponent(filename)
        
        try fileManager.removeItem(at: fileURL)
        print("Deleted scene: \(id)")
    }
    
    // MARK: - Built-in Presets
    func createBuiltInPresets() -> [SoundScene] {
        // This would contain pre-configured scenes with built-in audio files
        // For now, return empty array - we'll populate with actual audio later
        return []
    }
    
    // MARK: - Export/Import
    func exportScene(_ scene: SoundScene) throws -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(scene)
        let filename = "\(scene.name.replacingOccurrences(of: " ", with: "_")).\(AppConstants.presetFileExtension)"
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(filename)
        
        try data.write(to: tempURL)
        return tempURL
    }
    
    func importScene(from url: URL) throws -> SoundScene {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        var scene = try decoder.decode(SoundScene.self, from: data)
        
        // Generate new ID to avoid conflicts
        scene = SoundScene(
            id: UUID(),
            name: scene.name,
            audioSources: scene.audioSources,
            circleRadius: scene.circleRadius,
            userAvatarPosition: scene.userAvatarPosition,
            createdDate: Date()
        )
        
        // Save imported scene
        try saveScene(scene)
        
        return scene
    }
}
