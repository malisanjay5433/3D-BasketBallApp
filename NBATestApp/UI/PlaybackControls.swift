//
//  PlaybackControls.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//


import SwiftUI

struct PlaybackControls: View {
    @ObservedObject var controller: SceneController
    let shots: [ShotSpec]
    let playersMap: [String: Player]
    
    var body: some View {
        HStack(spacing: GameConstants.UI.controlSpacing) {
            Button(action: {
                controller.stopAll()
            }) {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: GameConstants.UI.controlButtonSize, height: GameConstants.UI.controlButtonSize)
                    .background(Circle().fill(Color.black.opacity(0.7)))
            }
            
            Button(action: {
                controller.play(shots: shots, players: playersMap)
            }) {
                Image(systemName: "play.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: GameConstants.UI.controlButtonSize, height: GameConstants.UI.controlButtonSize)
                    .background(Circle().fill(Color.green))
            }
            
            Button(action: {
                controller.replay(shots: shots, players: playersMap)
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: GameConstants.UI.controlButtonSize, height: GameConstants.UI.controlButtonSize)
                    .background(Circle().fill(Color.orange))
            }
        }
        .padding(.bottom, 30)
    }
}
