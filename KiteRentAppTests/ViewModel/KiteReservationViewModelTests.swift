//
//  KiteReservationViewModelTests.swift
//  KiteRentAppTests
//

import XCTest
@testable import KiteRentApp

@MainActor
final class KiteReservationViewModelTests: XCTestCase {

    func testFilteredInstructors_excludesInactive() {
        let sut = KiteReservationViewModel(
            kiteManager: MockKiteManager(),
            rentalManager: MockRentalManager(),
            instructorManager: MockInstructorManager(),
            instructorMode: .selectable
        )
        sut.instructors = [
            TestFixtures.makeInstructor(id: "1", state: .active),
            TestFixtures.makeInstructor(id: "2", state: .inactive)
        ]
        XCTAssertEqual(sut.filteredInstructors.count, 1)
        XCTAssertEqual(sut.filteredInstructors.first?.instructorId, "1")
    }

    func testConfirmReservation_noInstructor_setsError() async {
        let sut = KiteReservationViewModel(
            kiteManager: MockKiteManager(),
            rentalManager: MockRentalManager(),
            instructorManager: MockInstructorManager(),
            instructorMode: .selectable
        )
        sut.startHour = 10
        sut.startMinute = 0
        sut.endHour = 12
        sut.endMinute = 0
        await sut.confirmReservation(kiteId: "k1")
        XCTAssertEqual(sut.errorMessage, "Wybierz instruktora.")
        XCTAssertFalse(sut.didCreateReservation)
    }

    func testConfirmReservation_overlap_setsError() async {
        let rentalMock = MockRentalManager()
        rentalMock.hasOverlappingRentalResult = true
        let sut = KiteReservationViewModel(
            kiteManager: MockKiteManager(),
            rentalManager: rentalMock,
            instructorManager: MockInstructorManager(),
            instructorMode: .selectable
        )
        sut.selectedInstructor = TestFixtures.makeInstructor(id: "ins")
        sut.startHour = 10
        sut.startMinute = 0
        sut.endHour = 12
        sut.endMinute = 0
        await sut.confirmReservation(kiteId: "k1")
        XCTAssertEqual(sut.errorMessage, "Ten kite jest już zarezerwowany w wybranym przedziale czasowym.")
        XCTAssertFalse(sut.didCreateReservation)
        XCTAssertEqual(rentalMock.createNewRentalCallCount, 0)
    }

    func testConfirmReservation_success_createsRentalAndUpdatesKite() async {
        let kiteMock = MockKiteManager()
        let rentalMock = MockRentalManager()
        let sut = KiteReservationViewModel(
            kiteManager: kiteMock,
            rentalManager: rentalMock,
            instructorManager: MockInstructorManager(),
            instructorMode: .selectable
        )
        sut.selectedInstructor = TestFixtures.makeInstructor(id: "ins")
        sut.startHour = 10
        sut.startMinute = 0
        sut.endHour = 12
        sut.endMinute = 0
        await sut.confirmReservation(kiteId: "kite-x")
        XCTAssertTrue(sut.didCreateReservation)
        XCTAssertNotNil(sut.createdRentalId)
        XCTAssertEqual(rentalMock.createNewRentalCallCount, 1)
        XCTAssertEqual(rentalMock.lastCreatedRental?.kiteId, "kite-x")
        XCTAssertEqual(kiteMock.lastUpdatedKiteId, "kite-x")
        XCTAssertEqual(kiteMock.lastUpdatedState, .used)
    }
}
