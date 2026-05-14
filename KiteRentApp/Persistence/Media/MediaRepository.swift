//
//  MediaRepository.swift
//  KiteRentApp
//

import Foundation
import SwiftData

/// SwiftData `ModelContext` must be used on the main actor; image decode stays off-main in callers.
final class MediaRepository: MediaRepositoryProtocol, @unchecked Sendable {
    static let shared = MediaRepository(modelContainer: MediaPersistence.modelContainer)

    private let modelContainer: ModelContainer

    private let dataCache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>()
        cache.countLimit = 30
        return cache
    }()

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        Task { @MainActor in
            Self.backfillLegacyStorageKeysIfNeeded(modelContainer: modelContainer)
        }
    }

    @MainActor
    private static func backfillLegacyStorageKeysIfNeeded(modelContainer: ModelContainer) {
        let context = ModelContext(modelContainer)
        do {
            let all = try context.fetch(FetchDescriptor<MediaAsset>())
            var changed = false
            for row in all {
                guard let owner = MediaOwnerType(rawValue: row.ownerType) else { continue }
                let expected = MediaAsset.makeStorageKey(ownerType: owner, ownerId: row.ownerId)
                if row.storageKey != expected {
                    row.storageKey = expected
                    changed = true
                }
            }
            if changed {
                try context.save()
            }
        } catch {
            // Non-fatal; per-read backfill in `fetchAsset` still applies.
        }
    }

    @MainActor
    private func fetchAsset(
        context: ModelContext,
        ownerType: MediaOwnerType,
        ownerId: String
    ) throws -> MediaAsset? {
        let typeStr = ownerType.rawValue
        var descriptor = FetchDescriptor<MediaAsset>(
            predicate: #Predicate<MediaAsset> { asset in
                asset.ownerType == typeStr && asset.ownerId == ownerId
            }
        )
        descriptor.fetchLimit = 1
        guard let row = try context.fetch(descriptor).first else { return nil }

        let expectedKey = MediaAsset.makeStorageKey(ownerType: ownerType, ownerId: ownerId)
        if row.storageKey != expectedKey {
            row.storageKey = expectedKey
            try context.save()
        }
        return row
    }

    private func cacheKey(ownerType: MediaOwnerType, ownerId: String, thumbnail: Bool) -> NSString {
        "\(ownerType.rawValue):\(ownerId):\(thumbnail ? "thumb" : "full")" as NSString
    }

    private func removeCachedData(for ownerType: MediaOwnerType, ownerId: String) {
        dataCache.removeObject(forKey: cacheKey(ownerType: ownerType, ownerId: ownerId, thumbnail: false))
        dataCache.removeObject(forKey: cacheKey(ownerType: ownerType, ownerId: ownerId, thumbnail: true))
    }

    func getImageData(ownerType: MediaOwnerType, ownerId: String) async throws -> Data? {
        let key = cacheKey(ownerType: ownerType, ownerId: ownerId, thumbnail: false)
        if let cached = dataCache.object(forKey: key) {
            return cached as Data
        }
        let data = try await MainActor.run {
            let context = ModelContext(modelContainer)
            let row = try fetchAsset(context: context, ownerType: ownerType, ownerId: ownerId)
            return row?.data
        }
        if let data {
            dataCache.setObject(data as NSData, forKey: key)
        }
        return data
    }

    func getThumbnailData(ownerType: MediaOwnerType, ownerId: String) async throws -> Data? {
        let key = cacheKey(ownerType: ownerType, ownerId: ownerId, thumbnail: true)
        if let cached = dataCache.object(forKey: key) {
            return cached as Data
        }
        let data = try await MainActor.run { () throws -> Data? in
            let context = ModelContext(modelContainer)
            let row = try fetchAsset(context: context, ownerType: ownerType, ownerId: ownerId)
            if let thumb = row?.thumbnailData, !thumb.isEmpty {
                return thumb
            }
            return row?.data
        }
        if let data {
            dataCache.setObject(data as NSData, forKey: key)
        }
        return data
    }

    func setImageData(
        ownerType: MediaOwnerType,
        ownerId: String,
        data: Data,
        mimeType: String,
        thumbnailData: Data?,
        width: Int?,
        height: Int?
    ) async throws {
        try await MainActor.run {
            let context = ModelContext(modelContainer)
            let existing = try fetchAsset(context: context, ownerType: ownerType, ownerId: ownerId)
            let now = Date()
            if let row = existing {
                row.data = data
                row.thumbnailData = thumbnailData
                row.mimeType = mimeType
                row.width = width
                row.height = height
                row.updatedAt = now
                row.storageKey = MediaAsset.makeStorageKey(ownerType: ownerType, ownerId: ownerId)
            } else {
                let insert = MediaAsset(
                    ownerType: ownerType,
                    ownerId: ownerId,
                    data: data,
                    thumbnailData: thumbnailData,
                    mimeType: mimeType,
                    width: width,
                    height: height,
                    createdAt: now,
                    updatedAt: now
                )
                context.insert(insert)
            }
            try context.save()
            removeCachedData(for: ownerType, ownerId: ownerId)
        }
    }

    func deleteImage(ownerType: MediaOwnerType, ownerId: String) async throws {
        try await MainActor.run {
            let typeStr = ownerType.rawValue
            let context = ModelContext(modelContainer)
            let descriptor = FetchDescriptor<MediaAsset>(
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
            removeCachedData(for: ownerType, ownerId: ownerId)
        }
    }
}
