//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Matthew on 07.03.2025.
//

import UIKit

final class AlertPresenter {
    static func showAlert(viewController: UIViewController, title: String?, message: String?, buttonTitle: String?, button2Title: String? = nil, completion1: @escaping (() -> Void), completion2: @escaping (() -> Void)) {
        let alert = UIAlertController(
            title: title ?? "Error",
            message: message ?? "Something went wrong",
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: buttonTitle ?? "OK",
            style: .default) { _ in
                completion1()
        }
        
        alert.addAction(action)

        if button2Title != nil {
            let secondAction = UIAlertAction(
                title: button2Title,
                style: .default) { _ in
                    completion2()
                }
            alert.addAction(secondAction)
        }
        
        viewController.present(alert, animated: true)
    }
}
