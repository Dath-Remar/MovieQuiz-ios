import XCTest

// MARK: - Test Case Class

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    // MARK: - Test Case Setup
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app=XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    // MARK: - Test Case Teardown
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    // MARK: - Example Test
    
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
    }
    // MARK: - Test Yes Button Changes Poster
    
    func testYesButtonChangesPoster() throws {
        let yesButton = app.buttons["Yes"]
        let poster = app.images["Poster"]
        XCTAssertTrue(poster.waitForExistence(timeout: 5), "The first poster should be visible before tapping 'Yes'.")
        let firstPosterData = poster.screenshot().pngRepresentation
        yesButton.tap()
        let expectation = XCTestExpectation(description: "Wait for poster to change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.5)
        let secondPosterData = poster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData, "The poster should change after tapping 'Yes'.")
    }
    // MARK: - Test Question Number Changes After Yes Button Tapped
    
    func testQuestionNumberChangesAfterYesButtonTapped() throws {
        let yesButton = app.buttons["Yes"]
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5), "Index label should be visible before tapping 'Yes'.")
        yesButton.tap()
        let expectation = XCTestExpectation(description: "Waite for the question number to change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.5)
        let updateQuestionNumber = indexLabel.label
        XCTAssertEqual(updateQuestionNumber, "2/10", "The question number should be '2/10'.")
    }
    // MARK: - Test No Button Changes Poster
    
    func testNoButtonChangesPoster() throws {
        let noButton = app.buttons["No"]
        let poster = app.images["Poster"]
        XCTAssertTrue(poster.waitForExistence(timeout: 5), "The first poster should be visible before tapping 'No'.")
        let firstPosterData = poster.screenshot().pngRepresentation
        noButton.tap()
        let expectation = XCTestExpectation(description: "Wait for poster to change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.5)
        let secondPosterData = poster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData, "The poster should change after tapping 'No'.")
    }
    // MARK: - Test Game Finish
    
    func testGameFinish() {
        let yesButton = app.buttons["Yes"]
        
        for _ in 1...10 {
            yesButton.tap()
            let expectation = XCTestExpectation(description: "Wait for next question or alert")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 2.5)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        let alertExists = alert.waitForExistence(timeout: 5)
        
        XCTAssertTrue(alertExists, "The end of game alert should appear.")
        XCTAssertTrue(alert.buttons["Сыграть ещё раз"].exists, "The 'Play Again' button should be present on the alert.")
    }
    // MARK: - Test Alert Dismiss
    
    func testAlertDismiss() throws {
        let yesButton = app.buttons["Yes"]
        
        for _ in 1...10 {
            yesButton.tap()
            let expectation = XCTestExpectation(description: "Wait for next question or alert")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 2.5)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Alert should be present")
        alert.buttons["Сыграть ещё раз"].tap()
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5), "Index label should be visible after alert dismissal.")
        XCTAssertEqual(indexLabel.label, "1/10", "Game should reset to the first question after alert dismissal.")
    }
}

