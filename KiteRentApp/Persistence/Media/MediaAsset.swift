//
//  MediaAsset.swift
//  KiteRentApp
//

import Foundation
import SwiftData

@Model
final class MediaAsset {
    @Attribute(.unique) var id: UUID
    var ownerType: String
    var ownerId: String
    var storageKey: String?
    /// Basename of the full-size image under `Application Support/MediaImages/`.
    var imageFilename: String?
    @Attribute(.externalStorage) var thumbnailData: Data?
    var createdAt: Date
    var updatedAt: Date
    var mimeType: String?
    var width: Int?
    var height: Int?

    init(
        id: UUID = UUID(),
        ownerType: MediaOwnerType,
        ownerId: String,
        imageFilename: String?,
        thumbnailData: Data?,
        mimeType: String,
        width: Int?,
        height: Int?,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.ownerType = ownerType.rawValue
        self.ownerId = ownerId
        self.storageKey = Self.makeStorageKey(ownerType: ownerType, ownerId: ownerId)
        self.imageFilename = imageFilename
        self.thumbnailData = thumbnailData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.mimeType = mimeType
        self.width = width
        self.height = height
    }

    static func makeStorageKey(ownerType: MediaOwnerType, ownerId: String) -> String {
        "\(ownerType.rawValue):\(ownerId)"
    }
}
