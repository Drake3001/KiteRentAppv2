//
//  MediaPersistence.swift
//  KiteRentApp
//

import SwiftData

/// Single shared `ModelContainer` for media so the app and `MediaRepository` use the same store.
enum MediaPersistence {
    static let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: MediaAsset.self)
        } catch {
            fatalError("Failed to create ModelContainer for MediaAsset: \(error)")
        }
    }()
}
