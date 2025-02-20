//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Matthew on 14.02.2025.
//

import UIKit

final class AuthViewController: UIViewController{
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oAuthService = OAuth2Service.shared
    
    // MARK: - Private Methods
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
        oAuthService.loadToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                OAuth2TokenStorage().token = data
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        vc.dismiss(animated: true)
    }
    
    func webViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
