//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//

import XCTest
@testable import MovieQuiz

// MARK: - MovieQuizViewControllerMock
final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {}
    func show(quiz result: QuizResultsViewModel) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showImageBorderAndDisableButtons(isCorrectAnswer: Bool) {}
    func hideImageBorderAndEnableButtons() {}
    func showLoadingImageError(message: String) {}
    func showNetworkError(message: String) {}
}

// MARK: - MovieQuizPresenterTests
final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
