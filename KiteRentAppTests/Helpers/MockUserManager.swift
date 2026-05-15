//
//  MockUserManager.swift
//  KiteRentAppTests
//

import Foundation
@testable import KiteRentApp

final class MockUserManager: UserManagerProtocol {
    var users: [String: DBUser] = [:]
    var getUserError: Error?

    func createNewUser(user: DBUser) async throws {
        users[user.userId] = user
    }

    func getUser(userId: String) async throws -> DBUser {
        if let getUserError { throw getUserError }
        guard let u = users[userId] else {
            throw NSError(domain: "MockUserManager", code: 404)
        }
        return u
    }

    func deleteUser(userId: String) async throws {
        users[userId] = nil
    }
}
