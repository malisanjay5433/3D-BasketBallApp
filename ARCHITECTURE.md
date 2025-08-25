# NBA 3D Shot Chart - Technical Architecture

## Overview
This document outlines the architectural foundation for an interactive 3D shot chart experience in an NBA mobile app. The system provides real-time 3D visualization of basketball shots with live data streaming, camera controls, and performance optimization.

## Architecture Decision: SceneKit (iOS)

### Why SceneKit?
- **Performance**: Native iOS integration with Metal under the hood, achieving 60fps on modern devices
- **Flexibility**: Built-in physics, animation, and camera controls
- **Team Familiarity**: Existing codebase already uses SceneKit
- **Cost**: No licensing fees (vs Unity)
- **Integration**: Seamless integration with iOS ecosystem

### Performance Characteristics
- **Target**: 60fps on iPhone 12+ and iPad Pro
- **Fallback**: 30fps on older devices with quality reduction
- **Memory**: Optimized for mobile with texture atlasing and LOD

## System Architecture

### High-Level Component Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐  │
│  │   UI Views  │ │  GameView   │ │   Camera Controls   │  │
│  └─────────────┘ └─────────────┘ └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    Business Logic Layer                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐  │
│  │GameViewModel│ │ShotFactory  │ │AnimationCoordinator│  │
│  └─────────────┘ └─────────────┘ └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    3D Engine Layer                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐  │
│  │SceneBuilder │ │SceneKit     │ │   Math Utils        │  │
│  │             │ │Wrapper      │ │                     │  │
│  └─────────────┘ └─────────────┘ └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    Data Layer                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐  │
│  │LiveDataFeed │ │PlayerData   │ │   Shot Cache        │  │
│  │             │ │Service      │ │                     │  │
│  └─────────────┘ └─────────────┘ └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Core Components

#### 1. SceneKitEngine (`SceneKitEngine.swift`)
- **Purpose**: Main 3D rendering engine wrapper
- **Responsibilities**:
  - Scene management and rendering lifecycle
  - Performance level management
  - Shot node management
  - Animation queue processing
- **Key Features**:
  - Performance level switching (Low/Medium/High)
  - Automatic frame rate monitoring
  - Shot animation queuing system

#### 2. LiveDataService (`LiveDataService.swift`)
- **Purpose**: Real-time shot data ingestion
- **Responsibilities**:
  - WebSocket connection management
  - Shot data validation and processing
  - Retry logic with exponential backoff
  - Connection status monitoring
- **Key Features**:
  - Automatic reconnection
  - Data validation pipeline
  - Mock data simulation for testing

#### 3. CameraController (`CameraController.swift`)
- **Purpose**: Advanced camera control system
- **Responsibilities**:
  - Multiple camera modes (Fixed, Free, Follow, Replay)
  - Smooth camera transitions
  - Gesture handling (pan, pinch)
  - Camera preset management
- **Key Features**:
  - 4 predefined camera positions
  - Smooth interpolation for camera movements
  - Constraint-based rotation system

#### 4. ShotFactory (`ShotFactory.swift`)
- **Purpose**: Shot data processing and validation
- **Responsibilities**:
  - Live data to ShotSpec conversion
  - Shot validation and quality scoring
  - Historical data support
  - Shot interpolation for missing frames
- **Key Features**:
  - Realistic shot trajectory calculation
  - Data validation with confidence scoring
  - Support for multiple shot types

#### 5. GameViewModel (`GameViewModel.swift`)
- **Purpose**: Main orchestration layer
- **Responsibilities**:
  - Component coordination
  - Live mode management
  - Performance monitoring
  - UI state management
- **Key Features**:
  - Reactive data binding with Combine
  - Performance level management
  - Live mode toggling

## Data Flow Architecture

### Live Data Pipeline
```
Live Shot Feed → WebSocket → LiveDataService → ShotFactory → SceneKitEngine → 3D Rendering
     ↓                    ↓                    ↓              ↓              ↓
Real-time API    →   Data Validation   →   ShotSpec   →   Animation   →   Visual Output
     ↓                    ↓                    ↓              ↓              ↓
Retry Logic      →   Frame Interpolation →   Physics     →   60fps Rendering
```

### Data Models

