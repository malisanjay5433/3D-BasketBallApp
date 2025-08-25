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
        print("🎯 ShotAnimationService.animateShot called for \(shot.playerName)")
        let start = SCNVector3(shot.start.x, shot.start.y, shot.start.z)
        let end = SCNVector3(shot.rim.x, shot.rim.y, shot.rim.z)
        print("🎯 Start position: \(start), End position: \(end)")
        print("🎯 Apex Y: \(shot.apexY)")
        
        // Create and setup ball
        let ball = createBall(at: start)
        
        scene.rootNode.addChildNode(ball)
        print("🎯 Ball created at position: \(ball.position)")
        print("🎯 Ball added to scene. Scene has \(scene.rootNode.childNodes.count) root nodes")
        print("🎯 Ball node name: \(ball.name ?? "unnamed")")
        
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
        
        // Create a proper basketball material with realistic orange color
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)  // Basketball orange
        material.emission.contents = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.3)  // Subtle glow
        material.emission.intensity = 0.4  // Moderate emission
        material.roughness.contents = 0.2  // Slightly rough surface
        material.metalness.contents = 0.1  // Low metalness for realistic look
        material.lightingModel = .physicallyBased  // Use PBR for better rendering
        
        ballGeometry.materials = [material]
        
        let ball = SCNNode(geometry: ballGeometry)
        ball.name = "ball"
        ball.position = position
        
        // Add a point light to the ball to make it glow
        let ballLight = SCNLight()
        ballLight.type = .omni
        ballLight.intensity = 50.0  // Reduced intensity
        ballLight.color = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)  // Orange light
        ballLight.attenuationStartDistance = 0.3
        ballLight.attenuationEndDistance = 2.0
        
        let lightNode = SCNNode()
        lightNode.light = ballLight
        lightNode.position = SCNVector3(0, 0, 0)
        ball.addChildNode(lightNode)
        
        // Add spinning animation
        let spinAction = SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: CGFloat(GameConstants.Animation.ballSpinRotation), z: 0, 
                              duration: GameConstants.Animation.ballSpinDuration)
        )
        ball.runAction(spinAction, forKey: "spin")
        
        print("🎯 Ball created with radius: \(GameConstants.Ball.radius)")
        print("🎯 Ball has light: \(ball.childNodes.contains(where: { $0.light != nil }))")
        return ball
    }
    
    /// Creates breadcrumb trail nodes for the shot
    private func createBreadcrumbs(for shot: ShotSpec, start: SCNVector3, end: SCNVector3) -> [SCNNode] {
        let breadcrumbCount = GameConstants.Ball.breadcrumbCount
        var breadcrumbs: [SCNNode] = []
        
        // Use actuallyMade for more accurate color coding
        let actuallyMade = shot.actuallyMade
        let breadcrumbColor: UIColor = actuallyMade ? .systemGreen : .systemRed
        
        for i in 0..<breadcrumbCount {
            let breadcrumb = SCNNode(geometry: SCNSphere(radius: CGFloat(GameConstants.Ball.breadcrumbRadius)))
            breadcrumb.position = start
            
            // Create material with appropriate color and emission
            let material = SCNMaterial()
            material.diffuse.contents = breadcrumbColor
            material.emission.contents = breadcrumbColor
            material.emission.intensity = 0.6  // Increased emission for better visibility
            material.lightingModel = .physicallyBased
            
            breadcrumb.geometry?.materials = [material]
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
        
        print("🎯 Starting ball flight animation")
        print("🎯 Ball initial position: \(ball.position)")
        
        // Create a custom action that follows the Bézier curve trajectory
        let flightAction = SCNAction.customAction(duration: GameConstants.Animation.shotDuration) { node, elapsed in
            let t = Float(min(1.0, elapsed / CGFloat(GameConstants.Animation.shotDuration)))
            
            // Calculate position along the Bézier curve
            let position = MathUtils.bezierPoint(t: t, start: start, end: end, apexY: shot.apexY)
            node.position = position
            
            // Update breadcrumbs along the path
            self.updateBreadcrumbs(breadcrumbs: breadcrumbs, 
                                 t: t, 
                                 start: start, 
                                 end: end, 
                                 apexY: shot.apexY)
            
            // Debug: Print position every few frames
            if Int(elapsed * 10) % 10 == 0 {
                print("🎯 Ball at t=\(t): \(node.position)")
            }
        }
        
        // Add rotation for realism
        let spinAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: GameConstants.Animation.shotDuration)
        
        // Group the actions
        let groupAction = SCNAction.group([flightAction, spinAction])
        
        // Show made/miss effect
        let effectAction = SCNAction.run { _ in
            print("🎯 Shot completed, showing effect")
            // Use actuallyMade for more accurate detection
            let actuallyMade = shot.actuallyMade
            print("🎯 Shot marked as made: \(shot.made), but actually made: \(actuallyMade)")
            
            if actuallyMade {
                self.addMadeRing(at: end, in: scene)
            } else {
                self.addMissX(at: end, in: scene)
            }
        }
        
        // Cleanup
        let cleanupAction = SCNAction.run { _ in
            print("🎯 Cleaning up animation nodes")
            ball.removeFromParentNode()
            breadcrumbs.forEach { $0.removeFromParentNode() }
            completion()
        }
        
        // Sequence: flight + effect + cleanup
        let sequence = SCNAction.sequence([
            groupAction,
            effectAction,
            SCNAction.wait(duration: GameConstants.Animation.cleanupDelay),
            cleanupAction
        ])
        
        print("🎯 Running ball animation sequence")
        ball.runAction(sequence)
    }
    
    // Easing function for more realistic movement
    private func easeInOutQuad(t: Float) -> Float {
        if t < 0.5 {
            return 2 * t * t
        } else {
            return 1 - 2 * (1 - t) * (1 - t)
        }
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
                
                // Ensure breadcrumbs are above the court surface (y > 0.1) and add extra offset
                let yPosition = max(position.y + GameConstants.Ball.breadcrumbOffset, 0.15)
                breadcrumb.position = SCNVector3(position.x, yPosition, position.z)
                breadcrumb.isHidden = false
                
                // Add fade-in effect for breadcrumbs
                let fadeInAction = SCNAction.fadeIn(duration: 0.1)
                breadcrumb.runAction(fadeInAction)
                
                // Make breadcrumbs pulse for better visibility
                let pulseAction = SCNAction.sequence([
                    SCNAction.scale(to: 1.2, duration: 0.3),
                    SCNAction.scale(to: 1.0, duration: 0.3)
                ])
                breadcrumb.runAction(SCNAction.repeatForever(pulseAction), forKey: "pulse")
            }
        }
    }
    
    private func addMadeRing(at pos: SCNVector3, in scene: SCNScene) {
        let ringGeometry = SCNTorus(ringRadius: CGFloat(GameConstants.Effects.madeRingRadius), 
                                   pipeRadius: CGFloat(GameConstants.Effects.madeRingPipeRadius))
        let ringMaterial = SCNMaterial()
        ringMaterial.diffuse.contents = UIColor.systemGreen
        ringMaterial.emission.contents = UIColor.systemGreen
        ringMaterial.emission.intensity = 1.0  // Bright emission
        ringGeometry.materials = [ringMaterial]
        
        let ringNode = SCNNode(geometry: ringGeometry)
        ringNode.name = "effect"
        ringNode.position = SCNVector3(pos.x, pos.y - 0.08, pos.z)
        
        scene.rootNode.addChildNode(ringNode)
        
        // More dramatic animation
        let scaleAction = SCNAction.scale(to: CGFloat(GameConstants.Effects.madeRingScale), 
                                        duration: GameConstants.Animation.effectScaleDuration)
        let fadeAction = SCNAction.fadeOut(duration: GameConstants.Animation.effectFadeDuration)
        let removeAction = SCNAction.removeFromParentNode()
        
        // Add rotation for more visual impact
        let rotateAction = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: GameConstants.Animation.effectScaleDuration)
        
        ringNode.runAction(SCNAction.sequence([
            SCNAction.group([scaleAction, fadeAction, rotateAction]),
            removeAction
        ]))
        
        print("🎯 Made shot effect added at position: \(pos)")
    }
    
    private func addMissX(at pos: SCNVector3, in scene: SCNScene) {
        let barGeometry = SCNBox(width: CGFloat(GameConstants.Effects.missBarWidth), 
                                height: CGFloat(GameConstants.Effects.missBarHeight), 
                                length: CGFloat(GameConstants.Effects.missBarDepth), 
                                chamferRadius: CGFloat(GameConstants.Effects.missBarChamferRadius))
        let barMaterial = SCNMaterial()
        barMaterial.diffuse.contents = UIColor.systemRed
        barMaterial.emission.contents = UIColor.systemRed
        barMaterial.emission.intensity = 1.0  // Bright emission
        barGeometry.materials = [barMaterial]
        
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
        
        // More dramatic animation
        let scaleAction = SCNAction.scale(to: CGFloat(GameConstants.Effects.missBarScale), 
                                        duration: GameConstants.Animation.effectScaleDuration)
        let fadeAction = SCNAction.fadeOut(duration: GameConstants.Animation.effectFadeDuration)
        let removeAction = SCNAction.removeFromParentNode()
        
        // Add bounce effect
        let bounceAction = SCNAction.sequence([
            SCNAction.moveBy(x: 0, y: 0.5, z: 0, duration: GameConstants.Animation.effectScaleDuration * 0.3),
            SCNAction.moveBy(x: 0, y: -0.5, z: 0, duration: GameConstants.Animation.effectScaleDuration * 0.7)
        ])
        
        pivotNode.runAction(SCNAction.sequence([
            SCNAction.group([scaleAction, fadeAction, bounceAction]),
            removeAction
        ]))
        
        print("🎯 Miss shot effect added at position: \(pos)")
    }
}
