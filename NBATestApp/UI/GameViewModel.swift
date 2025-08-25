//
//  GameViewModel.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import Foundation
import SwiftUI
import Combine
import SceneKit

@MainActor
final class GameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var playersMap: [String: Player] = [:]
    @Published var shots: [ShotSpec] = []
    @Published var teamChoice = GameConstants.Teams.defaultTeamIndex
    @Published var isLoading = true
    
    // MARK: - Private Properties
    private let playerDataService = PlayerDataService()
    private let shotFactory = ShotFactory()
    private let sceneKitEngine = SceneKitEngine()
    private let sceneController = SceneController()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var availableTeams: [String] {
        return GameConstants.Teams.teamNames
    }
    
    var selectedTeam: String {
        return availableTeams[teamChoice]
    }
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Loads team data and prepares shots
    func loadTeamAndPrepareShots() async {
        isLoading = true
        
        let fileName = GameConstants.Teams.teamFileNames[teamChoice]
        let players = playerDataService.loadPlayers(from: fileName)
        
        await MainActor.run {
            self.playersMap = Dictionary(uniqueKeysWithValues: players.map { ($0.uid, $0) })
            
            // Generate demo shots for the loaded players
            let newShots = ShotFactory.makeDemoShots(for: players)
            print("🎯 Generated \(newShots.count) demo shots")
            self.shots = newShots
            
            self.isLoading = false
        }
    }
    
    /// Manually loads shots for the current team (called by play button)
    func loadShotsForPlayback() async {
        await loadTeamAndPrepareShots()
    }
    
    /// Gets the current scene for rendering
    func getScene() -> SCNScene {
        return sceneController.scene
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Monitor team changes
        $teamChoice
            .sink { [weak self] _ in
                Task {
                    await self?.loadTeamAndPrepareShots()
                }
            }
            .store(in: &cancellables)
    }
}
