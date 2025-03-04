//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Matthew on 18.02.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let showAuthFlowSegueIdentifier = "ShowAuthFlow"
    private let userToken = OAuth2TokenStorage().token
    private let profileService = ProfileService.shared
    
    // MARK: - Overrides Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showNextController()
        print(userToken)
    }
    // MARK: - Private Methods
    private func showNextController() {
        if isUserAuthorized(with: userToken) {
            fetchProfile(userToken)
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
        
        if !userToken.isEmpty {
            fetchProfile(userToken)
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(_):
                self?.switchToTabBarController()

            case .failure(let error):
                assertionFailure("ERROR \(error.localizedDescription)")
            }
        }
    }
}
