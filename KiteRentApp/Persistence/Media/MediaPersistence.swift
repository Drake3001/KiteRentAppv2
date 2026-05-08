//
//  MediaPersistence.swift
//  KiteRentApp
//

import Foundation
import SwiftData

/// Single shared `ModelContainer` for media so the app and `MediaRepository` use the same store.
enum MediaPersistence {
    static let modelContainer: ModelContainer = {
        do {
            let schema = Schema([MediaAsset.self])

            // Ensure `Library/Application Support` exists before Core Data / SwiftData opens the store.
            // Default `ModelContainer(for:)` can hit errno 2 + sandbox denials if the directory is missing on first launch.
            let appSupport = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            try FileManager.default.createDirectory(
                at: appSupport,
                withIntermediateDirectories: true
            )

            let storeURL = appSupport.appendingPathComponent("Media.store", isDirectory: false)
            let configuration = ModelConfiguration(schema: schema, url: storeURL)
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer for MediaAsset: \(error)")
        }
    }()
}
