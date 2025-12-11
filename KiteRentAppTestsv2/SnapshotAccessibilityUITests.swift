import XCTest

final class SnapshotAccessibilityUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testProfileSnapshotAndAccessibility() throws {
        let app = XCUIApplication()
        app.launch()

        // TODO: add snapshot/assertions once screenshots and identifiers are defined
        throw XCTSkip("Snapshot/accessibility test requires view identifiers and snapshot tooling")
    }
}
