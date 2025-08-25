//
//  ShotFactory.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import Foundation
import SceneKit

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
        return makeDemoShots(for: players, configuration: .default)
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
                start: SCNVector3(startX, 1.0, startZ),
                rim: configuration.rimPosition,
                made: made,
                apexY: apexY
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
            start: position,
            rim: rimPosition,
            made: made,
            apexY: Float.random(in: 4.5...6.5)
        )
    }
}
