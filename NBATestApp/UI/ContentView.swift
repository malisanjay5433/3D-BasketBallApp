//
//  ContentView.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    
    // MARK: - State Objects
    @StateObject private var sceneController = SceneController()
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some View {
        ZStack {
            // 3D Scene
            SceneView(scene: sceneController.scene,
                     pointOfView: nil,
                     options: [.allowsCameraControl, .autoenablesDefaultLighting])
            .ignoresSafeArea()
            
            // Team Selection
            VStack {
                ArenaSegmentedControl(
                    selection: $gameViewModel.teamChoice,
                    items: gameViewModel.availableTeams
                )
                Spacer()
            }
            
            // Loading Indicator
            if gameViewModel.isLoading {
                LoadingView()
            }
            
            // Playback Controls
            VStack {
                Spacer()
                PlaybackControls(
                    controller: sceneController,
                    shots: gameViewModel.shots,
                    playersMap: gameViewModel.playersMap
                )
                .padding(.bottom, 10)
            }
            
            // Player Overlay
            .overlay(
                Group {
                    if let currentPlayer = sceneController.currentPlayer {
                        PlayerOverlayView(player: currentPlayer)
                            .padding(.bottom, 20)
                    }
                },
                alignment: .bottom
            )
        }
        .onAppear {
            Task {
                await gameViewModel.loadTeamAndPrepareShots()
            }
        }
        .onChange(of: gameViewModel.teamChoice) { _, _ in
            Task {
                await gameViewModel.loadTeamAndPrepareShots()
            }
        }
        .onChange(of: gameViewModel.shots) { _, newShots in
            sceneController.stopAll()
            sceneController.loadShots(newShots)
        }
    }
}

// MARK: - Loading View
private struct LoadingView: View {
    var body: some View {
        ProgressView("Loading…")
            .progressViewStyle(CircularProgressViewStyle(tint: .black))
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
