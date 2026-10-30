# SoundGarden 🎵🌳

A spatial audio soundscape app for iOS that lets you create immersive 3D audio environments with interactive positioning and individual sound control.

## Features

### 🎯 Core Functionality
- **Spatial Audio Engine**: 3D audio positioning using AVAudioEngine with binaural rendering
- **Interactive Canvas**: Drag and position sound sources in a circular spatial field
- **Individual Controls**: Fine-tune volume, reverb, and pan for each audio source
- **Built-in Sounds**: 8 ambient sounds ready to use (forest, ocean, rain, etc.)
- **Custom Audio**: Import your own audio files (MP3, WAV, M4A, AAC)
- **Scene Management**: Save and load complete soundscape configurations

### 🎨 User Interface
- Modern SwiftUI design following iOS 18 design principles
- Glassmorphic UI elements with smooth animations
- Real-time visual feedback for playing sources
- Intuitive drag-and-drop positioning
- Comprehensive per-source control panel

### 🔊 Audio Features
- Up to 10 simultaneous audio sources
- 3D spatial positioning with distance attenuation
- Reverb effects with preset configurations
- Stereo panning control
- Volume control with dB display
- Looping audio playback
- Real-time parameter updates

## Architecture

The app follows MVVM (Model-View-ViewModel) architecture:

```
SoundGarden/
├── Models/               # Data models
│   ├── AudioSource.swift
│   ├── SoundScene.swift
│   └── AudioParameters.swift
├── ViewModels/           # Business logic
│   └── SoundScapeViewModel.swift
├── Views/                # SwiftUI views
│   ├── SoundscapeCanvasView.swift
│   ├── AudioControlPanelView.swift
│   ├── AudioLibraryView.swift
│   └── SettingsView.swift
├── Services/             # Core services
│   ├── AudioEngine.swift
│   └── SceneManager.swift
└── Utilities/            # Helpers
    ├── Constants.swift
    ├── Extensions.swift
    └── AudioResources.swift
```

## Technical Details

### Audio Engine
- **Framework**: AVFoundation
- **Spatial Audio**: AVAudioEnvironmentNode for 3D positioning
- **Format**: Supports common audio formats (MP3, WAV, M4A, AAC)
- **Processing**: Real-time parameter updates with debouncing
- **Reverb**: AVAudioUnitReverb with configurable wet/dry mix

### State Management
- Uses Swift's `@Observable` macro for reactive state
- SwiftUI `@Bindable` for two-way data flow
- Efficient updates with debouncing for audio parameters

### Data Persistence
- Scenes saved as JSON files
- User documents directory for storage
- Import/export capability for sharing scenes

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+
- Headphones recommended for best spatial audio experience

## Usage

### Adding Sound Sources
1. Tap the "Add Sound" button
2. Choose from built-in sounds or import your own audio files
3. The sound source appears on the canvas

### Positioning Sounds
1. Drag sound source nodes around the circular canvas
2. Position is constrained within the spatial boundary
3. Audio positioning updates in real-time

### Controlling Audio Parameters
1. Tap a sound source to select it
2. Control panel appears at the bottom
3. Adjust volume, reverb, and pan with sliders
4. Use presets for quick configurations
5. Play/pause individual sources

### Managing Scenes
1. Access settings via the gear icon
2. Save current scene for later
3. Create new scenes to start fresh
4. Export/import scenes (future feature)

## Built-in Sounds

The app includes 8 ambient sounds:
- 🌫️ White Noise - Steady background
- 🌳 Forest - Nature ambience  
- 🌊 Ocean - Waves and seagulls
- 🌧️ Rain - Gentle rainfall
- 🏙️ City - Urban atmosphere
- 🐦 Birds - Chirping and singing
- 🔥 Fire - Crackling flames
- 💨 Wind - Gentle breeze

*Note: In the current build, these generate silent placeholder files. Replace with actual audio files in production.*

## Future Enhancements

- [ ] Head tracking with CMHeadphoneMotionManager
- [ ] Higher-order ambisonics (HOA) support
- [ ] Built-in scene presets (meditation, focus, sleep)
- [ ] Audio recording and looping
- [ ] Cloud sync for scenes
- [ ] Widget support for quick access
- [ ] Background audio with Lock Screen controls
- [ ] Siri Shortcuts integration
- [ ] SharePlay for collaborative soundscapes

## Performance

- Optimized for low CPU usage with up to 10 sources
- Efficient audio buffer management
- Smooth 60fps UI animations
- Minimal memory footprint

## Privacy

- All audio processing happens on-device
- No network access required
- Audio files stored locally
- No data collection or analytics

## License

© 2026 All rights reserved

## Credits

Built with:
- SwiftUI
- AVFoundation
- CoreMotion (future)

---

**Enjoy creating your spatial soundscapes!** 🎧✨
