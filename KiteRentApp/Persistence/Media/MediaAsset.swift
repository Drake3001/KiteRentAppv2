//
//  MediaAsset.swift
//  KiteRentApp
//

import Foundation
import SwiftData

@Model
final class MediaAsset {
    @Attribute(.unique) var id: UUID
    /// Backed by `MediaOwnerType.rawValue`
    var ownerType: String
    var ownerId: String
    @Attribute(.externalStorage) var data: Data
    var createdAt: Date
    var updatedAt: Date
    var mimeType: String?

    init(
        id: UUID = UUID(),
        ownerType: MediaOwnerType,
        ownerId: String,
        data: Data,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        mimeType: String? = "image/jpeg"
    ) {
        self.id = id
        self.ownerType = ownerType.rawValue
        self.ownerId = ownerId
        self.data = data
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.mimeType = mimeType
    }
}
