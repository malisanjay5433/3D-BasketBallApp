//
//  GameViewModel.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import Foundation
import SwiftUI

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
    
    // MARK: - Computed Properties
    var availableTeams: [String] {
        GameConstants.Teams.teamNames
    }
    
    var selectedTeam: String {
        availableTeams[teamChoice]
    }
    
    // MARK: - Public Methods
    
    /// Loads team data and prepares shots for the selected team
    func loadTeamAndPrepareShots() async {
        isLoading = true
        
        do {
            let players = await loadPlayersForSelectedTeam()
			let newShots = ShotFactory.makeDemoShots(for: players)
            
            // Small delay for smooth transition
            try await Task.sleep(nanoseconds: UInt64(GameConstants.UI.loadingDelay * 1_000_000_000))
            
            await MainActor.run {
                self.playersMap = Dictionary(uniqueKeysWithValues: players.map { ($0.uid, $0) })
                self.shots = newShots
                self.isLoading = false
            }
        } catch {
            print("❌ Error loading team data: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    /// Changes the selected team and reloads data
    func changeTeam(to newTeamIndex: Int) {
        teamChoice = newTeamIndex
        Task {
            await loadTeamAndPrepareShots()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadPlayersForSelectedTeam() async -> [Player] {
        let fileName = teamChoice == 0 ? GameConstants.Teams.pacers : GameConstants.Teams.nets
        return playerDataService.loadPlayers(from: fileName)
    }
}
