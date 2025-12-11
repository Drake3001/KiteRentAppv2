import XCTest
import Foundation
@testable import KiteRentApp

final class KitesurfingListViewModelRentalTests: XCTestCase {

    private final class MockKiteManager: KiteManagerProtocol {
        var syncCalls = 0
        func syncKiteStatesWithRentals() async throws {
            syncCalls += 1
        }

        func getAllKites() async throws -> [DBKite] {
            return []
        }
    }

    private final class MockRentalManager: RentalManagerProtocol {
        var rentalsToReturn: [DBRental] = []
        var calls = 0
        var delayNanoseconds: UInt64 = 0

        func getActiveRentals() async throws -> [DBRental] {
            calls += 1
            if delayNanoseconds > 0 {
                try await Task.sleep(nanoseconds: delayNanoseconds)
            }
            return rentalsToReturn
        }

        func getAllRentals() async throws -> [DBRental] {
            return []
        }
    }

    private final class MockInstructorManager: InstructorManagerProtocol {
        var instructorsToReturn: [DBInstructor] = []
        func getAllInstructors() async throws -> [DBInstructor] {
            return instructorsToReturn
        }
    }


    private func makeRental(kiteId: String, instructorId: String, startOffset: TimeInterval = -60, endOffset: TimeInterval = 60) -> DBRental {
        return DBRental(
            rentalId: UUID().uuidString,
            kiteId: kiteId,
            instructorId: instructorId,
            startTime: Date().addingTimeInterval(startOffset),
            endTime: Date().addingTimeInterval(endOffset)
        )
    }

    private func makeInstructor(id: String) -> DBInstructor {
        return DBInstructor(
            instructorId: id,
            name: "Name",
            surname: "Surname",
            phoneNumber: nil,
            dateCreated: nil,
            state: .active
        )
    }


    @MainActor
    func testActiveRentalsEmptyWhenNoInstructorsMatch() async {
        let kiteManager = MockKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.rentalsToReturn = [
            makeRental(kiteId: "k1", instructorId: "i1")
        ]
        let instructorManager = MockInstructorManager()
        instructorManager.instructorsToReturn = []

        let vm = KitesurfingListViewModel(
            kiteManager: kiteManager,
            rentalManager: rentalManager,
            instructorManager: instructorManager
        )

        await vm.loadKites()
        let activeRentals = await MainActor.run { vm.activeRentals }

        XCTAssertTrue(activeRentals.isEmpty, "activeRentals powinno być puste, gdy brak instruktorów pasujących do rentalu")
    }

    @MainActor
    func testActiveRentalsUpdatedOnLoad() async {
        let kiteManager = MockKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.rentalsToReturn = [
            makeRental(kiteId: "k1", instructorId: "i1")
        ]
        let instructorManager = MockInstructorManager()
        instructorManager.instructorsToReturn = [ makeInstructor(id: "i1") ]

        let vm = KitesurfingListViewModel(
            kiteManager: kiteManager,
            rentalManager: rentalManager,
            instructorManager: instructorManager
        )

        await vm.loadKites()
        let instructor = await MainActor.run { vm.activeRentals["k1"] }

        XCTAssertNotNil(instructor, "Instructor should be present for kite 'k1'")
        XCTAssertEqual(instructor?.instructorId, "i1")
    }

    @MainActor
    func testRefreshTaskStartsAndStops() async {
        let kiteManager = MockKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.delayNanoseconds = 1_000_000_000
        let instructorManager = MockInstructorManager()

        let vm = KitesurfingListViewModel(
            kiteManager: kiteManager,
            rentalManager: rentalManager,
            instructorManager: instructorManager
        )

        await vm.startRefreshOnRentalEnd()

        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertGreaterThanOrEqual(rentalManager.calls, 1, "Refresh should have invoked getActiveRentals at least once")

        await vm.stopRefreshOnRentalEnd()
        let callsAfterStop = rentalManager.calls
        try? await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertEqual(rentalManager.calls, callsAfterStop, "No additional rental calls should occur after stopping the refresh task")
    }

    @MainActor
    func testRentalRefreshReloadsKitesWhenExpired() async {
        let kiteManager = MockKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.rentalsToReturn = [
            makeRental(kiteId: "k1", instructorId: "i1", startOffset: -10, endOffset: 1)
        ]
        let instructorManager = MockInstructorManager()

        let vm = KitesurfingListViewModel(
            kiteManager: kiteManager,
            rentalManager: rentalManager,
            instructorManager: instructorManager
        )

        await vm.loadKites()
        XCTAssertGreaterThanOrEqual(kiteManager.syncCalls, 1, "KiteManager.syncKiteStatesWithRentals should be called when a rental ends")
    }
}
