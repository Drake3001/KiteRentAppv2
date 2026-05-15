//
//  MockKiteManager.swift
//  KiteRentAppTests
//

import Foundation
@testable import KiteRentApp

final class MockKiteManager: KiteManagerProtocol {
    var shouldThrowOnSync = false
    var shouldThrowOnGetAll = false
    var kitesToReturn: [DBKite] = []
    var syncCallCount = 0
    var lastUpdatedKiteId: String?
    var lastUpdatedState: KiteState?

    func syncKiteStatesWithRentals() async throws {
        syncCallCount += 1
        if shouldThrowOnSync {
            throw NSError(domain: "MockKiteManager", code: 1)
        }
    }

    func getAllKites() async throws -> [DBKite] {
        if shouldThrowOnGetAll {
            throw NSError(domain: "MockKiteManager", code: 2)
        }
        return kitesToReturn
    }

    func createNewKite(kite: DBKite) async throws {}

    func updateKiteState(kiteId: String, state: KiteState) async throws {
        lastUpdatedKiteId = kiteId
        lastUpdatedState = state
    }

    func updateKiteFields(kiteId: String, fields: [String: Any]) async throws {}

    func deleteKite(kiteId: String) async throws {}
}
