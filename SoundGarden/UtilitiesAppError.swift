//
//  AppError.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import Foundation

/// Application-specific errors
enum AppError: LocalizedError {
    case audioEngineFailure(String)
    case audioFileInvalid(URL)
    case audioFileLoadFailed(URL, Error)
    case maxSourcesReached
    case sourceNotFound(UUID)
    case sceneLoadFailed(Error)
    case sceneSaveFailed(Error)
    case invalidPosition(CGPoint)
    
    var errorDescription: String? {
        switch self {
        case .audioEngineFailure(let message):
            return "Audio Engine Error: \(message)"
        case .audioFileInvalid(let url):
            return "Invalid audio file: \(url.lastPathComponent)"
        case .audioFileLoadFailed(let url, let error):
            return "Failed to load \(url.lastPathComponent): \(error.localizedDescription)"
        case .maxSourcesReached:
            return "Maximum number of audio sources (\(AppConstants.maxAudioSources)) reached"
        case .sourceNotFound(let id):
            return "Audio source not found: \(id)"
        case .sceneLoadFailed(let error):
            return "Failed to load scene: \(error.localizedDescription)"
        case .sceneSaveFailed(let error):
            return "Failed to save scene: \(error.localizedDescription)"
        case .invalidPosition(let point):
            return "Invalid position: (\(point.x), \(point.y))"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .audioEngineFailure:
            return "Try restarting the app or checking your audio settings"
        case .audioFileInvalid, .audioFileLoadFailed:
            return "Please select a valid audio file (MP3, WAV, M4A, or AAC)"
        case .maxSourcesReached:
            return "Remove some audio sources before adding new ones"
        case .sourceNotFound:
            return "The audio source may have been removed"
        case .sceneLoadFailed:
            return "The scene file may be corrupted or incompatible"
        case .sceneSaveFailed:
            return "Check available storage space"
        case .invalidPosition:
            return "Position must be within the circular boundary"
        }
    }
}

/// Logging utility
enum AppLogger {
    static var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static func debug(_ message: String, category: String = "SoundGarden") {
        if isDebugMode {
            print("🔍 [\(category)] \(message)")
        }
    }
    
    static func info(_ message: String, category: String = "SoundGarden") {
        print("ℹ️ [\(category)] \(message)")
    }
    
    static func warning(_ message: String, category: String = "SoundGarden") {
        print("⚠️ [\(category)] \(message)")
    }
    
    static func error(_ error: Error, category: String = "SoundGarden") {
        print("❌ [\(category)] \(error.localizedDescription)")
        if let appError = error as? AppError, let suggestion = appError.recoverySuggestion {
            print("   💡 \(suggestion)")
        }
    }
}
