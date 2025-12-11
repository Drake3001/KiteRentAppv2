import XCTest
@testable import KiteRentApp

final class MockKiteManager: KiteManagerProtocol {
    var kites: [DBKite]
    init(kites: [DBKite]) { self.kites = kites }
    func syncKiteStatesWithRentals() async throws { }
    func getAllKites() async throws -> [DBKite] { return kites }
}

final class MockRentalManager: RentalManagerProtocol {
    var activeRentals: [DBRental]
    init(activeRentals: [DBRental]) { self.activeRentals = activeRentals }
    func getActiveRentals() async throws -> [DBRental] { return activeRentals }
    func getAllRentals() async throws -> [DBRental] { return activeRentals }
}

final class MockInstructorManager: InstructorManagerProtocol {
    var instructors: [DBInstructor]
    init(instructors: [DBInstructor]) { self.instructors = instructors }
    func getAllInstructors() async throws -> [DBInstructor] { return instructors }
}

@MainActor
final class KitesurfingListViewModelAsyncTests: XCTestCase {
    @MainActor
    func testLoadKitesAndActiveRentalsMapping() async throws {
        let kite = DBKite(id: "kite1", name: "Kite 1", imageName: "", state: .free, brand: "B", kiteModel: "M", size: "10", dateCreated: nil)
        let now = Date()
        let rental = DBRental(rentalId: "r1", kiteId: "kite1", instructorId: "inst1", startTime: now.addingTimeInterval(-3600), endTime: now.addingTimeInterval(3600))
        let instructor = DBInstructor(instructorId: "inst1", name: "Anna", surname: "S", phoneNumber: nil, dateCreated: nil, state: .active)

        let kiteManager = MockKiteManager(kites: [kite])
        let rentalManager = MockRentalManager(activeRentals: [rental])
        let instructorManager = MockInstructorManager(instructors: [instructor])

        let vm = KitesurfingListViewModel(kiteManager: kiteManager, rentalManager: rentalManager, instructorManager: instructorManager)

        await vm.loadKites()

        XCTAssertEqual(vm.kites.count, 1)
        XCTAssertEqual(vm.kites.first?.id, "kite1")
        XCTAssertEqual(vm.activeRentals["kite1"]?.instructorId, "inst1")
    }
}
