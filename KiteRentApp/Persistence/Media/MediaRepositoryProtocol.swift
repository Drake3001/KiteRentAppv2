//
//  MediaRepositoryProtocol.swift
//  KiteRentApp
//

import Foundation

protocol MediaRepositoryProtocol: AnyObject {
    func getImageData(ownerType: MediaOwnerType, ownerId: String) async throws -> Data?
    func setImageData(ownerType: MediaOwnerType, ownerId: String, data: Data) async throws
    func deleteImage(ownerType: MediaOwnerType, ownerId: String) async throws
}
