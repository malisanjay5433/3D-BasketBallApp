# NBA Test App - Clean Architecture

## Overview
This NBA basketball visualization app has been restructured to follow clean architecture principles, improving maintainability, testability, and code organization.

## Architecture Overview

### 🏗️ **Clean Architecture Layers**

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   ContentView   │  │  GameViewModel  │  │ UI Views    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                       Business Logic Layer                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │ SceneController │  │ ShotFactory     │  │ MathUtils   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┐
│                        Data Layer                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │PlayerDataService│  │   Models        │  │ Resources   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                     SceneKit Engine Layer                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  SceneBuilder   │  │ShotAnimationSvc │  │  Constants  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📁 **Directory Structure**

```
NBATestApp/
├── Models/                          # Data models and constants
│   ├── Player.swift                 # Player data model
│   ├── ShotSpec.swift               # Shot specification model
│   └── GameConstants.swift          # Centralized game constants
├── Services/                        # Business logic services
│   ├── SceneController.swift        # Main scene orchestration
│   ├── PlayerDataService.swift      # Player data management
│   └── ShotFactory.swift            # Shot generation logic
├── SceneKitEngine/                  # 3D rendering engine
│   ├── SceneBuilder.swift           # Scene construction
│   ├── ShotAnimationService.swift   # Shot animation logic
│   └── MathUtils.swift              # Mathematical utilities
├── UI/                             # User interface components
│   ├── ContentView.swift            # Main view
│   ├── GameViewModel.swift          # View model for game logic
│   ├── ArenaSegmentedControl.swift  # Team selection control
│   ├── PlaybackControls.swift       # Playback control buttons
│   └── PlayerOverlayView.swift      # Player information overlay
└── Resources/                       # Static assets
    ├── crowd.jpg                    # Audience backdrop
    └── Player JSON files            # Team player data
```

## 🔧 **Key Components**

### **Models Layer**
- **`Player.swift`**: Player data structure with Codable support
- **`ShotSpec.swift`**: Shot trajectory and result specification
- **`GameConstants.swift`**: Centralized configuration values

### **Services Layer**
- **`SceneController.swift`**: Orchestrates scene and animation flow
- **`PlayerDataService.swift`**: Handles player data loading and parsing
- **`ShotFactory.swift`**: Generates realistic shot patterns

### **SceneKit Engine Layer**
- **`SceneBuilder.swift`**: Constructs 3D basketball court scene
- **`ShotAnimationService.swift`**: Manages ball flight and effects
- **`MathUtils.swift`**: Mathematical calculations for trajectories

### **UI Layer**
- **`ContentView.swift`**: Main SwiftUI view with scene integration
- **`GameViewModel.swift`**: Business logic for UI state management
- **`ArenaSegmentedControl.swift`**: Custom team selection control
- **`PlaybackControls.swift`**: Playback control interface
- **`PlayerOverlayView.swift`**: Player information display

## 🚀 **Key Improvements**

### **1. Separation of Concerns**
- **SceneController**: Now focuses only on orchestration
- **SceneBuilder**: Dedicated to scene construction
- **ShotAnimationService**: Handles all animation logic
- **GameViewModel**: Manages UI state and business logic

### **2. Centralized Configuration**
- **GameConstants**: All magic numbers and configuration values centralized
- **Easy maintenance**: Change values in one place
- **Consistent behavior**: All components use same constants

### **3. Better Error Handling**
- **PlayerDataService**: Robust error handling with custom error types
- **Async/await support**: Modern Swift concurrency patterns
- **Graceful fallbacks**: App continues working even with data errors

### **4. Improved Testability**
- **Dependency injection**: Services can be easily mocked
- **Single responsibility**: Each class has one clear purpose
- **Protocol-based design**: Easy to create test doubles

### **5. Enhanced Maintainability**
- **Clear file organization**: Logical grouping of related functionality
- **Consistent naming**: Descriptive names following Swift conventions
- **Documentation**: Comprehensive code comments and documentation

## 🔄 **Data Flow**

```
1. User selects team → GameViewModel.loadTeamAndPrepareShots()
2. PlayerDataService loads player data from JSON
3. ShotFactory generates shot specifications
4. GameViewModel updates UI state
5. ContentView observes changes and updates SceneController
6. SceneController loads shots and manages playback
7. ShotAnimationService animates individual shots
8. SceneBuilder provides 3D scene infrastructure
```

## 🎯 **Usage Examples**

### **Creating Custom Shot Configuration**
```swift
let config = ShotFactory.ShotConfiguration(
    rimPosition: SCNVector3(0, 3.05, -8),
    maxPlayers: 8,
    startXRange: -6.0...6.0,
    startZRange: -3.0...1.0,
    apexYRange: 4.5...7.0,
    successRate: 0.7
)

let shots = ShotFactory.makeDemoShots(for: players, configuration: config)
```

### **Customizing Game Constants**
```swift
// In GameConstants.swift
struct Animation {
    static let shotDuration: TimeInterval = 2.0  // Slower shots
    static let cleanupDelay: TimeInterval = 0.5  // Longer effects
}
```

## 🧪 **Testing Strategy**

### **Unit Tests**
- **Services**: Test business logic in isolation
- **Models**: Validate data structures and transformations
- **Utilities**: Test mathematical calculations

### **Integration Tests**
- **SceneController**: Test scene orchestration flow
- **AnimationService**: Test shot animation sequences
- **DataFlow**: Test end-to-end data loading and display

### **UI Tests**
- **User Interactions**: Test team selection and playback controls
- **State Management**: Verify UI updates with data changes
- **Accessibility**: Ensure app is accessible to all users

## 🔮 **Future Enhancements**

### **Planned Improvements**
1. **Network Layer**: API integration for real-time data
2. **Caching**: Local data persistence and offline support
3. **Analytics**: Shot statistics and player performance metrics
4. **Multiplayer**: Real-time collaborative viewing
5. **Customization**: User-configurable court layouts and themes

### **Architecture Extensions**
1. **Repository Pattern**: Abstract data access layer
2. **Coordinator Pattern**: Better navigation management
3. **Reactive Programming**: Combine framework integration
4. **Modular Design**: Feature-based module separation

## 📚 **Dependencies**

- **SwiftUI**: Modern declarative UI framework
- **SceneKit**: 3D graphics and animation
- **Foundation**: Core data structures and utilities
- **simd**: Vector mathematics for 3D calculations

## 🤝 **Contributing**

1. Follow the established architecture patterns
2. Use GameConstants for all configuration values
3. Maintain separation of concerns
4. Add comprehensive documentation
5. Include unit tests for new functionality

## 📋 **Development Planning**

For detailed development planning, team structure, and work delegation, see [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md).

## 📄 **License**

This project is part of the NBA Test App development effort.
