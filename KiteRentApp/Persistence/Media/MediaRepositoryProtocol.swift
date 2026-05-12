//
//  MediaRepositoryProtocol.swift
//  KiteRentApp
//

import Foundation

protocol MediaRepositoryProtocol: AnyObject {
    func getImageData(ownerType: MediaOwnerType, ownerId: String) async throws -> Data?
    func getThumbnailData(ownerType: MediaOwnerType, ownerId: String) async throws -> Data?
    func setImageData(
        ownerType: MediaOwnerType,
        ownerId: String,
        data: Data,
        mimeType: String,
        thumbnailData: Data?,
        width: Int?,
        height: Int?
    ) async throws
    func deleteImage(ownerType: MediaOwnerType, ownerId: String) async throws
}
