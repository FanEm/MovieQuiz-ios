//
//  AlertPresenter.swift
//  MovieQuiz
//

import UIKit

final class ResultAlertPresenter {
    func show(model: AlertModel, from controller: UIViewController) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: model.buttonText, style: .cancel) { _ in
            model.completion()
        }

        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
}
