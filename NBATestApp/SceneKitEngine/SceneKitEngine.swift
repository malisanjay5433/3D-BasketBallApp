//
//  SceneKitEngine.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import SceneKit
import Foundation
import Combine

// MARK: - Engine Protocol
protocol SceneKitEngineProtocol: AnyObject {
    var scene: SCNScene { get }
    var cameraNode: SCNNode { get }
    var isRendering: Bool { get }
    
    func startRendering()
    func stopRendering()
    func updateCamera(position: SCNVector3, lookAt: SCNVector3)
    func addShot(_ shot: ShotSpec)
    func clearShots()
    func setPerformanceLevel(_ level: PerformanceLevel)
}

// MARK: - Performance Levels
enum PerformanceLevel: Int, CaseIterable {
    case low = 0      // 30fps, basic effects
    case medium = 1   // 45fps, standard effects
    case high = 2     // 60fps, full effects
    
    var targetFrameRate: Int {
        switch self {
        case .low: return 30
        case .medium: return 45
        case .high: return 60
        }
    }
    
    var shadowQuality: Bool {
        switch self {
        case .low: return false
        case .medium, .high: return true
        }
    }
    
    var particleCount: Int {
        switch self {
        case .low: return 50
        case .medium: return 100
        case .high: return 200
        }
    }
}

// MARK: - Main Engine Class
final class SceneKitEngine: NSObject, SceneKitEngineProtocol {
    
    // MARK: - Properties
    let scene: SCNScene
    let cameraNode: SCNNode
    private(set) var isRendering: Bool = false
    
    private var performanceLevel: PerformanceLevel = .high
    private var shotNodes: [SCNNode] = []
    private var animationQueue: [ShotAnimation] = []
    private var renderTimer: Timer?
    
    // MARK: - Initialization
    override init() {
        self.scene = SceneBuilder.buildCourtScene()
        self.cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true) ?? SCNNode()
        super.init()
        
        setupScene()
        setupPerformanceMonitoring()
    }
    
    // MARK: - Public Methods
    func startRendering() {
        guard !isRendering else { return }
        
        isRendering = true
        startRenderLoop()
        print("🎬 SceneKit Engine: Rendering started")
    }
    
    func stopRendering() {
        guard isRendering else { return }
        
        isRendering = false
        stopRenderLoop()
        print("⏹️ SceneKit Engine: Rendering stopped")
    }
    
    func updateCamera(position: SCNVector3, lookAt: SCNVector3) {
        cameraNode.position = position
        cameraNode.look(at: lookAt)
    }
    
    func addShot(_ shot: ShotSpec) {
        let shotNode = createShotNode(from: shot)
        scene.rootNode.addChildNode(shotNode)
        shotNodes.append(shotNode)
        
        // Queue animation
        let animation = ShotAnimation(shot: shot, node: shotNode)
        animationQueue.append(animation)
        
        print("🏀 Shot added: \(shot.playerName) from \(shot.distance)ft")
    }
    
    func clearShots() {
        shotNodes.forEach { $0.removeFromParentNode() }
        shotNodes.removeAll()
        animationQueue.removeAll()
        print("🧹 All shots cleared")
    }
    
    func setPerformanceLevel(_ level: PerformanceLevel) {
        performanceLevel = level
        applyPerformanceSettings()
        print("⚡ Performance level set to: \(level)")
    }
    
    // MARK: - Private Methods
    private func setupScene() {
        // Add camera reference
        if let camera = scene.rootNode.childNode(withName: "camera", recursively: true) {
            camera.name = "camera"
        }
        
        // Setup physics world
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        
        // Setup renderer delegate
        scene.isPaused = false
    }
    
    private func setupPerformanceMonitoring() {
        // Monitor frame rate and adjust quality if needed
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePerformanceWarning),
            name: .sceneKitDidDropFrame,
            object: nil
        )
    }
    
    private func startRenderLoop() {
        renderTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.processAnimationQueue()
        }
    }
    
    private func stopRenderLoop() {
        renderTimer?.invalidate()
        renderTimer = nil
    }
    
    private func processAnimationQueue() {
        guard !animationQueue.isEmpty else { return }
        
        let currentTime = Date().timeIntervalSince1970
        let readyAnimations = animationQueue.filter { $0.startTime <= currentTime }
        
        for animation in readyAnimations {
            startShotAnimation(animation)
            animationQueue.removeAll { $0.id == animation.id }
        }
    }
    
    private func startShotAnimation(_ animation: ShotAnimation) {
        // Delegate to animation service
        let animationService = ShotAnimationService()
        animationService.animateShot(animation.shot, in: scene) {
            // Animation completed
            print("🏀 Shot animation completed")
        }
    }
    
    private func createShotNode(from shot: ShotSpec) -> SCNNode {
        let ballNode = SCNNode(geometry: SCNSphere(radius: CGFloat(GameConstants.Ball.radius)))
        ballNode.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        ballNode.position = shot.startPosition
        ballNode.name = "shot_\(shot.id)"
        
        return ballNode
    }
    
    private func applyPerformanceSettings() {
        // Adjust shadow quality
        scene.rootNode.childNodes.forEach { node in
            node.castsShadow = performanceLevel.shadowQuality
        }
        
        // Adjust particle systems
        // This would be implemented based on your particle system setup
    }
    
    @objc private func handlePerformanceWarning() {
        // Auto-adjust performance if frames are dropping
        if performanceLevel != .low {
            let newLevel = PerformanceLevel(rawValue: performanceLevel.rawValue - 1) ?? .low
            setPerformanceLevel(newLevel)
        }
    }
}

// MARK: - Shot Animation Model
struct ShotAnimation {
    let id = UUID()
    let shot: ShotSpec
    let node: SCNNode
    let startTime: TimeInterval
    
    init(shot: ShotSpec, node: SCNNode) {
        self.shot = shot
        self.node = node
        self.startTime = Date().timeIntervalSince1970 + 0.1 // Small delay for smooth start
    }
}

// MARK: - Extensions
extension Notification.Name {
    static let sceneKitDidDropFrame = Notification.Name("sceneKitDidDropFrame")
}
