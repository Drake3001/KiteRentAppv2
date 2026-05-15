//
//  MediaRepositoryIntegrationTests.swift
//  KiteRentAppTests
//

import SwiftData
import UIKit
import XCTest
@testable import KiteRentApp

@MainActor
final class MediaRepositoryIntegrationTests: XCTestCase {

    private var container: ModelContainer!
    private var repo: MediaRepository!

    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainer(
            for: MediaAsset.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        repo = MediaRepository(modelContainer: container)
        try await Task.sleep(nanoseconds: 50_000_000)
    }

    private func tinyJpegData() -> Data {
        let img = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in
            UIColor.red.setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return img.jpegData(compressionQuality: 0.9)!
    }

    private func assetCount() throws -> Int {
        let ctx = ModelContext(container)
        return try ctx.fetch(FetchDescriptor<MediaAsset>()).count
    }

    func testSetImageData_getImageData_roundTrip() async throws {
        let ownerId = "round-trip-\(UUID().uuidString)"
        let data = tinyJpegData()
        let thumb = tinyJpegData()
        try await repo.setImageData(
            ownerType: .kite,
            ownerId: ownerId,
            data: data,
            mimeType: "image/jpeg",
            thumbnailData: thumb,
            width: 1,
            height: 1
        )
        let loaded = try await repo.getImageData(ownerType: .kite, ownerId: ownerId)
        XCTAssertEqual(loaded, data)
    }

    func testSetImageData_twiceSameOwner_updatesNotDuplicates() async throws {
        let ownerId = "dup-\(UUID().uuidString)"
        let first = tinyJpegData()
        let second = tinyJpegData()
        try await repo.setImageData(
            ownerType: .kite,
            ownerId: ownerId,
            data: first,
            mimeType: "image/jpeg",
            thumbnailData: nil,
            width: 1,
            height: 1
        )
        try await repo.setImageData(
            ownerType: .kite,
            ownerId: ownerId,
            data: second,
            mimeType: "image/jpeg",
            thumbnailData: nil,
            width: 1,
            height: 1
        )
        XCTAssertEqual(try assetCount(), 1)
        let loaded = try await repo.getImageData(ownerType: .kite, ownerId: ownerId)
        XCTAssertEqual(loaded, second)
    }

    func testGetThumbnailData_returnsThumbnailWhenPresent() async throws {
        let ownerId = "thumb-\(UUID().uuidString)"
        let full = tinyJpegData()
        let thumb = tinyJpegData()
        try await repo.setImageData(
            ownerType: .kite,
            ownerId: ownerId,
            data: full,
            mimeType: "image/jpeg",
            thumbnailData: thumb,
            width: 1,
            height: 1
        )
        let loadedThumb = try await repo.getThumbnailData(ownerType: .kite, ownerId: ownerId)
        XCTAssertEqual(loadedThumb, thumb)
    }

    func testDeleteImage_removesData() async throws {
        let ownerId = "del-\(UUID().uuidString)"
        try await repo.setImageData(
            ownerType: .kite,
            ownerId: ownerId,
            data: tinyJpegData(),
            mimeType: "image/jpeg",
            thumbnailData: nil,
            width: 1,
            height: 1
        )
        try await repo.deleteImage(ownerType: .kite, ownerId: ownerId)
        let loaded = try await repo.getImageData(ownerType: .kite, ownerId: ownerId)
        XCTAssertNil(loaded)
        XCTAssertEqual(try assetCount(), 0)
    }
}
