//
//  AlertPresenter.swift
//  MovieQuiz
//

import UIKit

final class ResultAlertPresenter {
    private let model: AlertModel
    private let controller: UIViewController

    init(model: AlertModel, controller: UIViewController) {
        self.model = model
        self.controller = controller
    }

    func show() {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: model.buttonText, style: .cancel) { _ in
            self.model.completion()
        }

        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
    
}
