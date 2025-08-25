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
            SceneView(scene: gameViewModel.getScene(),
                     pointOfView: nil,
                     options: [.allowsCameraControl, .autoenablesDefaultLighting])
            .ignoresSafeArea()
            .transition(.opacity.combined(with: .scale))
            .animation(.easeInOut(duration: 1.0), value: true)
            
            // Top Controls - Only Team Selection
            VStack {
                HStack {
                    // Team Selection
                    ArenaSegmentedControl(
                        selection: $gameViewModel.teamChoice,
                        items: gameViewModel.availableTeams
                    )
                    
                    Spacer()
                    
                    // Simple Test Shot Button
                    Button(action: {
                        // Create a test shot
                        let testShot = ShotSpec(
                            playerUID: "test",
                            playerName: "Test Player",
                            start: SCNVector3(5, 1, -2),
                            rim: SCNVector3(0, 3.05, -8),
                            made: true,
                            apexY: 6.0
                        )
                        gameViewModel.shots.append(testShot)
                    }) {
                        Image(systemName: "basketball.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.orange.opacity(0.8), in: Circle())
                    }
                }
                .padding()
                
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
                    gameViewModel: gameViewModel,
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
                            .padding(.bottom, 75)
                    }
                },
                alignment: .bottom
            )
        }
        .onChange(of: gameViewModel.shots) { _, newShots in
            print("🎯 ContentView: Shots changed to \(newShots.count) shots")
            sceneController.stopAll()
            sceneController.loadShots(newShots)
            // Auto-play shots when they're loaded
            if !newShots.isEmpty {
                print("🎯 ContentView: Auto-playing \(newShots.count) shots")
                sceneController.play(shots: newShots, players: gameViewModel.playersMap)
            }
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
