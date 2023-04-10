//
//  MainPage.swift
//  MovieQuizUITests
//

import XCTest

struct MainPage {
    var view: XCUIElement {
        XCUIApplication().otherElements[AccessibilityIdentifier.MainScreen.view]
    }

    var yesButton: XCUIElement {
        view.buttons[AccessibilityIdentifier.MainScreen.yesButton]
    }
    
    var noButton: XCUIElement {
        view.buttons[AccessibilityIdentifier.MainScreen.noButton]
    }

    var activityIndicator: XCUIElement {
        view.activityIndicators[AccessibilityIdentifier.MainScreen.activityIndicator]
    }

    var posterImageView: XCUIElement {
        view.images[AccessibilityIdentifier.MainScreen.posterImageView]
    }
    
    var posterImageData: Data {
        posterImageView.screenshot().pngRepresentation
    }
    
    var questionIndexLabel: XCUIElement {
        view.staticTexts[AccessibilityIdentifier.MainScreen.questionIndexLabel]
    }
}
