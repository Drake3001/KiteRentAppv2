//
//  ChangePasswordValidationTests.swift
//  KiteRentAppTests
//

import XCTest
@testable import KiteRentApp

@MainActor
final class ChangePasswordValidationTests: XCTestCase {

    private var mockAuth: MockAuthenticationManager!
    private var sut: ChangePasswordViewModel!

    override func setUp() {
        super.setUp()
        mockAuth = MockAuthenticationManager()
        sut = ChangePasswordViewModel(authManager: mockAuth)
    }

    func testIsPasswordStrong_validPassword_true() {
        sut.newPassword = "Test1234"
        XCTAssertTrue(sut.isPasswordStrong)
    }

    func testIsPasswordStrong_tooShort_false() {
        sut.newPassword = "Ab1"
        XCTAssertFalse(sut.isPasswordStrong)
    }

    func testIsPasswordStrong_missingUppercase_false() {
        sut.newPassword = "test1234"
        XCTAssertFalse(sut.isPasswordStrong)
    }

    func testPasswordsMatch_matching_true() {
        sut.newPassword = "Test1234"
        sut.verifyPassword = "Test1234"
        XCTAssertTrue(sut.passwordsMatch)
    }

    func testPasswordsMatch_mismatch_false() {
        sut.newPassword = "Test1234"
        sut.verifyPassword = "Test1235"
        XCTAssertFalse(sut.passwordsMatch)
    }

    func testCanSubmit_allFieldsFilled_true() {
        sut.currentPassword = "old"
        sut.newPassword = "Newpass1"
        sut.verifyPassword = "Newpass1"
        XCTAssertTrue(sut.canSubmit)
    }
}
