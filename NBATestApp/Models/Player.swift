//
//  File.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import Foundation
// MARK: - Models (robust to null fields)
struct PlayerResponse: Codable { let data: PlayerData }
struct PlayerData: Codable { let players: [Player] }

struct Player: Codable, Identifiable {
	var id: String { uid }
	let uid: String
	let playerId: String?
	let teamName: String?
	let teamAbbreviation: String?
	let jerseyNumber: String?
	let personName: PersonName
	let images: PlayerImages?    // <- optional because JSON may contain null
}

struct PersonName: Codable {
	let name: String
	let firstName: String?
	let lastName: String?
}

struct PlayerImages: Codable {
	let headshot: String?
	let action: String?
}
