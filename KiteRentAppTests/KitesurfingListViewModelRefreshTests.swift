import XCTest
@testable import KiteRentApp

@MainActor
final class KitesurfingListViewModelRefreshTests: XCTestCase {

    private final class MockKiteManager: KiteManagerProtocol {
        var syncCalls = 0
        func syncKiteStatesWithRentals() async throws { syncCalls += 1 }
        func getAllKites() async throws -> [DBKite] { return [] }
    }

    private final class MockRentalManager: RentalManagerProtocol {
        var rentalsToReturn: [DBRental] = []
        var calls = 0
        var delayNanoseconds: UInt64 = 0

        func getActiveRentals() async throws -> [DBRental] {
            calls += 1
            if delayNanoseconds > 0 { try await Task.sleep(nanoseconds: delayNanoseconds) }
            return rentalsToReturn
        }

        func getAllRentals() async throws -> [DBRental] { return rentalsToReturn }
    }

    private final class MockInstructorManager: InstructorManagerProtocol {
        var instructorsToReturn: [DBInstructor] = []
        func getAllInstructors() async throws -> [DBInstructor] { return instructorsToReturn }
    }

    private func makeRental(kiteId: String, instructorId: String, startOffset: TimeInterval = -60, endOffset: TimeInterval = 60) -> DBRental {
        DBRental(rentalId: UUID().uuidString, kiteId: kiteId, instructorId: instructorId, startTime: Date().addingTimeInterval(startOffset), endTime: Date().addingTimeInterval(endOffset))
    }

    func testRefreshLoopCancelsAndDoesNotDuplicate() async {
        let kiteManager = MockKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.delayNanoseconds = 2_000_000_000
        let instructorManager = MockInstructorManager()

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.startRefreshOnRentalEnd()
        await vm.startRefreshOnRentalEnd() 

        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertGreaterThanOrEqual(rentalManager.calls, 1)

        await vm.stopRefreshOnRentalEnd()
        let callsAfterStop = rentalManager.calls
        try? await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertEqual(rentalManager.calls, callsAfterStop, "After stopping the refresh loop we should not see additional getActiveRentals calls")
    }

    func testRentalEndingNow_triggersImmediateReload() async {
        let kiteManager = MockKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.rentalsToReturn = [ makeRental(kiteId: "k1", instructorId: "i1", startOffset: -10, endOffset: 0) ]
        let instructorManager = MockInstructorManager()

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.startRefreshOnRentalEnd()

        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertGreaterThanOrEqual(kiteManager.syncCalls, 1, "A rental ending now should cause an immediate reload (syncKiteStatesWithRentals)")

        await vm.stopRefreshOnRentalEnd()
    }

    func testRentalRefreshReloadsKitesWhenExpired() async {
        let kiteManager = MockKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.rentalsToReturn = [ makeRental(kiteId: "k1", instructorId: "i1", startOffset: -10, endOffset: 1) ]
        let instructorManager = MockInstructorManager()

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.loadKites()
        XCTAssertGreaterThanOrEqual(kiteManager.syncCalls, 1, "KiteManager.syncKiteStatesWithRentals should be called when a rental ends")
    }
}
