//
//  SceneController.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import SceneKit
import SwiftUI

final class SceneController: ObservableObject {
    
    // MARK: - Published Properties
    @Published var scene: SCNScene
    @Published var currentPlayer: Player?
    @Published var isPlaying: Bool = false
    
    // MARK: - Private Properties
    private var shotsQueue: [ShotSpec] = []
    private var isAnimating = false
    private let animationService = ShotAnimationService()
    
    // MARK: - Initialization
    init() {
        self.scene = SceneBuilder.buildCourtScene()
    }
    
    // MARK: - Public Methods
    
    /// Loads shots into the queue for playback
    func loadShots(_ shots: [ShotSpec]) {
        shotsQueue = shots
    }
    
    /// Plays the next shot in the queue
    func playNext(from playersMap: [String: Player]) {
        guard !isAnimating, !shotsQueue.isEmpty else { return }
        
        isAnimating = true
        isPlaying = true
        
        let shot = shotsQueue.removeFirst()
        currentPlayer = playersMap[shot.playerUID]
        
        animationService.animateShot(shot, in: scene) { [weak self] in
            guard let self = self else { return }
            
            self.isAnimating = false
            
            DispatchQueue.main.async {
                self.isPlaying = !self.shotsQueue.isEmpty
            }
            
            // Small delay before playing next shot
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.Animation.replayDelay) {
                self.playNext(from: playersMap)
            }
        }
    }
    
    /// Stops all current animations and resets the scene
    func stopAll() {
        cleanupAnimationNodes()
        isPlaying = false
        isAnimating = false
    }
    
    /// Plays all shots in sequence
    func play(shots: [ShotSpec], players: [String: Player]) {
        loadShots(shots)
        playNext(from: players)
    }
    
    /// Replays all shots from the beginning
    func replay(shots: [ShotSpec], players: [String: Player]) {
        stopAll()
        loadShots(shots)
        playNext(from: players)
    }
    
    // MARK: - Private Methods
    
    private func cleanupAnimationNodes() {
        scene.rootNode.childNodes
            .filter { ["ball", "crumb", "effect"].contains($0.name) }
            .forEach { $0.removeFromParentNode() }
    }
}
