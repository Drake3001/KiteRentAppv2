//
//  MockRentalManager.swift
//  KiteRentAppTests
//

import Foundation
@testable import KiteRentApp

final class MockRentalManager: RentalManagerProtocol {
    var activeRentals: [DBRental] = []
    var allRentals: [DBRental] = []
    var hasOverlappingRentalResult = false
    var lastCreatedRental: DBRental?
    var createNewRentalCallCount = 0

    func getActiveRentals() async throws -> [DBRental] { activeRentals }

    func getAllRentals() async throws -> [DBRental] { allRentals }

    func getRentalsForInstructor(instructorId: String) async throws -> [DBRental] {
        allRentals.filter { $0.instructorId == instructorId }
    }

    func createNewRental(rental: DBRental) async throws {
        createNewRentalCallCount += 1
        lastCreatedRental = rental
    }

    func updateRentalFields(rentalId: String, fields: [String: Any]) async throws {}

    func hasOverlappingRental(kiteId: String, start: Date, end: Date) async throws -> Bool {
        hasOverlappingRentalResult
    }
}
