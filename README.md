# NBA Test App - Clean Architecture

This iOS app demonstrates NBA player visualization using SceneKit with a scalable Clean Architecture implementation.

## 🏗️ Architecture Overview

The app follows **Clean Architecture** principles, separating concerns into distinct layers with clear dependencies and boundaries.

### Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   ContentView   │  │ PlayerViewModel │  │ UI Views    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │     Entities    │  │   Use Cases     │  │Repository   │ │
│  │                 │  │                 │  │ Protocols   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  Repositories   │  │  Data Sources   │  │    DTOs     │ │
│  │                 │  │                 │  │             │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Infrastructure Layer                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Extensions    │  │ SceneKit Engine │  │ DI Container│ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
NBATestApp/
├── Architecture/
│   ├── Domain/                    # Business Logic Layer
│   │   ├── Entities/              # Core business objects
│   │   │   ├── Player.swift
│   │   │   ├── ShotSpec.swift
│   │   │   └── Team.swift
│   │   ├── UseCases/              # Business rules & operations
│   │   │   ├── PlayerUseCase.swift
│   │   │   └── ShotUseCase.swift
│   │   └── Repositories/          # Data access contracts
│   │       └── PlayerRepositoryProtocol.swift
│   ├── Data/                      # Data Access Layer
│   │   ├── Repositories/          # Repository implementations
│   │   │   └── PlayerRepository.swift
│   │   └── DataSources/           # Data source implementations
│   │       ├── PlayerDataSourceProtocol.swift
│   │       └── LocalPlayerDataSource.swift
│   ├── Presentation/              # UI Layer
│   │   ├── ViewModels/            # Presentation logic
│   │   │   └── PlayerViewModel.swift
│   │   └── Views/                 # SwiftUI views
│   │       └── ContentView.swift
│   ├── Infrastructure/            # Cross-cutting concerns
│   │   └── Extensions/            # Utility extensions
│   │       ├── Player+Mapping.swift
│   │       └── PlayerDTO+Extensions.swift
│   └── DI/                       # Dependency Injection
│       └── DependencyContainer.swift
├── Models/                        # Legacy models (to be removed)
├── Services/                      # Legacy services (to be removed)
├── UI/                           # Legacy UI (to be removed)
└── SceneKitEngine/               # 3D rendering engine
```

## 🔄 Dependency Flow

The dependency flow follows the **Dependency Inversion Principle**:

1. **Presentation Layer** depends on **Domain Layer** (Use Cases)
2. **Domain Layer** depends on **Data Layer** (Repository Protocols)
3. **Data Layer** implements **Domain Layer** contracts
4. **Infrastructure Layer** provides cross-cutting utilities

```
ContentView → PlayerViewModel → PlayerUseCase → PlayerRepositoryProtocol
                                                      ↓
                                              PlayerRepository → PlayerDataSourceProtocol
                                                                      ↓
                                                              LocalPlayerDataSource
```

## 🚀 Key Benefits

### 1. **Separation of Concerns**
- Each layer has a single responsibility
- Business logic is isolated from UI and data access
- Easy to modify one layer without affecting others

### 2. **Testability**
- Use Cases can be tested independently
- Repository protocols enable easy mocking
- ViewModels can be tested with fake dependencies

### 3. **Scalability**
- Easy to add new features by extending existing layers
- New data sources can be added without changing business logic
- UI changes don't affect business rules

### 4. **Maintainability**
- Clear dependencies make code easier to understand
- Consistent patterns across the codebase
- Easy to locate and fix issues

### 5. **Flexibility**
- Easy to swap implementations (e.g., local data → API data)
- New platforms can reuse business logic
- Database changes don't affect UI

## 🧪 Testing Strategy

### Unit Tests
- **Use Cases**: Test business logic with mocked repositories
- **ViewModels**: Test with fake use cases
- **Repositories**: Test with fake data sources

### Integration Tests
- Test complete data flow from data source to UI
- Verify mapping between DTOs and domain entities

### UI Tests
- Test user interactions and state changes
- Verify proper error handling and loading states

## 🔧 Adding New Features

### 1. **New Entity**
```swift
// 1. Create domain entity in Architecture/Domain/Entities/
struct Game: Identifiable, Equatable {
    let id: String
    let homeTeam: Team
    let awayTeam: Team
    let date: Date
}

// 2. Create repository protocol in Architecture/Domain/Repositories/
protocol GameRepositoryProtocol {
    func getGames() async throws -> [Game]
}

// 3. Create use case in Architecture/Domain/UseCases/
protocol GameUseCaseProtocol {
    func getUpcomingGames() async throws -> [Game]
}
```

### 2. **New Data Source**
```swift
// 1. Create data source protocol
protocol GameDataSourceProtocol {
    func fetchGames() async throws -> [GameDTO]
}

// 2. Implement concrete data source
final class APIGameDataSource: GameDataSourceProtocol {
    func fetchGames() async throws -> [GameDTO] {
        // API implementation
    }
}
```

### 3. **New UI Feature**
```swift
// 1. Create ViewModel
@MainActor
final class GameViewModel: ObservableObject {
    @Published var games: [Game] = []
    private let gameUseCase: GameUseCaseProtocol
    
    // Implementation
}

// 2. Create SwiftUI View
struct GameListView: View {
    @StateObject private var viewModel: GameViewModel
    
    // UI implementation
}
```

## 📱 Current Features

- **Team Selection**: Switch between Pacers and Nets
- **Player Visualization**: 3D court with player representations
- **Shot Animation**: Animated basketball shots with physics
- **Error Handling**: Graceful error handling with retry options
- **Loading States**: Proper loading indicators during data fetch

## 🎯 Future Enhancements

- **API Integration**: Replace local JSON with live NBA API
- **Caching**: Implement local caching for offline support
- **Real-time Updates**: Live game data and statistics
- **User Preferences**: Save user's favorite teams and players
- **Analytics**: Track user interactions and app performance

## 🛠️ Development Setup

1. **Clone the repository**
2. **Open `NBATestApp.xcodeproj`** in Xcode
3. **Build and run** the project
4. **Select a team** to see players and shots

## 📚 Dependencies

- **SwiftUI**: Modern declarative UI framework
- **SceneKit**: 3D graphics and physics engine
- **Foundation**: Core iOS functionality
- **Combine**: Reactive programming (future enhancement)

## 🤝 Contributing

When contributing to this project:

1. **Follow Clean Architecture principles**
2. **Add tests for new features**
3. **Update documentation**
4. **Use the dependency container for new dependencies**
5. **Follow Swift naming conventions**

## 📄 License

This project is for educational and demonstration purposes.
