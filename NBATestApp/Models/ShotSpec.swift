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
    let start: SCNVector3   // [x,y,z]
    let rim: SCNVector3
    let made: Bool
    let apexY: Float
}
