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
    // Remove duplicate SceneController - will use the one from ContentView
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
        print("🎯 loadTeamAndPrepareShots started")
        isLoading = true
        
        let fileName = GameConstants.Teams.teamFileNames[teamChoice]
        print("🎯 Loading team from file: \(fileName)")
        
        let players = playerDataService.loadPlayers(from: fileName)
        print("🎯 Loaded \(players.count) players from \(fileName)")
        
        if players.isEmpty {
            print("❌ No players loaded! This is the problem.")
            return
        }
        
        await MainActor.run {
            self.playersMap = Dictionary(uniqueKeysWithValues: players.map { ($0.uid, $0) })
            print("🎯 Players map created with \(self.playersMap.count) players")
            
            // Generate demo shots for the loaded players
            let newShots = ShotFactory.makeDemoShots(for: players)
            print("🎯 Generated \(newShots.count) demo shots")
            
            // Clear existing shots first
            self.shots.removeAll()
            print("🎯 Cleared existing shots")
            
            // Set new shots (this will trigger the onChange in ContentView)
            self.shots = newShots
            print("🎯 Set new shots array with \(self.shots.count) shots")
            
            self.isLoading = false
            print("🎯 Shots loaded and ready for animation")
        }
    }
    
    /// Manually loads shots for the current team (called by play button)
    func loadShotsForPlayback() async {
        await loadTeamAndPrepareShots()
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
