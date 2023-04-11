import UIKit

// MARK: - MovieQuizViewControllerProtocol
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)

    func showImageBorderAndDisableButtons(isCorrectAnswer: Bool)
    func hideImageBorderAndEnableButtons()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    func showLoadingImageError(message: String)
}

// MARK: - MovieQuizViewController
final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!

    private let imageBorderWidth: CGFloat = 8

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter()
        presenter = MovieQuizPresenter(viewController: self)
        setAccessibilityIdentifiers()
    }

    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }

    // MARK: - Public methods
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }

    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                self.presenter.restartGame()
            }
        )
        alertPresenter?.show(in: self, model: alertModel)
    }

    func showLoadingImageError(message: String) {
        let alertModel = AlertModel(
            title: "Не удалось загрузить постер",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self else { return }
                self.presenter.requestNextQuestion()
            }
        )
        alertPresenter?.show(in: self, model: alertModel)
    }

    func showNetworkError(message: String) {
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self else { return }
                self.presenter.loadData()
            }
        )
        alertPresenter?.show(in: self, model: alertModel)
    }

    func showImageBorderAndDisableButtons(isCorrectAnswer: Bool) {
        let borderColor = isCorrectAnswer ? UIColor.ypGreen : UIColor.ypRed
        imageView.layer.borderWidth = imageBorderWidth
        imageView.layer.borderColor = borderColor.cgColor
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }

    func hideImageBorderAndEnableButtons() {
        imageView.layer.borderWidth = 0
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    private func setAccessibilityIdentifiers() {
        view.accessibilityIdentifier = AccessibilityIdentifier.MainScreen.view
        imageView.accessibilityIdentifier = AccessibilityIdentifier.MainScreen.posterImageView
        yesButton.accessibilityIdentifier = AccessibilityIdentifier.MainScreen.yesButton
        noButton.accessibilityIdentifier = AccessibilityIdentifier.MainScreen.noButton
        counterLabel.accessibilityIdentifier = AccessibilityIdentifier.MainScreen.questionIndexLabel
        activityIndicator.accessibilityIdentifier = AccessibilityIdentifier.MainScreen.activityIndicator
    }
}
