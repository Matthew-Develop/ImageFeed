//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Matthew on 14.02.2025.
//

import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    // MARK: Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: Private Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oAuthService = OAuth2Service.shared
    private var alertPresenter: AlertPresenter?
    
    //MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(viewController: self, delegate: self)
    }
    
    // MARK: Private Methods
    private func showAuthAlertError(_ errorMessage: String) {
        alertPresenter?.showAlert(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему: \(errorMessage)",
            buttonTitle: "Ок") { [weak self] in
                self?.dismissAlert()
            }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showWebViewSegueIdentifier,
           let webVC = segue.destination as? WebViewViewController
        else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        webVC.delegate = self
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()
        
        oAuthService.loadToken(code: code) { [weak self] result in
            guard let self = self else { return }
        
            switch result {
            case .success(_):
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                let errorMessage = error.localizedDescription.components(separatedBy: "(")[0]
                print(errorMessage)
                self.showAuthAlertError(String(errorMessage))
            }
            
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func webViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController: AlertPresenterDelegate {
    func dismissAlert() { }
}
