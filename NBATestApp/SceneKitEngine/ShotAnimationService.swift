//
//  ShotAnimationService.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import SceneKit
import UIKit

final class ShotAnimationService {
    
    // MARK: - Public Methods
    
    func animateShot(_ shot: ShotSpec, in scene: SCNScene, completion: @escaping () -> Void) {
        let start = SCNVector3(shot.start.x, shot.start.y, shot.start.z)
        let end = SCNVector3(shot.rim.x, shot.rim.y, shot.rim.z)
        
        // Create and setup ball
        let ball = createBall(at: start)
        scene.rootNode.addChildNode(ball)
        
        // Create breadcrumbs
        let breadcrumbs = createBreadcrumbs(for: shot, start: start, end: end)
        breadcrumbs.forEach { scene.rootNode.addChildNode($0) }
        
        // Animate the shot
        animateBallFlight(ball: ball, 
                         breadcrumbs: breadcrumbs,
                         shot: shot,
                         start: start,
                         end: end,
                         scene: scene,
                         completion: completion)
    }
    
    // MARK: - Private Methods
    
    private func createBall(at position: SCNVector3) -> SCNNode {
        let ballGeometry = SCNSphere(radius: CGFloat(GameConstants.Ball.radius))
        ballGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        ballGeometry.firstMaterial?.roughness.contents = 0.3
        
        let ball = SCNNode(geometry: ballGeometry)
        ball.name = "ball"
        ball.position = position
        
        // Add spinning animation
        let spinAction = SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: CGFloat(GameConstants.Animation.ballSpinRotation), z: 0, 
                              duration: GameConstants.Animation.ballSpinDuration)
        )
        ball.runAction(spinAction, forKey: "spin")
        
        return ball
    }
    
    private func createBreadcrumbs(for shot: ShotSpec, start: SCNVector3, end: SCNVector3) -> [SCNNode] {
        var breadcrumbs: [SCNNode] = []
        
        for _ in 0..<GameConstants.Ball.breadcrumbCount {
            let crumbGeometry = SCNSphere(radius: CGFloat(GameConstants.Ball.breadcrumbRadius))
            crumbGeometry.firstMaterial?.diffuse.contents = shot.made ? UIColor.systemGreen : UIColor.systemRed
            crumbGeometry.firstMaterial?.emission.contents = crumbGeometry.firstMaterial?.diffuse.contents
            
            let breadcrumb = SCNNode(geometry: crumbGeometry)
            breadcrumb.name = "crumb"
            breadcrumb.isHidden = true
            
            breadcrumbs.append(breadcrumb)
        }
        
        return breadcrumbs
    }
    
    private func animateBallFlight(ball: SCNNode,
                                 breadcrumbs: [SCNNode],
                                 shot: ShotSpec,
                                 start: SCNVector3,
                                 end: SCNVector3,
                                 scene: SCNScene,
                                 completion: @escaping () -> Void) {
        
        let flightAction = SCNAction.customAction(duration: GameConstants.Animation.shotDuration) { node, elapsed in
            let t = Float(min(1.0, elapsed / CGFloat(GameConstants.Animation.shotDuration)))
            let position = MathUtils.bezierPoint(t: t, start: start, end: end, apexY: shot.apexY)
            node.position = position
            
            // Reveal breadcrumbs along the path
            self.updateBreadcrumbs(breadcrumbs: breadcrumbs, 
                                 t: t, 
                                 start: start, 
                                 end: end, 
                                 apexY: shot.apexY)
        }
        
        // Show made/miss effect
        let effectAction = SCNAction.run { _ in
            if shot.made {
                self.addMadeRing(at: end, in: scene)
            } else {
                self.addMissX(at: end, in: scene)
            }
        }
        
        // Cleanup
        let cleanupAction = SCNAction.run { _ in
            ball.removeFromParentNode()
            breadcrumbs.forEach { $0.removeFromParentNode() }
            completion()
        }
        
        let sequence = SCNAction.sequence([
            flightAction,
            effectAction,
            SCNAction.wait(duration: GameConstants.Animation.cleanupDelay),
            cleanupAction
        ])
        
        ball.runAction(sequence)
    }
    
    private func updateBreadcrumbs(breadcrumbs: [SCNNode],
                                 t: Float,
                                 start: SCNVector3,
                                 end: SCNVector3,
                                 apexY: Float) {
        for (index, breadcrumb) in breadcrumbs.enumerated() {
            let revealThreshold = Float(index + 1) / Float(breadcrumbs.count + 1)
            
            if t >= revealThreshold {
                let position = MathUtils.bezierPoint(t: revealThreshold, start: start, end: end, apexY: apexY)
                breadcrumb.position = SCNVector3(position.x, position.y + GameConstants.Ball.breadcrumbOffset, position.z)
                breadcrumb.isHidden = false
            }
        }
    }
    
    private func addMadeRing(at pos: SCNVector3, in scene: SCNScene) {
        let ringGeometry = SCNTorus(ringRadius: CGFloat(GameConstants.Effects.madeRingRadius), 
                                   pipeRadius: CGFloat(GameConstants.Effects.madeRingPipeRadius))
        ringGeometry.firstMaterial?.diffuse.contents = UIColor.systemGreen
        ringGeometry.firstMaterial?.emission.contents = UIColor.systemGreen
        
        let ringNode = SCNNode(geometry: ringGeometry)
        ringNode.name = "effect"
        ringNode.position = SCNVector3(pos.x, pos.y - 0.08, pos.z)
        
        scene.rootNode.addChildNode(ringNode)
        
        let scaleAction = SCNAction.scale(to: CGFloat(GameConstants.Effects.madeRingScale), 
                                        duration: GameConstants.Animation.effectScaleDuration)
        let fadeAction = SCNAction.fadeOut(duration: GameConstants.Animation.effectFadeDuration)
        let removeAction = SCNAction.removeFromParentNode()
        
        ringNode.runAction(SCNAction.sequence([
            SCNAction.group([scaleAction, fadeAction]),
            removeAction
        ]))
    }
    
    private func addMissX(at pos: SCNVector3, in scene: SCNScene) {
        let barGeometry = SCNBox(width: CGFloat(GameConstants.Effects.missBarWidth), 
                                height: CGFloat(GameConstants.Effects.missBarHeight), 
                                length: CGFloat(GameConstants.Effects.missBarDepth), 
                                chamferRadius: CGFloat(GameConstants.Effects.missBarChamferRadius))
        barGeometry.firstMaterial?.diffuse.contents = UIColor.systemRed
        barGeometry.firstMaterial?.emission.contents = UIColor.systemRed
        
        let barA = SCNNode(geometry: barGeometry)
        barA.eulerAngles.z = .pi/4
        
        let barB = SCNNode(geometry: barGeometry)
        barB.eulerAngles.z = -.pi/4
        
        let pivotNode = SCNNode()
        pivotNode.name = "effect"
        pivotNode.position = pos
        pivotNode.addChildNode(barA)
        pivotNode.addChildNode(barB)
        
        scene.rootNode.addChildNode(pivotNode)
        
        let scaleAction = SCNAction.scale(to: CGFloat(GameConstants.Effects.missBarScale), 
                                        duration: GameConstants.Animation.effectScaleDuration)
        let fadeAction = SCNAction.fadeOut(duration: GameConstants.Animation.effectFadeDuration)
        let removeAction = SCNAction.removeFromParentNode()
        
        pivotNode.runAction(SCNAction.sequence([
            SCNAction.group([scaleAction, fadeAction]),
            removeAction
        ]))
    }
}
