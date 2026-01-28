//
//  FavoritesManager.swift
//  hotelbooking
//
//  Created by GitHub Copilot on 1/28/26.
//

import Foundation
import Combine

@MainActor
final class FavoritesManager: ObservableObject {
    @Published private(set) var favoriteIds: Set<String> = []
    
    private let userDefaultsKey = "favoriteHotels"
    
    static let shared = FavoritesManager()
    
    init() {
        loadFavorites()
    }
    
    func isFavorite(_ hotelId: String) -> Bool {
        favoriteIds.contains(hotelId)
    }
    
    func toggleFavorite(_ hotelId: String) {
        if favoriteIds.contains(hotelId) {
            favoriteIds.remove(hotelId)
        } else {
            favoriteIds.insert(hotelId)
        }
        saveFavorites()
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteIds = decoded
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteIds) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}
