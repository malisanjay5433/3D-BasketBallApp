//
//  ShotSpec.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import Foundation
import SceneKit

// Shot specification (driven by code / or from your shot JSON)
struct ShotSpec: Identifiable, Equatable {
	static func == (lhs: ShotSpec, rhs: ShotSpec) -> Bool {
		return lhs.id == rhs.id
	}
	
    let id = UUID()
    let playerUID: String
    let playerName: String  // Added for live data support
    let start: SCNVector3   // [x,y,z]
    let rim: SCNVector3
    let made: Bool
    let apexY: Float
    let metadata: [String: String]  // Added for live data support
    
    // MARK: - Computed Properties
    
    /// Distance from start position to rim in feet
    var distance: Float {
        return MathUtils.distance(from: start, to: rim)
    }
    
    /// Start position as a readable property
    var startPosition: SCNVector3 {
        return start
    }
    
    // MARK: - Initializers
    
    // Default initializer for existing code
    init(playerUID: String, start: SCNVector3, rim: SCNVector3, made: Bool, apexY: Float) {
        self.playerUID = playerUID
        self.playerName = playerUID  // Default to UID if no name provided
        self.start = start
        self.rim = rim
        self.made = made
        self.apexY = apexY
        self.metadata = [:]
    }
    
    // Enhanced initializer for live data
    init(playerUID: String, playerName: String, start: SCNVector3, rim: SCNVector3, made: Bool, apexY: Float, metadata: [String: String] = [:]) {
        self.playerUID = playerUID
        self.playerName = playerName
        self.start = start
        self.rim = rim
        self.made = made
        self.apexY = apexY
        self.metadata = metadata
    }
}
