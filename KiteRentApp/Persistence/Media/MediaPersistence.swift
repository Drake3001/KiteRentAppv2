//
//  MediaPersistence.swift
//  KiteRentApp
//

import Foundation
import SwiftData

enum MediaPersistence {
    static func imageStorageDirectory() throws -> URL {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = appSupport.appendingPathComponent("MediaImages", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func applicationSupportDirectory() throws -> URL {
        try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }

    private static func deleteMediaStoreFiles() {
        do {
            let appSupport = try applicationSupportDirectory()
            let names = ["Media.store", "Media.store-shm", "Media.store-wal"]
            for name in names {
                let url = appSupport.appendingPathComponent(name, isDirectory: false)
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            // Best-effort cleanup before retry.
        }
    }

    private static func createModelContainer() throws -> ModelContainer {
        let schema = Schema([MediaAsset.self])

        let appSupport = try applicationSupportDirectory()
        try FileManager.default.createDirectory(
            at: appSupport,
            withIntermediateDirectories: true
        )

        let storeURL = appSupport.appendingPathComponent("Media.store", isDirectory: false)
        let configuration = ModelConfiguration(schema: schema, url: storeURL)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static let modelContainer: ModelContainer = {
        do {
            return try createModelContainer()
        } catch {
            deleteMediaStoreFiles()
            do {
                return try createModelContainer()
            } catch {
                fatalError("Failed to create ModelContainer for MediaAsset: \(error)")
            }
        }
    }()
}
