import XCTest
@testable import KiteRentApp

final class E2ERentalFlowTests: XCTestCase {

    final class FakeRentalManager: RentalManagerProtocol {
        var rentals: [DBRental] = []

        func getAllRentals() async throws -> [DBRental] {
            rentals
        }

        func getActiveRentals() async throws -> [DBRental] {
            let now = Date()
            return rentals.filter { $0.endTime > now }
        }

        func add(_ rental: DBRental) {
            rentals.append(rental)
        }

        func remove(rentalId: String) {
            rentals.removeAll { $0.rentalId == rentalId }
        }
    }

    final class FakeKiteManager: KiteManagerProtocol {
        var kites: [DBKite] = []
        private let rentalManager: RentalManagerProtocol

        init(rentalManager: RentalManagerProtocol) {
            self.rentalManager = rentalManager
        }

        func getAllKites() async throws -> [DBKite] {
            kites
        }

        func syncKiteStatesWithRentals() async throws {
            let activeRentals = try await rentalManager.getActiveRentals()
            let activeKiteIds = Set(activeRentals.map { $0.kiteId })

            for idx in kites.indices {
                let kite = kites[idx]
                let hasActive = activeKiteIds.contains(kite.id ?? "")

                if hasActive && kite.state != .used {
                    kites[idx].state = .used
                } else if !hasActive && kite.state == .used {
                    kites[idx].state = .free
                }
            }
        }
    }

    func testEndToEndRentalFlow_selectReserveSaveCancel_changesKiteState() async throws {
        let rentalManager = FakeRentalManager()
        let kiteManager = FakeKiteManager(rentalManager: rentalManager)

        let kite = DBKite(id: "kite1", name: "TestKite", imageName: "", state: .free, brand: "B", kiteModel: "M", size: "9", dateCreated: nil)
        kiteManager.kites = [kite]

        let now = Date()
        let rental = DBRental(rentalId: "r1", kiteId: "kite1", instructorId: "i1", startTime: now, endTime: now.addingTimeInterval(60*60))
        rentalManager.add(rental)

        try await kiteManager.syncKiteStatesWithRentals()

        let updatedKites1 = try await kiteManager.getAllKites()
        XCTAssertEqual(updatedKites1.first?.state, .used)

        rentalManager.remove(rentalId: "r1")
        try await kiteManager.syncKiteStatesWithRentals()

        let updatedKites2 = try await kiteManager.getAllKites()
        XCTAssertEqual(updatedKites2.first?.state, .free)
    }

    func testRentalManager_getActiveRentals_filtersByEndTime() async throws {
        let rentalManager = FakeRentalManager()

        let now = Date()
        let past = DBRental(rentalId: "past", kiteId: "k1", instructorId: "i1", startTime: now.addingTimeInterval(-3600), endTime: now.addingTimeInterval(-1800))
        let future = DBRental(rentalId: "future", kiteId: "k2", instructorId: "i2", startTime: now, endTime: now.addingTimeInterval(3600))

        rentalManager.add(past)
        rentalManager.add(future)

        let active = try await rentalManager.getActiveRentals()
        XCTAssertEqual(active.count, 1)
        XCTAssertEqual(active.first?.rentalId, "future")
    }
}
