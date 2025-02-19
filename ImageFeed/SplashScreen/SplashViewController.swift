//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Matthew on 18.02.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - IB Outlets

    // MARK: - Public Properties

    // MARK: - Private Properties
    private let showAuthFlowSegueIdentifier = "ShowAuthFlow"
    private let userToken = OAuth2TokenStorage().token
    
    // MARK: - Overrides Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showNextController()
        print(userToken)
    }
    
    // MARK: - IB Actions

    // MARK: - Public Methods

    // MARK: - Private Methods
    private func showNextController() {
        if isUserAuthorized(with: userToken) {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthFlowSegueIdentifier, sender: nil)
        }
    }
    
    private func isUserAuthorized(with token: String) -> Bool {
        return token.isEmpty ? false : true
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBar")
        
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  showAuthFlowSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let authVC = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            authVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        switchToTabBarController()
    }
}
