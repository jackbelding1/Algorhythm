import XCTest


class RootViewTests: XCTestCase {
    var app: XCUIApplication!

        override func setUp() {
            super.setUp()
            continueAfterFailure = false
            app = XCUIApplication()
            app.launch()
        }

        func testAuthorizedViewAppears() {
            let authorizedView = app.otherElements["authorizedView"]
            XCTAssertTrue(authorizedView.exists)
        }

        func testUnauthorizedViewAppears() {
            let unauthorizedView = app.otherElements["unauthorizedView"]
            XCTAssertTrue(unauthorizedView.exists)
        }

        func testLogoImageAppears() {
            let logoImage = app.images["logoImage"]
            XCTAssertTrue(logoImage.exists)
        }

        func testTitleLabelAppears() {
            let titleLabel = app.staticTexts["titleLabel"]
            XCTAssertTrue(titleLabel.exists)
        }
    }
