//
//  DirectAdminLoginViewModelTests.swift
//  KiteRentAppTests
//

import XCTest
@testable import KiteRentApp

@MainActor
final class DirectAdminLoginViewModelTests: XCTestCase {

    func testSignIn_emptyFields_setsErrorMessage() async {
        let sut = DirectAdminLoginViewModel(
            authManager: MockAuthenticationManager(),
            userManager: MockUserManager()
        )
        do {
            try await sut.signIn()
            XCTFail("Expected error")
        } catch ValidationError.emptyFields {
            XCTAssertEqual(sut.errorMessage, "Please enter both email and password.")
        } catch {
            XCTFail("Wrong error \(error)")
        }
    }

    func testSignIn_success_setsLoggedInRole_admin() async throws {
        let auth = MockAuthenticationManager()
        auth.signInResult = AuthDataResultModel(uid: "u-admin", email: "a@test.com")
        let users = MockUserManager()
        try await users.createNewUser(user: TestFixtures.makeUser(userId: "u-admin", role: .admin))
        let sut = DirectAdminLoginViewModel(authManager: auth, userManager: users)
        sut.email = "a@test.com"
        sut.password = "secret"
        try await sut.signIn()
        XCTAssertEqual(sut.loggedInRole, .admin)
    }

    func testSignIn_success_setsLoggedInRole_instructor() async throws {
        let auth = MockAuthenticationManager()
        auth.signInResult = AuthDataResultModel(uid: "u-inst", email: "i@test.com")
        let users = MockUserManager()
        try await users.createNewUser(user: TestFixtures.makeUser(userId: "u-inst", role: .instructor))
        let sut = DirectAdminLoginViewModel(authManager: auth, userManager: users)
        sut.email = "i@test.com"
        sut.password = "secret"
        try await sut.signIn()
        XCTAssertEqual(sut.loggedInRole, .instructor)
    }
}
