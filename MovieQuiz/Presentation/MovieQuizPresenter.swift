//
//  MovieQuizPresenter.swift
//  MovieQuiz
//

import UIKit

// MARK: - MovieQuizPresenter
final class MovieQuizPresenter {
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let statisticService: StatisticService!

    private var currentQuestion: QuizQuestion?
    private let questionsAmount = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswerCount: Int = 0
    private var resultMessage: String {
        let result = "Ваш результат: \(correctAnswerCount)/\(questionsAmount)"
        guard let statisticService else {
            return result
        }
        let gamesCount = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGame: GameRecord = statisticService.bestGame
        let record = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let totalAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        return "\(result)\n\(gamesCount)\n\(record)\n\(totalAccuracy)"
    }

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    func restartGame() {
        correctAnswerCount = 0
        currentQuestionIndex = 0
        requestNextQuestion()
    }

    func loadData() {
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
    }

    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
        viewController?.showLoadingIndicator()
    }

    func yesButtonClicked() {
        buttonClicked(givenAnswer: true)
    }

    func noButtonClicked() {
        buttonClicked(givenAnswer: false)
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    // MARK: Private functions
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswerCount += 1
        }
    }

    private func showAnswerResult(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)

        viewController?.showImageBorderAndDisableButtons(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.viewController?.hideImageBorderAndEnableButtons()
        }
    }

    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService?.store(correct: correctAnswerCount, total: questionsAmount)

            let resultViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultMessage,
                buttonText: "Сыграть еще раз"
            )
            viewController?.show(quiz: resultViewModel)
        } else {
            switchToNextQuestion()
            requestNextQuestion()
        }
    }

    private func buttonClicked(givenAnswer: Bool) {
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

// MARK: - MovieQuizPresenter+QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()

        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    func didFailToLoadImage(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showLoadingImageError(message: error.localizedDescription)
    }
}
