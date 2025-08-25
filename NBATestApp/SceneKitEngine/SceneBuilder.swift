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
        floorPlane.firstMaterial?.diffuse.contents = UIColor.systemGreen.withAlphaComponent(0.85)
        floorPlane.firstMaterial?.isDoubleSided = true
        
        let floorNode = SCNNode(geometry: floorPlane)
        floorNode.eulerAngles.x = -.pi/2
        floorNode.position = SCNVector3(0, GameConstants.Court.floorY, GameConstants.Court.centerZ)
        
        scene.rootNode.addChildNode(floorNode)
    }
    
    private static func setupCourtLines(in scene: SCNScene) {
        let centerLine = SCNPlane(width: CGFloat(GameConstants.Court.width), height: 0.06)
        centerLine.firstMaterial?.diffuse.contents = UIColor.white
        
        let centerNode = SCNNode(geometry: centerLine)
        centerNode.eulerAngles.x = -.pi/2
        centerNode.position = SCNVector3(0, 0.01, GameConstants.Court.centerZ)
        
        scene.rootNode.addChildNode(centerNode)
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
        crowdPlane.firstMaterial?.diffuse.contents = UIImage(named: "crowd.jpg")
        crowdPlane.firstMaterial?.diffuse.wrapS = .repeat
        crowdPlane.firstMaterial?.diffuse.wrapT = .repeat
        crowdPlane.firstMaterial?.isDoubleSided = true
        
        let crowdNode = SCNNode(geometry: crowdPlane)
        crowdNode.position = GameConstants.Audience.backdropPosition
        
        scene.rootNode.addChildNode(crowdNode)
    }
}
