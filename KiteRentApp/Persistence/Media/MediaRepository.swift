//
//  MediaRepository.swift
//  KiteRentApp
//

import Foundation
import SwiftData

@MainActor
final class MediaRepository: MediaRepositoryProtocol, @unchecked Sendable {
    static let shared = MediaRepository(modelContainer: MediaPersistence.modelContainer)

    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func getImageData(ownerType: MediaOwnerType, ownerId: String) async throws -> Data? {
        let typeStr = ownerType.rawValue
        let context = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<MediaAsset>(
            predicate: #Predicate<MediaAsset> { asset in
                asset.ownerType == typeStr && asset.ownerId == ownerId
            }
        )
        descriptor.fetchLimit = 1
        let results = try context.fetch(descriptor)
        return results.first?.data
    }

    func setImageData(ownerType: MediaOwnerType, ownerId: String, data: Data) async throws {
        let typeStr = ownerType.rawValue
        let context = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<MediaAsset>(
            predicate: #Predicate<MediaAsset> { asset in
                asset.ownerType == typeStr && asset.ownerId == ownerId
            }
        )
        descriptor.fetchLimit = 1
        let existing = try context.fetch(descriptor).first
        let now = Date()
        if let row = existing {
            row.data = data
            row.updatedAt = now
        } else {
            let insert = MediaAsset(
                ownerType: ownerType,
                ownerId: ownerId,
                data: data,
                createdAt: now,
                updatedAt: now
            )
            context.insert(insert)
        }
        try context.save()
    }

    func deleteImage(ownerType: MediaOwnerType, ownerId: String) async throws {
        let typeStr = ownerType.rawValue
        let context = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<MediaAsset>(
            predicate: #Predicate<MediaAsset> { asset in
                asset.ownerType == typeStr && asset.ownerId == ownerId
            }
        )
        let rows = try context.fetch(descriptor)
        for row in rows {
            context.delete(row)
        }
        if !rows.isEmpty {
            try context.save()
        }
    }
}
