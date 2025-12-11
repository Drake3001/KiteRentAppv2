import XCTest
@testable import KiteRentApp

@MainActor
final class AdditionalRentalTests: XCTestCase {

    // MARK: - Mocks
    private final class ThrowingKiteManager: KiteManagerProtocol {
        func syncKiteStatesWithRentals() async throws { throw NSError(domain: "test", code: 1) }
        func getAllKites() async throws -> [DBKite] { return [] }
    }

    private final class SimpleKiteManager: KiteManagerProtocol {
        var syncCalls = 0
        func syncKiteStatesWithRentals() async throws { syncCalls += 1 }
        func getAllKites() async throws -> [DBKite] { return [] }
    }

    private final class ThrowingInstructorManager: InstructorManagerProtocol {
        func getAllInstructors() async throws -> [DBInstructor] { throw NSError(domain: "test", code: 2) }
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

        func getAllRentals() async throws -> [DBRental] { rentalsToReturn }
    }

    // MARK: - Helpers
    private func makeRental(kiteId: String, instructorId: String, startOffset: TimeInterval = -60, endOffset: TimeInterval = 60) -> DBRental {
        return DBRental(rentalId: UUID().uuidString, kiteId: kiteId, instructorId: instructorId, startTime: Date().addingTimeInterval(startOffset), endTime: Date().addingTimeInterval(endOffset))
    }

    private func makeInstructor(id: String, state: InstructorState = .active) -> DBInstructor {
        return DBInstructor(instructorId: id, name: "Name", surname: "Surname", phoneNumber: nil, dateCreated: nil, state: state)
    }

    // MARK: - Critical tests

    func testKiteManagerThrows_setsErrorMessage() async {
        let kiteManager = ThrowingKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.rentalsToReturn = []
        let instructorManager = ThrowingInstructorManager()

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.loadKites()

        XCTAssertNotNil(vm.errorMessage, "When KiteManager.sync throws, loadKites should set errorMessage")
    }

    func testInstructorManagerThrows_activeRentalsEmpty() async {
        let kiteManager = SimpleKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.rentalsToReturn = [ makeRental(kiteId: "k1", instructorId: "i1") ]
        let instructorManager = ThrowingInstructorManager()

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.loadKites()

        XCTAssertTrue(vm.activeRentals.isEmpty, "When InstructorManager throws, activeRentals should be empty (fallback)")
        XCTAssertNil(vm.errorMessage, "loadKites should not set errorMessage for instructor manager errors (they are handled internally)")
    }

    func testInactiveInstructorIncluded_currentBehavior() async {
        let kiteManager = SimpleKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.rentalsToReturn = [ makeRental(kiteId: "k1", instructorId: "i1") ]
        let instructorManager = MockInstructorManager(instructors: [ makeInstructor(id: "i1", state: .inactive) ])

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.loadKites()

        // Current implementation maps instructors by id without checking state, so inactive instructors are included.
        XCTAssertNotNil(vm.activeRentals["k1"], "Current behavior includes inactive instructors in activeRentals; adjust implementation if you want to ignore them")
    }

    func testOverlappingRentals_lastOneWins() async {
        let kiteManager = SimpleKiteManager()
        let rentalManager = MockRentalManager()
        // same kite, two rentals — the last rental in the returned array should be used by current implementation
        let r1 = makeRental(kiteId: "k1", instructorId: "i1")
        let r2 = makeRental(kiteId: "k1", instructorId: "i2")
        rentalManager.rentalsToReturn = [r1, r2]
        let instructorManager = MockInstructorManager(instructors: [ makeInstructor(id: "i1"), makeInstructor(id: "i2") ])

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.loadKites()

        XCTAssertEqual(vm.activeRentals["k1"]?.instructorId, "i2", "When multiple rentals for the same kite exist, the last one in the list wins in current implementation")
    }

    // MARK: - Medium priority

    func testRefreshLoopCancelsAndDoesNotDuplicate() async {
        let kiteManager = SimpleKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.delayNanoseconds = 2_000_000_000 // block calls a bit
        let instructorManager = MockInstructorManager(instructors: [])

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.startRefreshOnRentalEnd()
        // start again quickly — implementation stops previous before starting
        await vm.startRefreshOnRentalEnd()

        // allow the task to call getActiveRentals at least once
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertGreaterThanOrEqual(rentalManager.calls, 1)

        await vm.stopRefreshOnRentalEnd()
        let callsAfterStop = rentalManager.calls
        try? await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertEqual(rentalManager.calls, callsAfterStop, "After stopping the refresh loop we should not see additional getActiveRentals calls")
    }

    func testRentalEndingNow_triggersImmediateReload() async {
        let kiteManager = SimpleKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.rentalsToReturn = [ makeRental(kiteId: "k1", instructorId: "i1", startOffset: -10, endOffset: 0) ]
        let instructorManager = MockInstructorManager(instructors: [ makeInstructor(id: "i1") ])

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.startRefreshOnRentalEnd()

        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertGreaterThanOrEqual(kiteManager.syncCalls, 1, "A rental ending now should cause an immediate reload (syncKiteStatesWithRentals)")

        await vm.stopRefreshOnRentalEnd()
    }

    func testMappingMultipleRentals_mapsAllUniqueKites() async {
        let kiteManager = SimpleKiteManager()
        let rentalManager = MockRentalManager()
        rentalManager.rentalsToReturn = [
            makeRental(kiteId: "k1", instructorId: "i1"),
            makeRental(kiteId: "k2", instructorId: "i2"),
            makeRental(kiteId: "k3", instructorId: "i3")
        ]
        let instructorManager = MockInstructorManager(instructors: [ makeInstructor(id: "i1"), makeInstructor(id: "i2"), makeInstructor(id: "i3") ])

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.loadKites()

        XCTAssertEqual(vm.activeRentals.count, 3, "Should map each unique kite to its instructor when instructors exist")
    }
}
