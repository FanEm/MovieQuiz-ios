//
//  XCTestCase+Extensions.swift
//  MovieQuizUITests
//

import XCTest

// MARK: - Expectation
extension XCTestCase {
    func waitForAbsence(element: XCUIElement, timeout: TimeInterval = 3.0) {
        let expectation = expectation(
            for: NSPredicate(format: "exists == false"),
            evaluatedWith: element,
            handler: .none
        )

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)

        XCTAssertEqual(
            result,
            .completed,
            "Element \(element) не пропал с экрана за \(timeout) секунд"
        )
    }
}
