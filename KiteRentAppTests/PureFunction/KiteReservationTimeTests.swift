//
//  KiteReservationTimeTests.swift
//  KiteRentAppTests
//

import XCTest
@testable import KiteRentApp

final class KiteReservationTimeTests: XCTestCase {

    func testClampToWorkHours_beforeWorkStart_clampsToSix() {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 4
        comps.minute = 30
        let early = cal.date(from: comps)!
        let out = KiteReservationViewModel.clampToWorkHours(early, isStartDate: true)
        XCTAssertEqual(cal.component(.hour, from: out), AppConstants.defaultWorkStartHour)
        XCTAssertEqual(cal.component(.minute, from: out), 0)
    }

    func testClampToWorkHours_afterWorkEnd_clampsToEnd() {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = AppConstants.defaultWorkEndHour
        comps.minute = 45
        let late = cal.date(from: comps)!
        let out = KiteReservationViewModel.clampToWorkHours(late, isStartDate: false)
        XCTAssertEqual(cal.component(.hour, from: out), AppConstants.defaultWorkEndHour)
        XCTAssertEqual(cal.component(.minute, from: out), 0)
    }

    func testClampToWorkHours_withinRange_unchanged() {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 14
        comps.minute = 30
        let mid = cal.date(from: comps)!
        let out = KiteReservationViewModel.clampToWorkHours(mid, isStartDate: true)
        XCTAssertEqual(cal.component(.hour, from: out), 14)
        XCTAssertEqual(cal.component(.minute, from: out), 30)
    }

    func testValidMinutes_atMaxHour_respectsMaxMinute() {
        let minutes = KiteReservationViewModel.validMinutes(for: 10, maxHour: 10, maxMinute: 30)
        XCTAssertEqual(minutes, [0, 15, 30])
    }
}