#### LiveShotData
```swift
struct LiveShotData: Codable {
    let id: String
    let gameId: String
    let playerId: String
    let playerName: String
    let teamId: String
    let timestamp: Date
    let shotType: String
    let distance: Float
    let startPosition: ShotPosition
    let endPosition: ShotPosition
    let result: ShotResult
    let metadata: [String: String]
}
```

#### ShotSpec (Enhanced)
```swift
struct ShotSpec {
    let playerUID: String
    let start: SCNVector3
    let rim: SCNVector3
    let made: Bool
    let apexY: Float
    let metadata: [String: String]  // New: Live data support
}
```

## Performance Optimization

### Frame Rate Targets
- **High Performance**: 60fps with full effects
- **Medium Performance**: 45fps with standard effects
- **Low Performance**: 30fps with basic effects

### Optimization Strategies
1. **Level of Detail (LOD)**: Reduce shot complexity based on distance
2. **Frustum Culling**: Only render shots visible to camera
3. **Texture Atlasing**: Combine multiple textures into single atlas
4. **Animation Batching**: Group similar animations together
5. **Memory Management**: Automatic cleanup of old shot data

### Fallback Mechanisms
- **Network Issues**: Show cached shots with "live" indicator
- **Performance Drops**: Auto-reduce quality to maintain frame rate
- **Device Limitations**: Progressive enhancement based on capabilities

## Camera System

### Camera Modes
1. **Fixed Mode**: Classic fan view (default)
2. **Free Mode**: User-controlled rotation and zoom
3. **Follow Mode**: Camera follows specific shots
4. **Replay Mode**: Smooth transitions between preset views

### Camera Presets
- **Fan View**: Mid-row sideline (default)
- **Baseline**: Behind the basket
- **Overhead**: Bird's eye view
- **Corner**: Three-point corner view

### Gesture Controls
- **Pan**: Rotate camera around arena
- **Pinch**: Zoom in/out with constraints
- **Double Tap**: Reset to default view

## Live Data Handling

### Connection Management
- **WebSocket**: Real-time bidirectional communication
- **Heartbeat**: 30-second ping/pong for connection health
- **Retry Logic**: Exponential backoff with max 5 attempts
- **Fallback**: Graceful degradation to offline mode

### Data Validation
- **Shot Distance**: Realistic range (0-50 feet)
- **Apex Height**: Physics-based validation
- **Position Constraints**: Court boundary checking
- **Confidence Scoring**: Quality assessment of received data

### Latency Handling
- **Frame Interpolation**: Smooth animation for missing frames
- **Shot Queuing**: Priority-based processing
- **Timestamp Synchronization**: Accurate shot timing

## Development Work Division

### Developer 1: 3D Engine & Rendering
- SceneKit engine wrapper and optimization
- Camera controls and viewport management
- Performance optimization and profiling
- 3D asset management

### Developer 2: Data & Animation
- Live data integration and validation
- Shot animation system
- UI and user experience
- Performance monitoring

## Testing & Quality Assurance

### Unit Testing
- Shot validation logic
- Camera movement calculations
- Performance level switching

### Integration Testing
- Live data pipeline
- 3D rendering performance
- Camera control responsiveness

### Performance Testing
- Frame rate monitoring
- Memory usage profiling
- Battery impact assessment

## Deployment Considerations

### iOS Version Support
- **Minimum**: iOS 14.0
- **Target**: iOS 17.0+
- **Optimized**: iOS 15.0+

### Device Compatibility
- **iPhone**: iPhone 11 and newer (60fps)
- **iPad**: iPad Air 4th gen and newer (60fps)
- **Fallback**: Older devices with reduced quality

### App Store Requirements
- Privacy policy for live data
- Network usage disclosure
- Performance optimization guidelines

## Future Enhancements

### Phase 2 Features
- Multi-camera replay system
- Advanced shot analytics
- Social sharing integration
- AR overlay support

### Phase 3 Features
- Cross-platform support (Android)
- Cloud-based shot storage
- Machine learning shot prediction
- VR headset support

## Conclusion

This architecture provides a solid foundation for a high-performance 3D shot chart experience. The modular design allows for easy maintenance and future enhancements while maintaining the performance requirements for mobile devices. The SceneKit-based approach leverages existing team expertise while providing the flexibility needed for complex 3D interactions.

The system is designed to handle real-world challenges like network latency, device performance variations, and data quality issues, ensuring a smooth user experience across different conditions.
