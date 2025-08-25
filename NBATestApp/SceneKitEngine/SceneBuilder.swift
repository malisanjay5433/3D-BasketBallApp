//
//  SceneBuilder.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import SceneKit
import UIKit

final class SceneBuilder {
    
    // MARK: - Scene Construction
    static func buildCourtScene() -> SCNScene {
        let scene = SCNScene()
        
        // Camera setup
        setupCamera(in: scene)
        
        // Lighting setup
        setupLighting(in: scene)
        
        // Court elements
        setupCourtFloor(in: scene)
        setupCourtLines(in: scene)
        setupBasket(in: scene)
        setupAudience(in: scene)
        
        return scene
    }
    
    // MARK: - Private Methods
    
    private static func setupCamera(in scene: SCNScene) {
        let camera = SCNCamera()
        camera.fieldOfView = CGFloat(GameConstants.Camera.fieldOfView)
		camera.zFar = Double(GameConstants.Camera.zFar)
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = GameConstants.Camera.position
        cameraNode.look(at: GameConstants.Camera.lookAt)
        
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private static func setupLighting(in scene: SCNScene) {
        // Key light
        let keyLight = SCNLight()
        keyLight.type = .omni
        keyLight.intensity = CGFloat(GameConstants.Lighting.KeyLight.intensity)
        
        let keyLightNode = SCNNode()
        keyLightNode.light = keyLight
        keyLightNode.position = GameConstants.Lighting.KeyLight.position
        scene.rootNode.addChildNode(keyLightNode)
        
        // Ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = CGFloat(GameConstants.Lighting.AmbientLight.intensity)
        
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        // Spot light for dramatic effect
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.intensity = CGFloat(GameConstants.Lighting.SpotLight.intensity)
        spotLight.castsShadow = true
        
        let spotNode = SCNNode()
        spotNode.light = spotLight
        spotNode.position = GameConstants.Lighting.SpotLight.position
        spotNode.look(at: GameConstants.Lighting.SpotLight.lookAt)
        scene.rootNode.addChildNode(spotNode)
    }
    
    private static func setupCourtFloor(in scene: SCNScene) {
        let floorPlane = SCNPlane(width: CGFloat(GameConstants.Court.width), 
                                 height: CGFloat(GameConstants.Court.length))
        
        // Create a proper basketball court material
        let floorMaterial = SCNMaterial()
        
        // Try to load a court texture, fallback to a realistic court color
        if let courtTexture = UIImage(named: "court_texture") {
            floorMaterial.diffuse.contents = courtTexture
            floorMaterial.diffuse.wrapS = .repeat
            floorMaterial.diffuse.wrapT = .repeat
        } else {
            // Create a realistic basketball court color (wooden court)
            floorMaterial.diffuse.contents = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        }
        
        // Add some roughness and specular for realism
        floorMaterial.roughness.contents = 0.8
        floorMaterial.metalness.contents = 0.1
        floorMaterial.lightingModel = .physicallyBased
        
        floorPlane.materials = [floorMaterial]
        floorPlane.firstMaterial?.isDoubleSided = true
        
        let floorNode = SCNNode(geometry: floorPlane)
        floorNode.eulerAngles.x = -.pi/2
        floorNode.position = SCNVector3(0, GameConstants.Court.floorY, GameConstants.Court.centerZ)
        floorNode.name = "courtFloor"
        
        scene.rootNode.addChildNode(floorNode)
        
        // Add court lines on top of the floor
        setupCourtLines(in: scene)
    }
    
    private static func setupCourtLines(in scene: SCNScene) {
        // Center line
        let centerLine = SCNPlane(width: CGFloat(GameConstants.Court.width), height: 0.08)
        let centerMaterial = SCNMaterial()
        centerMaterial.diffuse.contents = UIColor.white
        centerMaterial.emission.contents = UIColor.white
        centerMaterial.emission.intensity = 0.1
        centerLine.materials = [centerMaterial]
        
        let centerNode = SCNNode(geometry: centerLine)
        centerNode.eulerAngles.x = -.pi/2
        centerNode.position = SCNVector3(0, 0.02, GameConstants.Court.centerZ)
        centerNode.name = "centerLine"
        
        // Free throw lines
        let freeThrowDistance: Float = 4.57 // 15 feet from basket
        let freeThrowWidth: Float = 3.66   // 12 feet wide
        
        // Left free throw line
        let leftFreeThrow = SCNPlane(width: CGFloat(freeThrowWidth), height: 0.08)
        leftFreeThrow.materials = [centerMaterial]
        
        let leftFreeThrowNode = SCNNode(geometry: leftFreeThrow)
        leftFreeThrowNode.eulerAngles.x = -.pi/2
        leftFreeThrowNode.position = SCNVector3(-freeThrowWidth/2, 0.02, GameConstants.Basket.position.z + freeThrowDistance)
        leftFreeThrowNode.name = "leftFreeThrow"
        
        // Right free throw line
        let rightFreeThrow = SCNPlane(width: CGFloat(freeThrowWidth), height: 0.08)
        rightFreeThrow.materials = [centerMaterial]
        
        let rightFreeThrowNode = SCNNode(geometry: rightFreeThrow)
        rightFreeThrowNode.eulerAngles.x = -.pi/2
        rightFreeThrowNode.position = SCNVector3(freeThrowWidth/2, 0.02, GameConstants.Basket.position.z + freeThrowDistance)
        rightFreeThrowNode.name = "rightFreeThrow"
        
        // Three-point line (simplified arc)
        let threePointDistance: Float = 6.75 // 22.1 feet from basket
        let threePointArc = SCNPlane(width: CGFloat(threePointDistance * 2), height: 0.08)
        threePointArc.materials = [centerMaterial]
        
        let threePointNode = SCNNode(geometry: threePointArc)
        threePointNode.eulerAngles.x = -.pi/2
        threePointNode.position = SCNVector3(0, 0.02, GameConstants.Basket.position.z + threePointDistance)
        threePointNode.name = "threePointLine"
        
        scene.rootNode.addChildNode(centerNode)
        scene.rootNode.addChildNode(leftFreeThrowNode)
        scene.rootNode.addChildNode(rightFreeThrowNode)
        scene.rootNode.addChildNode(threePointNode)
    }
    
    private static func setupBasket(in scene: SCNScene) {
        // Rim
        let rimGeometry = SCNTorus(ringRadius: CGFloat(GameConstants.Basket.rimRadius), 
                                  pipeRadius: CGFloat(GameConstants.Basket.rimPipeRadius))
        let rimMaterial = SCNMaterial()
        rimMaterial.diffuse.contents = UIColor.black  // Changed to black as requested
        rimMaterial.emission.contents = UIColor.black
        rimMaterial.emission.intensity = 0.0  // No emission for black rim
        rimGeometry.materials = [rimMaterial]
        
        let rimNode = SCNNode(geometry: rimGeometry)
        rimNode.position = GameConstants.Basket.position
        rimNode.name = "rim"
        
        // Backboard
        let backboardGeometry = SCNBox(width: CGFloat(GameConstants.Basket.backboardWidth), 
                                     height: CGFloat(GameConstants.Basket.backboardHeight), 
                                     length: CGFloat(GameConstants.Basket.backboardDepth),
                                     chamferRadius: 0.0)
        let backboardMaterial = SCNMaterial()
        backboardMaterial.diffuse.contents = UIColor.white
        backboardMaterial.roughness.contents = 0.8
        backboardGeometry.materials = [backboardMaterial]
        
        let backboardNode = SCNNode(geometry: backboardGeometry)
        backboardNode.position = SCNVector3(GameConstants.Basket.position.x, 
                                          GameConstants.Basket.position.y + 0.5, 
                                          GameConstants.Basket.position.z + 0.1)
        backboardNode.name = "backboard"
        
        // Pole
        let poleGeometry = SCNCylinder(radius: CGFloat(GameConstants.Basket.poleRadius), 
                                     height: CGFloat(GameConstants.Basket.poleHeight))
        let poleMaterial = SCNMaterial()
        poleMaterial.diffuse.contents = UIColor.white  // Changed to white as requested
        poleMaterial.roughness.contents = 0.6
        poleGeometry.materials = [poleMaterial]
        
        let poleNode = SCNNode(geometry: poleGeometry)
        poleNode.position = SCNVector3(GameConstants.Basket.position.x, 
                                      GameConstants.Basket.position.y - 1.5, 
                                      GameConstants.Basket.position.z)
        poleNode.name = "pole"
        
        // Base
        let baseGeometry = SCNBox(width: CGFloat(GameConstants.Basket.basePaddingWidth), 
                                height: CGFloat(GameConstants.Basket.basePaddingHeight), 
                                length: CGFloat(GameConstants.Basket.basePaddingDepth),
                                chamferRadius: 0.0)
        let baseMaterial = SCNMaterial()
        baseMaterial.diffuse.contents = UIColor.white  // Changed to white to match pole
        baseMaterial.roughness.contents = 0.7
        baseGeometry.materials = [baseMaterial]
        
        let baseNode = SCNNode(geometry: baseGeometry)
        baseNode.position = SCNVector3(GameConstants.Basket.position.x, 
                                      GameConstants.Basket.position.y - 2.5, 
                                      GameConstants.Basket.position.z)
        baseNode.name = "base"
        
        scene.rootNode.addChildNode(rimNode)
        scene.rootNode.addChildNode(backboardNode)
        scene.rootNode.addChildNode(poleNode)
        scene.rootNode.addChildNode(baseNode)
    }
    
    private static func setupAudience(in scene: SCNScene) {
        let crowdPlane = SCNPlane(width: CGFloat(GameConstants.Audience.backdropWidth), 
                                 height: CGFloat(GameConstants.Audience.backdropHeight))
        
        let crowdMaterial = SCNMaterial()
        
        // Try to load the crowd image from the bundle
        if let crowdImage = UIImage(named: "crowd.jpg") {
            print("🎯 SceneBuilder: Successfully loaded crowd image")
            crowdMaterial.diffuse.contents = crowdImage
            crowdMaterial.diffuse.wrapS = .repeat
            crowdMaterial.diffuse.wrapT = .repeat
        } else {
            print("🎯 SceneBuilder: Crowd image not found, using fallback color")
            // Fallback to a realistic crowd color
            crowdMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.8)
        }
        
        // Add some emission for better visibility
        crowdMaterial.emission.contents = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.3)
        crowdMaterial.emission.intensity = 0.2
        
        crowdMaterial.isDoubleSided = true
        crowdPlane.materials = [crowdMaterial]
        
        let crowdNode = SCNNode(geometry: crowdPlane)
        crowdNode.position = GameConstants.Audience.backdropPosition
        crowdNode.name = "audience"
        
        scene.rootNode.addChildNode(crowdNode)
        print("🎯 SceneBuilder: Audience backdrop added at position: \(GameConstants.Audience.backdropPosition)")
    }
}
