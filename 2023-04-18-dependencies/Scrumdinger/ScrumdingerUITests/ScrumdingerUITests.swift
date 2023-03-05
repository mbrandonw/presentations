import XCTest

@MainActor
final class ScrumdingerUITests: XCTestCase {
  let app = XCUIApplication()

  override func setUpWithError() throws {
    self.continueAfterFailure = false
  }

  func testBasics() async throws {
    self.app.launch()

    self.app.buttons["New Scrum"].tap()

    self.app.textFields["Title"].tap()
    self.app.typeText("Engineering")

    self.app.textFields["New Attendee"].tap()
    self.app.typeText("Blob")
    self.app.buttons["Add attendee"].tap()
    self.app.typeText("Blob Jr.")
    self.app.buttons["Add attendee"].tap()
    self.app.buttons["Add"].tap()

    XCTAssertEqual(self.app.cells.count, 1)
    XCTAssertEqual(self.app.staticTexts["Engineering"].exists, true)
  }
}
