# SoundGarden Development Guide

## Project Setup

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Swift 5.9+
- Physical device recommended for best spatial audio experience

### Initial Setup

1. **Clone/Open Project**
   ```bash
   open SoundGarden.xcodeproj
   ```

2. **Add Audio Resources**
   - Create a folder named "Audio" in your project
   - Add MP3/M4A files for each built-in sound:
     - `whiteNoise.mp3`
     - `forest.mp3`
     - `ocean.mp3`
     - `rain.mp3`
     - `city.mp3`
     - `birds.mp3`
     - `fire.mp3`
     - `wind.mp3`
   - Add to target in Xcode

3. **Configure Info.plist**
   Add these keys:
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>SoundGarden needs access to record audio</string>
   
   <key>UIBackgroundModes</key>
   <array>
       <string>audio</string>
   </array>
   
   <key>UIFileSharingEnabled</key>
   <true/>
   
   <key>LSSupportsOpeningDocumentsInPlace</key>
   <true/>
   ```

4. **Test Build**
   - Select a device or simulator
   - Cmd+R to build and run

## Architecture Overview

### MVVM Pattern
```
User Input → View → ViewModel → Service Layer → Audio Engine
                ↓        ↑
              State   Updates
```

### Key Components

#### Models
- `AudioSource`: Represents a single sound source
- `SoundScene`: Collection of audio sources
- `AudioParameters`: Audio effect parameters

#### ViewModels
- `SoundScapeViewModel`: Main state management
  - Coordinates between UI and audio engine
  - Handles scene persistence
  - Manages audio source lifecycle

#### Services
- `AudioEngine`: Core audio processing
  - AVAudioEngine configuration
  - Spatial audio positioning
  - Real-time parameter updates
  
- `SceneManager`: Data persistence
  - JSON serialization
  - File management
  - Import/export

#### Views
- `ContentView`: Main app container
- `SoundscapeCanvasView`: Interactive spatial canvas
- `AudioControlPanelView`: Per-source controls
- `AudioLibraryView`: Sound selection
- `SettingsView`: Configuration
- `WelcomeView`: Onboarding

## Audio Engine Details

### AVAudioEngine Setup
```
Input File → AVAudioPlayerNode → AVAudioUnitReverb → AVAudioEnvironmentNode → Output
```

### 3D Positioning
- Uses AVAudioEnvironmentNode for spatial audio
- Converts 2D canvas coordinates to 3D space
- Distance attenuation for realism
- Supports binaural rendering for headphones

### Performance Optimization
- Debouncing for real-time parameter updates (50ms)
- Efficient audio buffer management
- Lazy loading of audio files
- Background audio support

## Testing Strategy

### Unit Tests
Test coverage should include:
- Audio parameter calculations
- Position validation and constraints
- Scene serialization/deserialization
- Audio engine state management

### UI Tests
- Source positioning
- Control panel interactions
- Scene saving/loading
- File import flow

### Manual Testing Checklist
- [ ] Add audio source from library
- [ ] Drag source to different positions
- [ ] Adjust volume/reverb/pan sliders
- [ ] Play/pause individual sources
- [ ] Play/pause all sources
- [ ] Save scene
- [ ] Load saved scene
- [ ] Import audio file
- [ ] Remove source
- [ ] Create new scene
- [ ] Test with headphones
- [ ] Test spatial audio positioning
- [ ] Background audio continues playing
- [ ] Handle audio interruptions (calls, etc.)

## Common Issues & Solutions

### Audio Engine Won't Start
**Problem**: `audioEngine.start()` throws error
**Solution**: 
- Check Info.plist audio permissions
- Verify audio session configuration
- Ensure no other app is using audio exclusively

### Spatial Audio Not Working
**Problem**: All sounds come from center
**Solution**:
- Use headphones for binaural rendering
- Check AVAudioEnvironmentNode is connected
- Verify position coordinates are non-zero
- Test on physical device (not simulator)

### File Import Fails
**Problem**: Cannot import audio files
**Solution**:
- Check file format (MP3, WAV, M4A, AAC only)
- Verify security-scoped resource access
- Enable file sharing in Info.plist

### Memory Issues
**Problem**: App crashes with many sources
**Solution**:
- Implement audio streaming for large files
- Reduce max sources limit
- Profile with Instruments

## Performance Profiling

### Using Instruments
1. Product → Profile (Cmd+I)
2. Select "Time Profiler"
3. Test audio-intensive scenarios
4. Look for:
   - Audio thread CPU usage
   - Main thread blocking
   - Memory leaks in audio buffers

### Optimization Targets
- Audio thread: < 30% CPU usage
- UI: 60fps sustained
- Memory: < 100MB with 10 sources
- Startup time: < 2 seconds

## Debugging Tips

### Audio Engine Debug
```swift
// Add to AudioEngine.swift
print("🎵 Audio engine running: \(engine.isRunning)")
print("🎵 Current format: \(mainMixer.outputFormat(forBus: 0))")
print("🎵 Sample rate: \(mainMixer.outputFormat(forBus: 0).sampleRate)")
```

### Position Debug Overlay
```swift
// Add to SoundscapeCanvasView
.overlay {
    if isDebugMode {
        Text("X: \(source.position.x), Y: \(source.position.y)")
            .font(.caption2)
            .padding(4)
            .background(.red)
    }
}
```

### ViewModel State Logging
```swift
// Add property observer
var audioSources: [AudioSource] {
    didSet {
        AppLogger.debug("Sources updated: \(audioSources.count)", category: "ViewModel")
    }
}
```

## Code Style Guidelines

### Naming Conventions
- Types: PascalCase (e.g., `AudioSource`)
- Properties/Methods: camelCase (e.g., `playSource`)
- Constants: PascalCase in enum (e.g., `AppConstants.maxSources`)
- Private: prefix with underscore or mark clearly

### SwiftUI Best Practices
- Extract complex views into separate components
- Use `@Bindable` for ViewModel binding
- Prefer `@Observable` over `ObservableObject`
- Keep view bodies simple and readable

### Audio Code
- Always handle errors from AVFoundation
- Clean up audio resources in `deinit`
- Document audio threading considerations
- Use proper audio session categories

## Adding New Features

### Adding a New Audio Effect
1. Add parameter to `AudioParameters`
2. Create AVAudioUnit in `AudioEngine`
3. Connect in audio graph
4. Add UI control in `AudioControlPanelView`
5. Update ViewModel binding

### Adding a New Built-in Sound
1. Add case to `BuiltInSound` enum
2. Provide icon, color, and description
3. Add audio file to bundle
4. Update `AudioResources` if needed

### Adding Scene Presets
1. Create configuration in `DemoScenes`
2. Add to `allDemoScenes()` array
3. Test loading and playback
4. Add preview in `WelcomeView`

## Deployment

### Pre-Release Checklist
- [ ] Remove debug logging
- [ ] Optimize audio assets
- [ ] Test on multiple devices
- [ ] Verify spatial audio on AirPods
- [ ] Check background audio permissions
- [ ] Test low-power mode
- [ ] Verify file import/export
- [ ] Review privacy manifest
- [ ] Update version number
- [ ] Generate release notes

### App Store Assets
- Screenshots showing:
  - Main canvas with multiple sources
  - Control panel UI
  - Audio library
  - Demo scenes
- App preview video (optional)
- Privacy policy
- Support URL

## Future Enhancements

### Phase 2 Features
- Head tracking with CMHeadphoneMotionManager
- Audio recording and sampling
- Cloud sync via CloudKit
- Widget support
- SharePlay integration

### Phase 3 Features
- Higher-order ambisonics
- MIDI controller support
- Apple Watch companion
- Siri Shortcuts
- Live Activities

## Resources

### Documentation
- [AVFoundation Programming Guide](https://developer.apple.com/av-foundation/)
- [Spatial Audio Developer Resources](https://developer.apple.com/spatial-audio/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

### Sample Code
- [AVAudioEngine Examples](https://developer.apple.com/documentation/avfaudio/audio_engine)
- [3D Audio Positioning](https://developer.apple.com/documentation/avfaudio/audio_engine/audio_objects_and_3d_audio)

### Tools
- Instruments (Xcode profiling)
- Audio MIDI Setup (macOS audio config)
- RealityKit for spatial debugging

---

**Happy coding! 🎵**
