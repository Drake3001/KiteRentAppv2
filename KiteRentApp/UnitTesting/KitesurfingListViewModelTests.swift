import XCTest
@testable import KiteRentApp

final class KitesurfingListViewModelTests: XCTestCase {
    func makeKite(id: String? = nil, name: String, size: String, state: KiteState) -> DBKite {
        return DBKite(id: id, name: name, imageName: "", state: state, brand: "", kiteModel: "", size: size, dateCreated: nil)
    }

    func testFilteredBySearchText() {
        let vm = KitesurfingListViewModel()
        vm.kites = [
            makeKite(name: "Alpha One", size: "10", state: .free),
            makeKite(name: "Beta Two", size: "12", state: .free),
            makeKite(name: "Gamma Three", size: "9", state: .free)
        ]

        vm.searchText = "alpha"
        let results = vm.filteredAndOrderedKites
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Alpha One")
    }

    func testSortBySizeWhenSameState() {
        let vm = KitesurfingListViewModel()
        vm.kites = [
            makeKite(name: "K1", size: "9", state: .free),
            makeKite(name: "K2", size: "12", state: .free),
            makeKite(name: "K3", size: "10", state: .free)
        ]

        vm.isSortAscending = false
        var results = vm.filteredAndOrderedKites
        let sizesDesc = results.compactMap { Int($0.size) }
        XCTAssertEqual(sizesDesc, [12, 10, 9])

        vm.isSortAscending = true
        results = vm.filteredAndOrderedKites
        let sizesAsc = results.compactMap { Int($0.size) }
        XCTAssertEqual(sizesAsc, [9, 10, 12])
    }

    func testGetInstructorForKite() {
        let vm = KitesurfingListViewModel()
        let instructor = DBInstructor(instructorId: "inst1", name: "John", surname: "D", phoneNumber: nil, dateCreated: nil, state: .active)
        vm.activeRentals = ["kite123": instructor]

        let found = vm.getInstructorForKite(kiteId: "kite123")
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.instructorId, "inst1")
    }
}
