//
//  GameConstants.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import Foundation
import SceneKit

enum GameConstants {
    
    // MARK: - Court Dimensions
    struct Court {
        static let width: Float = 15.0
        static let length: Float = 28.0
        static let floorY: Float = 0.0
        static let centerZ: Float = -6.0
    }
    
    // MARK: - Basket Dimensions
    struct Basket {
        static let rimHeight: Float = 3.05
        static let rimRadius: Float = 0.45
        static let rimPipeRadius: Float = 0.05
        static let backboardWidth: Float = 1.8
        static let backboardHeight: Float = 1.0
        static let backboardDepth: Float = 0.05
        static let poleRadius: Float = 0.1
        static let poleHeight: Float = 3.0
        static let basePaddingWidth: Float = 1.0
        static let basePaddingHeight: Float = 0.5
        static let basePaddingDepth: Float = 1.0
        static let position = SCNVector3(0, rimHeight, -8.0)
    }
    
    // MARK: - Camera Settings
    struct Camera {
        static let fieldOfView: Float = 55.0
        static let zFar: Float = 300.0
        static let position = SCNVector3(10, 8, 10)
        static let lookAt = SCNVector3(0, 1.5, -6)
    }
    
    // MARK: - Lighting
    struct Lighting {
        struct KeyLight {
            static let intensity: Float = 900.0
            static let position = SCNVector3(10, 12, 10)
        }
        
        struct AmbientLight {
            static let intensity: Float = 300.0
        }
        
        struct SpotLight {
            static let intensity: Float = 600.0
            static let position = SCNVector3(0, 10, 0)
            static let lookAt = SCNVector3(0, 3, -8)
        }
    }
    
    // MARK: - Animation
    struct Animation {
        static let shotDuration: TimeInterval = 1.8
        static let cleanupDelay: TimeInterval = 0.3
        static let replayDelay: TimeInterval = 0.5
        static let ballSpinDuration: TimeInterval = 0.7
        static let ballSpinRotation: Float = 2.6
        static let effectScaleDuration: TimeInterval = 0.45
        static let effectFadeDuration: TimeInterval = 0.4
    }
    
    // MARK: - Ball Properties
    struct Ball {
        static let radius: Float = 0.24
        static let breadcrumbRadius: Float = 0.03
        static let breadcrumbCount = 24
        static let breadcrumbOffset: Float = 0.02
    }
    
    // MARK: - Effects
    struct Effects {
        static let madeRingRadius: Float = 0.55
        static let madeRingPipeRadius: Float = 0.03
        static let madeRingScale: Float = 1.6
        static let missBarWidth: Float = 0.8
        static let missBarHeight: Float = 0.06
        static let missBarDepth: Float = 0.06
        static let missBarChamferRadius: Float = 0.02
        static let missBarScale: Float = 1.4
    }
    
    // MARK: - Audience
    struct Audience {
        static let backdropWidth: Float = 20.0
        static let backdropHeight: Float = 8.0
        static let backdropPosition = SCNVector3(0, 4, -15)
    }
    
    // MARK: - Team Data
    struct Teams {
        static let pacers = "Players_Pacers_1610612754"
        static let nets = "Players_Nets_1610612751"
        
        static let teamNames = ["Pacers", "Nets"]
        static let teamFileNames = ["Players_Pacers_1610612754", "Players_Nets_1610612751"]
        static let defaultTeamIndex = 0
    }
    
    // MARK: - UI
    struct UI {
        static let loadingDelay: TimeInterval = 0.8
        static let teamSelectionPadding: CGFloat = 32
        static let controlButtonSize: CGFloat = 56
        static let controlSpacing: CGFloat = 32
        static let playerOverlayBottomPadding: CGFloat = 40
        static let playerOverlayHorizontalPadding: CGFloat = 16
        static let playerOverlayCornerRadius: CGFloat = 16
        static let playerImageSize: CGFloat = 56
        static let playerImageBorderWidth: CGFloat = 2
    }
}
