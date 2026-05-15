//
//  ModelLogicTests.swift
//  KiteRentAppTests
//

import XCTest
@testable import KiteRentApp

final class ModelLogicTests: XCTestCase {

    func testKiteState_ordering() {
        XCTAssertTrue(KiteState.free < KiteState.used)
        XCTAssertTrue(KiteState.used < KiteState.serviced)
    }

    func testMediaAsset_storageKey_format() {
        let key = MediaAsset.makeStorageKey(ownerType: .kite, ownerId: "abc")
        XCTAssertEqual(key, "kite:abc")
        let keyProfile = MediaAsset.makeStorageKey(ownerType: .userProfile, ownerId: "u1")
        XCTAssertEqual(keyProfile, "userProfile:u1")
    }

    func testDBUser_encodesSnakeCaseKeys() throws {
        let user = DBUser(userId: "id1", email: "x@y.z", dateCreated: nil, role: .admin)
        let data = try JSONEncoder().encode(user)
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(obj?["user_id"] as? String)
        XCTAssertNotNil(obj?["email"] as? String)
        XCTAssertEqual(obj?["role"] as? String, "admin")
    }
}
