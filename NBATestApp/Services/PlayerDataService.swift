//
//  PlayerDataService.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 25/08/25.
//

import Foundation

enum PlayerDataError: Error, LocalizedError {
    case missingFile(String)
    case decodingFailed(String, Error)
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .missingFile(let fileName):
            return "Missing data file: \(fileName).json"
        case .decodingFailed(let fileName, let error):
            return "Failed to decode \(fileName).json: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid data format"
        }
    }
}

final class PlayerDataService {
    
    // MARK: - Public Methods
    
    /// Loads players from a JSON file in the app bundle
    /// - Parameter fileName: The name of the JSON file (without extension)
    /// - Returns: Array of Player objects
    /// - Throws: PlayerDataError if loading or decoding fails
    func loadPlayers(from fileName: String) -> [Player] {
        print("🎯 PlayerDataService: Loading players from \(fileName)")
        do {
            let data = try loadDataFromBundle(fileName: fileName)
            print("🎯 PlayerDataService: Successfully loaded \(data.count) bytes from \(fileName)")
            
            let response = try decodePlayerResponse(from: data)
            print("🎯 PlayerDataService: Successfully decoded \(response.data.players.count) players")
            return response.data.players
        } catch {
            print("❌ PlayerDataService: Failed to load players from \(fileName): \(error)")
            return []
        }
    }
    
    /// Loads players asynchronously from a JSON file
    /// - Parameter fileName: The name of the JSON file (without extension)
    /// - Returns: Array of Player objects
    /// - Throws: PlayerDataError if loading or decoding fails
    func loadPlayersAsync(from fileName: String) async throws -> [Player] {
        let data = try await loadDataFromBundleAsync(fileName: fileName)
        let response = try decodePlayerResponse(from: data)
        return response.data.players
    }
    
    // MARK: - Private Methods
    
    private func loadDataFromBundle(fileName: String) throws -> Data {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw PlayerDataError.missingFile(fileName)
        }
        
        return try Data(contentsOf: url)
    }
    
    private func loadDataFromBundleAsync(fileName: String) async throws -> Data {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw PlayerDataError.missingFile(fileName)
        }
        
        return try Data(contentsOf: url)
    }
    
    private func decodePlayerResponse(from data: Data) throws -> PlayerResponse {
        do {
            return try JSONDecoder().decode(PlayerResponse.self, from: data)
        } catch {
            throw PlayerDataError.decodingFailed("unknown", error)
        }
    }
}
