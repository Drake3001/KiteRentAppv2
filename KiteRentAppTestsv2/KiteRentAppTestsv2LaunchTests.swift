//
//  KiteRentAppTestsV2LaunchTests.swift
//  KiteRentAppTestsV2
//
//  Created by Filip on 11/12/2025.
//

import XCTest

 
final class KiteRentAppTestsv2LaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
 
