//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Matthew on 14.02.2025.
//

import UIKit

final class AuthViewController: UIViewController{
    // MARK: - IB Outlets

    // MARK: - Public Properties
    
    // MARK: - Private Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oAuthService = OAuth2Service.shared
    // MARK: - Overrides Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webVC = segue.destination as? WebViewViewController else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            webVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    // MARK: - IB Actions
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oAuthService.loadToken(code: code)
    }
    
    func webViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
}
