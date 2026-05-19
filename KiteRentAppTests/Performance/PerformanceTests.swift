//
//  PerformanceTests.swift
//  KiteRentAppTests
//

import SwiftData
import UIKit
import XCTest
@testable import KiteRentApp

final class PerformanceTests: XCTestCase {

    private var measureOptions: XCTMeasureOptions {
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        return options
    }

    // MARK: - MediaProcessor

    func testMediaProcessor_resize4000x3000_performance() {
        let input = Self.largeJPEG4000x3000()
        measure(options: measureOptions) {
            let exp = expectation(description: "process")
            Task.detached(priority: .userInitiated) {
                _ = try? await MediaProcessor.process(input, maxLongEdge: 2048)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 30)
        }
    }

    // MARK: - MediaRepository

    func testMediaRepository_getImageData_inMemorySwiftData_performance() async throws {
        let container = try ModelContainer(
            for: MediaAsset.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let mediaRepo = MediaRepository(modelContainer: container)
        let ownerId = "perf-\(UUID().uuidString)"
        let imageData = Self.mediumJPEGData()
        try await mediaRepo.setImageData(
            ownerType: .kite,
            ownerId: ownerId,
            data: imageData,
            mimeType: "image/jpeg",
            thumbnailData: imageData,
            width: 100,
            height: 100
        )
        // Warm NSCache so measure iterations hit the in-memory fast path (no MainActor work).
        let warmed = try await mediaRepo.getImageData(ownerType: .kite, ownerId: ownerId)
        XCTAssertNotNil(warmed)

        measure(options: measureOptions) {
            let exp = expectation(description: "read")
            Task.detached {
                _ = try? await mediaRepo.getImageData(ownerType: .kite, ownerId: ownerId)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 10)
        }
    }

    // MARK: - KitesurfingListViewModel

    func testKitesurfingListViewModel_filteredAndOrderedKites_performance() {
        let kites = Self.makeManyKites(count: 120)
        let searchText = "north"

        measure(options: measureOptions) {
            _ = KitesurfingListViewModel.filteredAndOrdered(
                kites: kites,
                searchText: searchText,
                isSortAscending: false
            )
        }
    }

    // MARK: - Rental overlap (no Firestore — RentalOverlap, not RentalManager)

    func testRentalOverlap_hasOverlap_largeDataset_performance() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let rentals = Self.makeManyRentals(count: 200, kiteId: "kite-perf", dayStart: startOfDay)
        let proposedStart = calendar.date(byAdding: .hour, value: 10, to: startOfDay)!
        let proposedEnd = calendar.date(byAdding: .hour, value: 12, to: startOfDay)!

        measure(options: measureOptions) {
            _ = RentalOverlap.hasOverlap(in: rentals, start: proposedStart, end: proposedEnd)
        }
    }

    // MARK: - Helpers

    private static func largeJPEG4000x3000() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4000, height: 3000))
        let image = renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4000, height: 3000))
        }
        return image.jpegData(compressionQuality: 0.9)!
    }

    private static func mediumJPEGData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        }
        return image.jpegData(compressionQuality: 0.85)!
    }

    private static func makeManyKites(count: Int) -> [DBKite] {
        let states: [KiteState] = [.free, .used, .serviced]
        let brands = ["North", "Duotone", "Cabrinha", "F-One"]
        return (0..<count).map { i in
            TestFixtures.makeKite(
                name: "\(brands[i % brands.count]) \(i)",
                state: states[i % states.count],
                brand: brands[i % brands.count],
                size: String(7 + (i % 8))
            )
        }
    }

    private static func makeManyRentals(count: Int, kiteId: String, dayStart: Date) -> [DBRental] {
        (0..<count).map { i in
            let start = dayStart.addingTimeInterval(TimeInterval(i * 300))
            let end = start.addingTimeInterval(300)
            return TestFixtures.makeRental(
                rentalId: "rent-\(i)",
                kiteId: kiteId,
                instructorId: "inst-\(i % 10)",
                start: start,
                end: end
            )
        }
    }
}
