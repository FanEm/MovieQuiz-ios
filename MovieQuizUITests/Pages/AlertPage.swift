//
//  AlertPage.swift
//  MovieQuizUITests
//

import XCTest

struct AlertPage {
    var view: XCUIElement {
        XCUIApplication().alerts[AccessibilityIdentifier.Alert.view]
    }

    var title: String {
        view.label
    }

    var button: XCUIElement {
        view.buttons.firstMatch
    }
}
