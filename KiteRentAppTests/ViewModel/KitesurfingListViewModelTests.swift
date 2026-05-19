//
//  KitesurfingListViewModelTests.swift
//  KiteRentAppTests
//

import XCTest
@testable import KiteRentApp

@MainActor
final class KitesurfingListViewModelTests: XCTestCase {

    func testFilteredAndOrderedKites_filtersBySearchText() async {
        let sut = KitesurfingListViewModel(
            kiteManager: MockKiteManager(),
            rentalManager: MockRentalManager(),
            instructorManager: MockInstructorManager()
        )
        sut.kites = [
            TestFixtures.makeKite(name: "North Reach"),
            TestFixtures.makeKite(name: "Duotone Evo")
        ]
        sut.searchText = "reach"
        let names = sut.filteredAndOrderedKites.map(\.name)
        XCTAssertEqual(names, ["North Reach"])
    }

    func testFilteredAndOrderedKites_sortsBySizeDescending() async {
        let sut = KitesurfingListViewModel(
            kiteManager: MockKiteManager(),
            rentalManager: MockRentalManager(),
            instructorManager: MockInstructorManager()
        )
        sut.kites = [
            TestFixtures.makeKite(name: "A", size: "12"),
            TestFixtures.makeKite(name: "B", size: "9")
        ]
        sut.isSortAscending = false
        let sizes = sut.filteredAndOrderedKites.map(\.size)
        XCTAssertEqual(sizes, ["12", "9"])
    }

    func testFilteredAndOrderedKites_groupsByState() async {
        let sut = KitesurfingListViewModel(
            kiteManager: MockKiteManager(),
            rentalManager: MockRentalManager(),
            instructorManager: MockInstructorManager()
        )
        sut.kites = [
            TestFixtures.makeKite(name: "Used", state: .used),
            TestFixtures.makeKite(name: "Free", state: .free)
        ]
        let states = sut.filteredAndOrderedKites.map(\.state)
        XCTAssertEqual(states, [.free, .used])
    }

    func testGetInstructorForKite_returnsMappedInstructor() async {
        let sut = KitesurfingListViewModel(
            kiteManager: MockKiteManager(),
            rentalManager: MockRentalManager(),
            instructorManager: MockInstructorManager()
        )
        let inst = TestFixtures.makeInstructor(id: "i1", name: "Ann", surname: "X")
        sut.activeRentals = ["k1": inst]
        XCTAssertEqual(sut.getInstructorForKite(kiteId: "k1")?.instructorId, "i1")
        XCTAssertNil(sut.getInstructorForKite(kiteId: "unknown"))
    }

    func testLoadKites_whenSyncThrows_setsErrorMessage() async {
        let kiteMock = MockKiteManager()
        kiteMock.shouldThrowOnSync = true
        let sut = KitesurfingListViewModel(
            kiteManager: kiteMock,
            rentalManager: MockRentalManager(),
            instructorManager: MockInstructorManager()
        )
        await sut.loadKites()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.kites.isEmpty)
    }

    func testLoadKites_success_populatesKites() async {
        let kiteMock = MockKiteManager()
        kiteMock.kitesToReturn = [
            TestFixtures.makeKite(name: "K1"),
            TestFixtures.makeKite(name: "K2")
        ]
        let sut = KitesurfingListViewModel(
            kiteManager: kiteMock,
            rentalManager: MockRentalManager(),
            instructorManager: MockInstructorManager()
        )
        await sut.loadKites()
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.kites.count, 2)
        XCTAssertEqual(kiteMock.syncCallCount, 1)
    }
}
