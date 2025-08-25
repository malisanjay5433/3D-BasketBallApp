//
//  ArenaSegmentedControl.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import SwiftUI

// Custom segmented style with capsule look
struct ArenaSegmentedControl: View {
    @Binding var selection: Int
    let items: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { idx in
                Button(action: { selection = idx }) {
                    Text(items[idx])
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            ZStack {
                                if selection == idx {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.orange) // active color
                                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                                }
                            }
                        )
                        .foregroundColor(selection == idx ? .white : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.black.opacity(0.85))
        .clipShape(Capsule())
        .padding(.horizontal, GameConstants.UI.teamSelectionPadding)
    }
}
