//
//  PlayerOverlayView.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import SwiftUI

struct PlayerOverlayView: View {
    let player: Player
    
    var body: some View {
        HStack(spacing: 12) {
            if let urlStr = player.images?.headshot,
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { img in
                    img.resizable()
                       .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: GameConstants.UI.playerImageSize, height: GameConstants.UI.playerImageSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: GameConstants.UI.playerImageBorderWidth))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.personName.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("#\(player.jerseyNumber ?? "--") • \(player.teamAbbreviation ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: GameConstants.UI.playerOverlayCornerRadius))
        .padding(.horizontal, GameConstants.UI.playerOverlayHorizontalPadding)
        .padding(.bottom, GameConstants.UI.playerOverlayBottomPadding)
    }
}


