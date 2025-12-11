import XCTest
@testable import KiteRentApp

final class KiteStateTests: XCTestCase {
    func testKiteStateOrdering() {
        let free = KiteState.free
        let used = KiteState.used
        let serviced = KiteState.serviced

        XCTAssertTrue(free < used, "free should be less than used")
        XCTAssertTrue(used < serviced, "used should be less than serviced")

        let array: [KiteState] = [.serviced, .free, .used]
        let sorted = array.sorted()
        XCTAssertEqual(sorted, [.free, .used, .serviced])
    }
}
