//
//  AlertPresenter.swift
//  MovieQuiz
//

import UIKit

final class AlertPresenter {
    func show(in controller: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: model.buttonText, style: .cancel) { _ in
            model.completion()
        }

        alert.addAction(action)
        alert.view.accessibilityIdentifier = AccessibilityIdentifier.Alert.view
        controller.present(alert, animated: true, completion: nil)
    }
}
