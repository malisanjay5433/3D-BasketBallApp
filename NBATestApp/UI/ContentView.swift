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
                    
                    // Debug Test Button
                    Button(action: {
                        print("🎯 Debug test button pressed")
                        // Create a simple test shot
                        let testShot = ShotSpec(
                            playerUID: "debug",
                            playerName: "Debug Player",
                            start: SCNVector3(2, 1, -3),
                            rim: SCNVector3(0, 3.05, -8),
                            made: true,
                            apexY: 5.0
                        )
                        
                        // Immediately animate this test shot
                        sceneController.stopAll()
                        sceneController.play(shots: [testShot], players: ["debug": Player(
                            uid: "debug",
                            playerId: nil,
                            teamName: nil,
                            teamAbbreviation: nil,
                            jerseyNumber: nil,
                            personName: PersonName(name: "Debug", firstName: nil, lastName: nil),
                            images: nil
                        )])
                        print("🎯 Debug test shot started")
                    }) {
                        Text("Test Ball")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
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
        .onAppear {
            print("🎯 ContentView appeared, automatically loading shots")
            // Automatically load shots when view appears
            Task {
                print("🎯 Starting automatic shot loading...")
                await gameViewModel.loadTeamAndPrepareShots()
                print("🎯 Automatic shot loading completed")
            }
        }
        .onChange(of: gameViewModel.shots) { _, newShots in
            print("🎯 ContentView: Shots changed to \(newShots.count) shots")
            print("🎯 Shot details: \(newShots.map { "\($0.playerName) at \($0.start)" })")
            
            // Stop any existing animations
            sceneController.stopAll()
            
            // Load shots into the scene controller
            sceneController.loadShots(newShots)
            
            // Auto-play shots when they're loaded (with a small delay to ensure loading is complete)
            if !newShots.isEmpty {
                print("🎯 ContentView: Auto-playing \(newShots.count) shots")
                // Start animation immediately after shots are loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    print("🎯 Starting automatic animation sequence")
                    sceneController.play(shots: newShots, players: gameViewModel.playersMap)
                }
            } else {
                print("🎯 ContentView: No shots to animate")
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
