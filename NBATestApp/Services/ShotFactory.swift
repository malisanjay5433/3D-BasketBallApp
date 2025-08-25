//
//  ShotFactory.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import Foundation
import SceneKit
import Combine

// MARK: - Live Data Integration
extension ShotFactory {
    
    /// Processes live shot data and converts it to ShotSpec
    /// - Parameter liveData: Live shot data from the data service
    /// - Returns: ShotSpec object ready for animation
    static func createShotSpec(from liveData: LiveShotData) -> ShotSpec {
        let startPosition = SCNVector3(
            liveData.startPosition.x,
            liveData.startPosition.y,
            liveData.startPosition.z
        )
        
        let rimPosition = SCNVector3(
            liveData.endPosition.x,
            liveData.endPosition.y,
            liveData.endPosition.z
        )
        
        // Calculate apex based on distance and shot type
        let apexY = calculateApexY(for: liveData.shotType, distance: liveData.distance)
        
        return ShotSpec(
            playerUID: liveData.playerId,
            playerName: liveData.playerName,
            start: startPosition,
            rim: rimPosition,
            made: liveData.result == .made,
            apexY: apexY,
            metadata: [
                "shotType": liveData.shotType,
                "distance": String(liveData.distance),
                "timestamp": ISO8601DateFormatter().string(from: liveData.timestamp),
                "teamId": liveData.teamId
            ]
        )
    }
    
    /// Creates a shot from historical data
    /// - Parameter historicalData: Historical shot data
    /// - Returns: ShotSpec object
    static func createShotSpec(from historicalData: HistoricalShotData) -> ShotSpec {
        let startPosition = SCNVector3(
            historicalData.startPosition.x,
            historicalData.startPosition.y,
            historicalData.startPosition.z
        )
        
        let rimPosition = SCNVector3(
            historicalData.endPosition.x,
            historicalData.endPosition.y,
            historicalData.endPosition.z
        )
        
        let apexY = calculateApexY(for: historicalData.shotType, distance: historicalData.distance)
        
        return ShotSpec(
            playerUID: historicalData.playerId,
            playerName: historicalData.playerName,
            start: startPosition,
            rim: rimPosition,
            made: historicalData.result == .made,
            apexY: apexY,
            metadata: [
                "shotType": historicalData.shotType,
                "distance": String(historicalData.distance),
                "gameDate": historicalData.gameDate.description,
                "quarter": String(historicalData.quarter),
                "timeRemaining": historicalData.timeRemaining.description
            ]
        )
    }
    
    /// Calculates realistic apex height based on shot type and distance
    /// - Parameters:
    ///   - shotType: Type of shot (2PT, 3PT, Free Throw, etc.)
    ///   - distance: Distance from basket in feet
    /// - Returns: Apex Y coordinate
    private static func calculateApexY(for shotType: String, distance: Float) -> Float {
        let baseApex: Float
        
        switch shotType.uppercased() {
        case "FREE_THROW":
            baseApex = 4.5
        case "2PT":
            baseApex = 5.0
        case "3PT":
            baseApex = 5.5
        case "DUNK":
            baseApex = 3.5
        case "LAYUP":
            baseApex = 4.0
        default:
            baseApex = 5.0
        }
        
        // Adjust for distance
        let distanceFactor = min(1.5, distance / 20.0)
        return baseApex + distanceFactor
    }
}

// MARK: - Historical Data Support
struct HistoricalShotData {
    let id: String
    let playerId: String
    let playerName: String
    let teamId: String
    let gameDate: Date
    let quarter: Int
    let timeRemaining: TimeInterval
    let shotType: String
    let distance: Float
    let startPosition: ShotPosition
    let endPosition: ShotPosition
    let result: ShotResult
    let metadata: [String: String]
}

// MARK: - Shot Validation
extension ShotFactory {
    
    /// Validates shot data for consistency and realism
    /// - Parameter shot: ShotSpec to validate
    /// - Returns: Validation result with any issues
    static func validateShot(_ shot: ShotSpec) -> ShotValidationResult {
        var issues: [String] = []
        
        // Check distance
        let distance = MathUtils.distance(from: shot.start, to: shot.rim)
        if distance > 50.0 {
            issues.append("Shot distance (\(distance)ft) exceeds realistic range")
        }
        
        // Check apex height
        if shot.apexY < 2.0 || shot.apexY > 10.0 {
            issues.append("Apex height (\(shot.apexY)) is unrealistic")
        }
        
        // Check start position
        if shot.start.y < 0.5 || shot.start.y > 3.0 {
            issues.append("Start height (\(shot.start.y)) is unrealistic")
        }
        
        return ShotValidationResult(
            isValid: issues.isEmpty,
            issues: issues,
            confidence: calculateConfidence(issues: issues)
        )
    }
    
    private static func calculateConfidence(issues: [String]) -> Float {
        let baseConfidence: Float = 1.0
        let penaltyPerIssue: Float = 0.2
        let penalty = Float(issues.count) * penaltyPerIssue
        return max(0.0, baseConfidence - penalty)
    }
}

