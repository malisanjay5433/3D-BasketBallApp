//
//  CameraController.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import SceneKit
import UIKit

// MARK: - Camera Modes
enum CameraMode {
    case fixed          // Fixed fan view
    case free           // Free rotation
    case follow         // Follow specific player
    case replay         // Replay mode with smooth transitions
}

// MARK: - Camera Presets
struct CameraPreset {
    let name: String
    let position: SCNVector3
    let lookAt: SCNVector3
    let fieldOfView: Float
    let description: String
    
    static let fanView = CameraPreset(
        name: "Fan View",
        position: SCNVector3(10, 8, 10),
        lookAt: SCNVector3(0, 1.5, -6),
        fieldOfView: 55.0,
        description: "Classic mid-row sideline view"
    )
    
    static let baseline = CameraPreset(
        name: "Baseline",
        position: SCNVector3(0, 6, -12),
        lookAt: SCNVector3(0, 1.5, 0),
        fieldOfView: 60.0,
        description: "Behind the basket view"
    )
    
    static let overhead = CameraPreset(
        name: "Overhead",
        position: SCNVector3(0, 15, 0),
        lookAt: SCNVector3(0, 0, 0),
        fieldOfView: 45.0,
        description: "Bird's eye view of the court"
    )
    
    static let corner = CameraPreset(
        name: "Corner",
        position: SCNVector3(8, 7, -8),
        lookAt: SCNVector3(0, 1.5, -6),
        fieldOfView: 50.0,
        description: "Corner three-point view"
    )
}

// MARK: - Main Controller
final class CameraController: NSObject {
    
    // MARK: - Properties
    private weak var cameraNode: SCNNode?
    private var currentMode: CameraMode = .fixed
    private var currentPreset: CameraPreset = .fanView
    
    // Free rotation properties
    private var isRotating = false
    private var lastPanLocation: CGPoint = .zero
    private var currentRotation: (horizontal: Float, vertical: Float) = (0, 0)
    private var targetRotation: (horizontal: Float, vertical: Float) = (0, 0)
    
    // Smoothing
    private var displayLink: CADisplayLink?
    private let rotationSmoothing: Float = 0.1
    private let positionSmoothing: Float = 0.05
    
    // Constraints
    private let minDistance: Float = 5.0
    private let maxDistance: Float = 25.0
    private let minVerticalAngle: Float = -Float.pi / 3  // -60 degrees
    private let maxVerticalAngle: Float = Float.pi / 2    // 90 degrees
    
    // MARK: - Initialization
    init(cameraNode: SCNNode) {
        self.cameraNode = cameraNode
        super.init()
        setupCamera()
    }
    
    // MARK: - Public Methods
    
    /// Sets the camera to a specific preset
    func setPreset(_ preset: CameraPreset, animated: Bool = true) {
        currentPreset = preset
        
        if animated {
            animateToPreset(preset)
        } else {
            applyPreset(preset)
        }
    }
    
    /// Switches to free rotation mode
    func enableFreeRotation() {
        currentMode = .free
        startSmoothUpdates()
        print("🎥 Camera: Free rotation enabled")
    }
    
    /// Switches to fixed mode
    func disableFreeRotation() {
        currentMode = .fixed
        stopSmoothUpdates()
        print("🎥 Camera: Fixed mode enabled")
    }
    
    /// Handles pan gesture for free rotation
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard currentMode == .free else { return }
        
        let location = gesture.location(in: gesture.view)
        
