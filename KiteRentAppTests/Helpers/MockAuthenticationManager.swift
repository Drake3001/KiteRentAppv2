//
//  MockAuthenticationManager.swift
//  KiteRentAppTests
//

import Foundation
@testable import KiteRentApp

final class MockAuthenticationManager: AuthenticationManagerProtocol {
    var signInResult: AuthDataResultModel?
    var signInError: Error?
    var createUserResult: AuthDataResultModel?
    var createUserError: Error?

    func getAuthenticatedUser() throws -> AuthDataResultModel {
        AuthDataResultModel(uid: "uid", email: "e@test.com")
    }

    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        if let createUserError { throw createUserError }
        guard let createUserResult else {
            return AuthDataResultModel(uid: "new-user", email: email)
        }
        return createUserResult
    }

    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        if let signInError { throw signInError }
        guard let signInResult else {
            return AuthDataResultModel(uid: "signed-in", email: email)
        }
        return signInResult
    }

    func signOut() throws {}

    func reauthenticateUser(email: String, password: String) async throws {}

    func updatePassword(to newPassword: String) async throws {}
}