struct ShotValidationResult {
    let isValid: Bool
    let issues: [String]
    let confidence: Float
}

// MARK: - Shot Interpolation
extension ShotFactory {
    
    /// Interpolates missing shot data for smooth animation
    /// - Parameters:
    ///   - startShot: Starting shot data
    ///   - endShot: Ending shot data
    ///   - frameCount: Number of frames to interpolate
    /// - Returns: Array of interpolated shot positions
    static func interpolateShotPath(from startShot: ShotSpec, 
                                  to endShot: ShotSpec, 
                                  frameCount: Int) -> [SCNVector3] {
        var positions: [SCNVector3] = []
        
        for i in 0..<frameCount {
            let progress = Float(i) / Float(frameCount - 1)
            let position = interpolatePosition(
                from: startShot.start,
                to: endShot.start,
                progress: progress
            )
            positions.append(position)
        }
        
        return positions
    }
    
    private static func interpolatePosition(from start: SCNVector3, 
                                          to end: SCNVector3, 
                                          progress: Float) -> SCNVector3 {
        return SCNVector3(
            start.x + (end.x - start.x) * progress,
            start.y + (end.y - start.y) * progress,
            start.z + (end.z - start.z) * progress
        )
    }
    
    /// Processes live shot data and adds it to the scene
    /// - Parameter liveData: Live shot data to process
    static func processLiveShot(_ liveData: LiveShotData) {
        // This method is called by LiveDataService to process incoming shots
        // In a real implementation, this would coordinate with the scene engine
        print("🏀 Processing live shot: \(liveData.playerName) - \(liveData.result.rawValue)")
    }
}

// MARK: - Configuration
struct ShotFactory {
    
    // MARK: - Configuration
    struct ShotConfiguration {
        let rimPosition: SCNVector3
        let maxPlayers: Int
        let startXRange: ClosedRange<Float>
        let startZRange: ClosedRange<Float>
        let apexYRange: ClosedRange<Float>
        let successRate: Float // 0.0 to 1.0
        
		static let `default` = ShotConfiguration(
            rimPosition: SCNVector3(0, 3.05, -8),
            maxPlayers: 6,
            startXRange: -5.0...5.0,
            startZRange: -2.0...0.0,
            apexYRange: 5.0...6.0,
            successRate: 0.5
        )
    }
    
    // MARK: - Public Methods
    
    /// Creates demo shots for the given players using default configuration
    /// - Parameter players: Array of players to generate shots for
    /// - Returns: Array of ShotSpec objects
    static func makeDemoShots(for players: [Player]) -> [ShotSpec] {
        print("🎯 makeDemoShots called with \(players.count) players")
        let shots = makeDemoShots(for: players, configuration: .default)
        print("🎯 Generated \(shots.count) demo shots")
        return shots
    }
    
    /// Creates demo shots for the given players using custom configuration
    /// - Parameters:
    ///   - players: Array of players to generate shots for
    ///   - configuration: Custom shot configuration
    /// - Returns: Array of ShotSpec objects
    static func makeDemoShots(for players: [Player], configuration: ShotConfiguration) -> [ShotSpec] {
        let maxPlayers = min(configuration.maxPlayers, players.count)
        
        return (0..<maxPlayers).map { index in
            let player = players[index]
            
            // Generate random shot parameters within configured ranges
            let startX = Float.random(in: configuration.startXRange)
            let startZ = Float.random(in: configuration.startZRange)
            let apexY = Float.random(in: configuration.apexYRange)
            
            // Determine if shot was made based on success rate
            let made = Float.random(in: 0...1) < configuration.successRate
            
            return ShotSpec(
                playerUID: player.uid,
                playerName: player.personName.name,
                start: SCNVector3(startX, 1.0, startZ),
                rim: configuration.rimPosition,
                made: made,
                apexY: apexY,
                metadata: [:]
            )
        }
    }
    
    /// Creates a realistic shot pattern for a specific player position
    /// - Parameters:
    ///   - player: The player taking the shot
    ///   - position: The player's position on the court
    ///   - difficulty: Shot difficulty (0.0 = easy, 1.0 = hard)
    /// - Returns: ShotSpec object
    static func makeRealisticShot(for player: Player, 
                                at position: SCNVector3, 
                                difficulty: Float) -> ShotSpec {
        
        let configuration = ShotConfiguration.default
        let rimPosition = configuration.rimPosition
        
        // Adjust success rate based on difficulty and distance
        let distance = MathUtils.distance(from: position, to: rimPosition)
        let baseSuccessRate = max(0.1, 1.0 - (difficulty * 0.8))
        let distanceFactor = max(0.3, 1.0 - (distance / 10.0))
        let finalSuccessRate = baseSuccessRate * distanceFactor
        
        let made = Float.random(in: 0...1) < finalSuccessRate
        
        return ShotSpec(
            playerUID: player.uid,
            playerName: player.personName.name,
            start: position,
            rim: rimPosition,
            made: made,
            apexY: Float.random(in: 4.5...6.5),
            metadata: [:]
        )
    }
}
