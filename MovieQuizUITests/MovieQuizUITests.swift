//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    private let mainPage = MainPage()
    private let alertPage = AlertPage()

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    // MARK: - Tests
    func testYesButton() throws {
        waitForAbsence(element: mainPage.activityIndicator)
        let firstPosterData = mainPage.posterImageData
        let firstIndexLabel = mainPage.questionIndexLabel.label

        XCTAssertEqual(firstIndexLabel, "1/10")

        mainPage.yesButton.tap()

        waitForAbsence(element: mainPage.activityIndicator)

        let secondPosterData = mainPage.posterImageData
        let secondIndexLabel = mainPage.questionIndexLabel.label
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(secondIndexLabel, "2/10")
    }

    func testNoButton() throws {
        waitForAbsence(element: mainPage.activityIndicator)

        let firstPosterData = mainPage.posterImageData
        let firstIndexLabel = mainPage.questionIndexLabel.label

        XCTAssertEqual(firstIndexLabel, "1/10")

        mainPage.noButton.tap()

        waitForAbsence(element: mainPage.activityIndicator)

        let secondPosterData = mainPage.posterImageData
        let secondIndexLabel = mainPage.questionIndexLabel.label
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(secondIndexLabel, "2/10")
    }
    
    func testAlertWithQuizResults() throws {
        waitForAbsence(element: mainPage.activityIndicator)

        mainPage
            .noButton
            .tap(times: 10,
                 andWaitForAbsenceOfElement: mainPage.activityIndicator)

        XCTAssertTrue(alertPage.view.exists)
        XCTAssertEqual(alertPage.title, "Этот раунд окончен!")
        XCTAssertEqual(alertPage.button.label, "Сыграть еще раз")
    }

    func testAlertWithQuizResultsPlayAgain() throws {
        waitForAbsence(element: mainPage.activityIndicator)

        mainPage
            .yesButton
            .tap(times: 10,
                 andWaitForAbsenceOfElement: mainPage.activityIndicator)

        XCTAssertTrue(alertPage.view.exists)

        alertPage.button.tap()
        
        waitForAbsence(element: mainPage.activityIndicator)

        XCTAssertFalse(alertPage.view.exists)
        XCTAssertEqual(mainPage.questionIndexLabel.label, "1/10")
    }
}
