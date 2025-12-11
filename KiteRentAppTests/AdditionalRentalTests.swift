import XCTest
@testable import KiteRentApp

@MainActor
final class AdditionalRentalTests: XCTestCase {

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

    private func makeRental(kiteId: String, instructorId: String, startOffset: TimeInterval = -60, endOffset: TimeInterval = 60) -> DBRental {
        return DBRental(rentalId: UUID().uuidString, kiteId: kiteId, instructorId: instructorId, startTime: Date().addingTimeInterval(startOffset), endTime: Date().addingTimeInterval(endOffset))
    }

    private func makeInstructor(id: String, state: InstructorState = .active) -> DBInstructor {
        return DBInstructor(instructorId: id, name: "Name", surname: "Surname", phoneNumber: nil, dateCreated: nil, state: state)
    }


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

        XCTAssertNotNil(vm.activeRentals["k1"], "Current behavior includes inactive instructors in activeRentals; adjust implementation if you want to ignore them")
    }

    func testOverlappingRentals_lastOneWins() async {
        let kiteManager = SimpleKiteManager()
        let rentalManager = MockRentalManager()
        let r1 = makeRental(kiteId: "k1", instructorId: "i1")
        let r2 = makeRental(kiteId: "k1", instructorId: "i2")
        rentalManager.rentalsToReturn = [r1, r2]
        let instructorManager = MockInstructorManager(instructors: [ makeInstructor(id: "i1"), makeInstructor(id: "i2") ])

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.loadKites()

        XCTAssertEqual(vm.activeRentals["k1"]?.instructorId, "i2", "When multiple rentals for the same kite exist, the last one in the list wins in current implementation")
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
