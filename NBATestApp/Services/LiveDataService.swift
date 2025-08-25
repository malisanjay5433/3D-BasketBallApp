//
//  LiveDataService.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import Foundation
import Combine

// MARK: - Live Data Protocol
protocol LiveDataServiceProtocol: AnyObject {
    var isConnected: Bool { get }
    var connectionStatus: ConnectionStatus { get }
    
    func connect()
    func disconnect()
    func subscribeToGame(_ gameId: String)
    func setRetryPolicy(_ policy: RetryPolicy)
}

// MARK: - Connection Status
enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case error(String)
    
    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .reconnecting: return "Reconnecting..."
        case .error(let message): return "Error: \(message)"
        }
    }
}

// MARK: - Retry Policy
struct RetryPolicy {
    let maxRetries: Int
    let baseDelay: TimeInterval
    let maxDelay: TimeInterval
    let backoffMultiplier: Double
    
    static let `default` = RetryPolicy(
        maxRetries: 5,
        baseDelay: 1.0,
        maxDelay: 30.0,
        backoffMultiplier: 2.0
    )
}

// MARK: - Live Shot Data
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

struct ShotPosition: Codable {
    let x: Float
    let y: Float
    let z: Float
}

enum ShotResult: String, Codable {
    case made = "MADE"
    case missed = "MISSED"
    case blocked = "BLOCKED"
}

// MARK: - Main Service
final class LiveDataService: NSObject, LiveDataServiceProtocol {
    
    // MARK: - Properties
    private(set) var isConnected: Bool = false
    private(set) var connectionStatus: ConnectionStatus = .disconnected
    
    private var webSocket: URLSessionWebSocketTask?
    private var retryPolicy: RetryPolicy = .default
    private var retryCount: Int = 0
    private var currentGameId: String?
    private var shotDataSubject = PassthroughSubject<LiveShotData, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Dependencies
    private let shotFactory: ShotFactory
    private let queue = DispatchQueue(label: "com.nba.livedata", qos: .userInitiated)
    
    // MARK: - Initialization
    init(shotFactory: ShotFactory) {
        self.shotFactory = shotFactory
        super.init()
        setupDataPipeline()
    }
    
    // MARK: - Public Methods
    func connect() {
        if case .connecting = connectionStatus { return }
        if case .connected = connectionStatus { return }
        
        connectionStatus = .connecting
        establishWebSocketConnection()
    }
    
    func disconnect() {
        webSocket?.cancel()
        webSocket = nil
        connectionStatus = .disconnected
        isConnected = false
        print("🔌 Live Data Service: Disconnected")
    }
    
    func subscribeToGame(_ gameId: String) {
        currentGameId = gameId
        if isConnected {
            sendSubscriptionMessage(for: gameId)
        }
        print("🎮 Live Data Service: Subscribed to game \(gameId)")
    }
    
    func setRetryPolicy(_ policy: RetryPolicy) {
        retryPolicy = policy
    }
    
    // MARK: - Private Methods
    private func establishWebSocketConnection() {
        guard let url = URL(string: "wss://api.nba.com/live/game") else {
            connectionStatus = .error("Invalid WebSocket URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        
        startReceiving()
        startHeartbeat()
    }
    
    private func startReceiving() {
        webSocket?.receive { [weak self] result in
            DispatchQueue.main.async {
                self?.handleWebSocketMessage(result)
            }
        }
    }
    
    private func startHeartbeat() {
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.sendHeartbeat()
        }
    }
    
    private func handleWebSocketMessage(_ result: Result<URLSessionWebSocketTask.Message, Error>) {
        switch result {
        case .success(let message):
            switch message {
            case .string(let text):
                handleTextMessage(text)
            case .data(let data):
                handleDataMessage(data)
            @unknown default:
                break
            }
            // Continue receiving
            startReceiving()
            
        case .failure(let error):
            handleConnectionError(error)
        }
    }
    
    private func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            let shotData = try JSONDecoder().decode(LiveShotData.self, from: data)
            processLiveShotData(shotData)
        } catch {
            print("❌ Failed to decode shot data: \(error)")
        }
    }
    
    private func handleDataMessage(_ data: Data) {
        do {
            let shotData = try JSONDecoder().decode(LiveShotData.self, from: data)
            processLiveShotData(shotData)
        } catch {
            print("❌ Failed to decode shot data: \(error)")
        }
    }
    
    private func processLiveShotData(_ shotData: LiveShotData) {
        // Validate shot data
        guard validateShotData(shotData) else {
            print("⚠️ Invalid shot data received: \(shotData.id)")
            return
        }
        
        // Convert to ShotSpec
        let shotSpec = ShotFactory.createShotSpec(from: shotData)
        
        // Publish to subscribers
        shotDataSubject.send(shotData)
        
        print("🏀 Live shot processed: \(shotData.playerName) - \(shotData.result.rawValue)")
    }
    
    private func validateShotData(_ shotData: LiveShotData) -> Bool {
        // Basic validation
        guard !shotData.id.isEmpty,
              !shotData.playerName.isEmpty,
              shotData.distance > 0,
              shotData.distance < 100 else {
            return false
        }
        
        return true
    }
    
    private func handleConnectionError(_ error: Error) {
        connectionStatus = .error(error.localizedDescription)
        isConnected = false
        print("❌ WebSocket error: \(error.localizedDescription)")
        
        // Attempt retry
        if retryCount < retryPolicy.maxRetries {
            scheduleRetry()
        } else {
            connectionStatus = .error("Max retries exceeded")
        }
    }
    
    private func scheduleRetry() {
        retryCount += 1
        let delay = min(
            retryPolicy.baseDelay * pow(retryPolicy.backoffMultiplier, Double(retryCount - 1)),
            retryPolicy.maxDelay
        )
        
        connectionStatus = .reconnecting
        print("🔄 Scheduling retry \(retryCount) in \(delay)s")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.establishWebSocketConnection()
        }
    }
    
    private func sendSubscriptionMessage(for gameId: String) {
        let subscription: [String: Any] = [
            "type": "subscribe",
            "gameId": gameId,
            "events": ["shot", "score", "gameState"]
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: subscription),
           let message = String(data: data, encoding: .utf8) {
            webSocket?.send(.string(message)) { error in
                if let error = error {
                    print("❌ Failed to send subscription: \(error)")
                }
            }
        }
    }
    
    private func sendHeartbeat() {
        let heartbeat: [String: String] = ["type": "ping"]
        if let data = try? JSONSerialization.data(withJSONObject: heartbeat),
           let message = String(data: data, encoding: .utf8) {
            webSocket?.send(.string(message)) { _ in }
        }
    }
    
    private func setupDataPipeline() {
        // Connect to shot factory for processing
        shotDataSubject
            .sink { [weak self] shotData in
                ShotFactory.processLiveShot(shotData)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Mock Data for Testing
extension LiveDataService {
    func simulateLiveShot() {
        let mockShot = LiveShotData(
            id: UUID().uuidString,
            gameId: "mock_game_001",
            playerId: "mock_player_001",
            playerName: "Mock Player",
            teamId: "mock_team_001",
            timestamp: Date(),
            shotType: "3PT",
            distance: 24.0,
            startPosition: ShotPosition(x: 8.0, y: 2.0, z: -6.0),
            endPosition: ShotPosition(x: 0.0, y: 3.05, z: -8.0),
            result: .made,
            metadata: [:]
        )
        
        processLiveShotData(mockShot)
    }
}
