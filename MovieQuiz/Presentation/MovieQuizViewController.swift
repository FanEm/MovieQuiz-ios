import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswerCount: Int = 0

    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private var alertPresenter: AlertPresenter?

    private var resultMessage: String {
        let result = "Ваш результат: \(correctAnswerCount)/\(Constants.questionsAmount)"
        guard let statisticService else {
            return result
        }
        let gamesCount = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGame: GameRecord = statisticService.bestGame
        let record = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let totalAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        return "\(result)\n\(gamesCount)\n\(record)\n\(totalAccuracy)"
    }

    private enum Constants {
        static let imageBorderWidth: CGFloat = 8
        static let questionsAmount = 10
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter()
        loadData()
    }

    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        buttonClicked(givenAnswer: false)
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        buttonClicked(givenAnswer: true)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    // MARK: - Private functions
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func loadData() {
        showLoadingIndicator()
        questionFactory?.loadData()
    }

    private func buttonClicked(givenAnswer: Bool) {
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswerCount = 0
                self.loadData()
            }
        )
        alertPresenter?.show(in: self, model: alertModel)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswerCount = 0
                self.loadData()
            }
        )
        alertPresenter?.show(in: self, model: alertModel)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswerCount += 1
        }

        let borderColor = isCorrect ? UIColor.ypGreen : UIColor.ypRed
        showBorder(color: borderColor.cgColor)
        disableButtons()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.hideBorder()
            self.enableButtons()
        }
    }

    private func showBorder(color: CGColor) {
        imageView.layer.borderWidth = Constants.imageBorderWidth
        imageView.layer.borderColor = color
    }
    
    private func hideBorder() {
        imageView.layer.borderWidth = 0
    }

    private func disableButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }

    private func enableButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == Constants.questionsAmount - 1 {
            statisticService?.store(correct: correctAnswerCount, total: Constants.questionsAmount)
            
            let resultViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultMessage,
                buttonText: "Сыграть еще раз")
            show(quiz: resultViewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(Constants.questionsAmount)"
        )
    }
}
