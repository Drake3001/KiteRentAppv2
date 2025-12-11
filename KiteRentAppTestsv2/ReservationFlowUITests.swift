import XCTest

final class ReservationFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testReserveAppearsInActiveList() throws {
        let app = XCUIApplication()
        app.launch()

        // TODO: implement when accessibility identifiers and test accounts are available.
        throw XCTSkip("Reservation flow test needs accessibility identifiers and a test account/setup")
    }
}
