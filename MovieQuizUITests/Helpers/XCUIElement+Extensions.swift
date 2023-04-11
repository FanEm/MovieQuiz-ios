//
//  XCUIElement+Extensions.swift
//  MovieQuizUITests
//

import XCTest

extension XCUIElement {
    func tap(times: Int, andWaitForAbsenceOfElement element: XCUIElement) {
        for _ in 1...times {
            self.tap()
            XCTestCase().waitForAbsence(element: element)
        }
    }
}