        switch gesture.state {
        case .began:
            isRotating = true
            lastPanLocation = location
            
        case .changed:
            let deltaX = Float(location.x - lastPanLocation.x)
            let deltaY = Float(location.y - lastPanLocation.y)
            
            // Convert to rotation angles
            let horizontalDelta = deltaX * 0.01
            let verticalDelta = deltaY * 0.01
            
            targetRotation.horizontal += horizontalDelta
            targetRotation.vertical += verticalDelta
            
            // Apply constraints
            targetRotation.vertical = max(minVerticalAngle, min(maxVerticalAngle, targetRotation.vertical))
            
            lastPanLocation = location
            
        case .ended, .cancelled:
            isRotating = false
            
        default:
            break
        }
    }
    
    /// Handles pinch gesture for zoom
    func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let cameraNode = cameraNode else { return }
        
        let scale = Float(gesture.scale)
        let currentDistance = distanceFromCenter(cameraNode.position)
        let newDistance = currentDistance * scale
        
        // Apply distance constraints
        let constrainedDistance = max(minDistance, min(maxDistance, newDistance))
        
        if gesture.state == .changed {
            let direction = normalize(cameraNode.position)
            let newPosition = SCNVector3(
                direction.x * constrainedDistance,
                direction.y * constrainedDistance,
                direction.z * constrainedDistance
            )
            cameraNode.position = newPosition
        }
    }
    
    /// Resets camera to default fan view
    func resetToDefault() {
        setPreset(.fanView, animated: true)
        currentMode = .fixed
        print("🎥 Camera: Reset to default view")
    }
    
    /// Gets current camera information
    func getCameraInfo() -> CameraInfo {
        guard let cameraNode = cameraNode else {
            return CameraInfo(position: SCNVector3(0, 0, 0), rotation: SCNVector3(0, 0, 0), mode: currentMode, preset: currentPreset)
        }
        
        return CameraInfo(
            position: cameraNode.position,
            rotation: cameraNode.eulerAngles,
            mode: currentMode,
            preset: currentPreset
        )
    }
    
    // MARK: - Private Methods
    private func setupCamera() {
        guard let cameraNode = cameraNode else { return }
        
        // Set initial position
        applyPreset(currentPreset)
        
        // Setup camera properties
        cameraNode.camera?.fieldOfView = CGFloat(currentPreset.fieldOfView)
        cameraNode.camera?.zFar = 300.0
        cameraNode.camera?.zNear = 0.1
    }
    
    private func applyPreset(_ preset: CameraPreset) {
        guard let cameraNode = cameraNode else { return }
        
        cameraNode.position = preset.position
        cameraNode.look(at: preset.lookAt)
        cameraNode.camera?.fieldOfView = CGFloat(preset.fieldOfView)
    }
    
    private func animateToPreset(_ preset: CameraPreset) {
        guard let cameraNode = cameraNode else { return }
        
        let positionAction = SCNAction.move(to: preset.position, duration: 1.0)
        positionAction.timingMode = .easeInEaseOut
        
        let lookAtAction = SCNAction.run { [weak self] _ in
            self?.cameraNode?.look(at: preset.lookAt)
        }
        
        let group = SCNAction.group([positionAction, lookAtAction])
        cameraNode.runAction(group)
    }
    
    private func startSmoothUpdates() {
        guard displayLink == nil else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateCamera))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopSmoothUpdates() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateCamera() {
        guard currentMode == .free else { return }
        
        // Smooth rotation updates
        currentRotation.horizontal += (targetRotation.horizontal - currentRotation.horizontal) * rotationSmoothing
        currentRotation.vertical += (targetRotation.vertical - currentRotation.vertical) * rotationSmoothing
        
        // Apply rotation to camera
        updateCameraPosition()
    }
    
    private func updateCameraPosition() {
        guard let cameraNode = cameraNode else { return }
        
        let distance = distanceFromCenter(cameraNode.position)
        
        // Calculate new position based on rotation
        let x = distance * sin(currentRotation.horizontal) * cos(currentRotation.vertical)
        let y = distance * sin(currentRotation.vertical)
        let z = distance * cos(currentRotation.horizontal) * cos(currentRotation.vertical)
        
        let newPosition = SCNVector3(x, y, z)
        
        // Smooth position update
        let smoothedPosition = lerp(
            from: cameraNode.position,
            to: newPosition,
            factor: positionSmoothing
        )
        
        cameraNode.position = smoothedPosition
        cameraNode.look(at: SCNVector3(0, 0, 0))
    }
    
    private func distanceFromCenter(_ position: SCNVector3) -> Float {
        return sqrt(position.x * position.x + position.y * position.y + position.z * position.z)
    }
    
    private func normalize(_ vector: SCNVector3) -> SCNVector3 {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        guard length > 0 else { return SCNVector3(0, 0, 0) }
        return SCNVector3(vector.x / length, vector.y / length, vector.z / length)
    }
    
    private func lerp(from: SCNVector3, to: SCNVector3, factor: Float) -> SCNVector3 {
        return SCNVector3(
            from.x + (to.x - from.x) * factor,
            from.y + (to.y - from.y) * factor,
            from.z + (to.z - from.z) * factor
        )
    }
}

// MARK: - Camera Info
struct CameraInfo {
    let position: SCNVector3
    let rotation: SCNVector3
    let mode: CameraMode
    let preset: CameraPreset
}

// MARK: - Extensions
extension CameraController {
    
    /// Creates a smooth transition between two camera positions
    func transitionToPosition(_ position: SCNVector3, lookAt: SCNVector3, duration: TimeInterval) {
        guard let cameraNode = cameraNode else { return }
        
        let moveAction = SCNAction.move(to: position, duration: duration)
        moveAction.timingMode = .easeInEaseOut
        
        let lookAtAction = SCNAction.run { [weak self] _ in
            self?.cameraNode?.look(at: lookAt)
        }
        
        let group = SCNAction.group([moveAction, lookAtAction])
        cameraNode.runAction(group)
    }
    
    /// Follows a specific node with smooth camera movement
    func followNode(_ node: SCNNode, offset: SCNVector3 = SCNVector3(0, 5, 8)) {
        guard let cameraNode = cameraNode else { return }
        
        let targetPosition = SCNVector3(
            node.position.x + offset.x,
            node.position.y + offset.y,
            node.position.z + offset.z
        )
        
        transitionToPosition(targetPosition, lookAt: node.position, duration: 0.5)
    }
}
