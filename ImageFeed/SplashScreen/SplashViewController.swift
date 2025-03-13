//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Matthew on 18.02.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private var ypImageLogo = UIImageView()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let authTokenService = AuthTokenService.shared
    
    // MARK: Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addYpImageLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showNextController()
        print(checkToken())
    }
    
    // MARK: Private Methods
    private func setupView() {
        view.backgroundColor = .ypBlack
    }
    
    private func addYpImageLogo() {
        ypImageLogo.image = UIImage(named: "launchScreenLogo")
        view.addSubview(ypImageLogo)
        NSLayoutConstraint.activate([
            ypImageLogo.heightAnchor.constraint(equalToConstant: 75),
            ypImageLogo.widthAnchor.constraint(equalToConstant: 72),
            
            ypImageLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ypImageLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showNextController() {
        let token = checkToken()
        
        if isUserAuthorized(with: token) {
            fetchProfile(token)
        } else {
            let authViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
            
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBar")
        
        window.rootViewController = tabBarController
    }
    
    private func checkToken() -> String {
        guard let token = authTokenService.getToken() else {
            print("ERROR Getting token")
            return ""
        }
        print(token)
        return token
    }
    
    private func isUserAuthorized(with token: String) -> Bool {
        return token.isEmpty ? false : true
    }
}

extension SplashViewController: AuthViewControllerDelegate {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier ==  showAuthFlowSegueIdentifier {
//            guard let navigationController = segue.destination as? UINavigationController,
//                  let authVC = navigationController.viewControllers.first as? AuthViewController
//            else {
//                assertionFailure("Invalid segue destination")
//                return
//            }
//            
//            authVC.delegate = self
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
    func didAuthenticate(_ vc: AuthViewController) {
        let token = checkToken()
        vc.dismiss(animated: true)
        
        if !token.isEmpty {
            fetchProfile(token)
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profile):
                self?.switchToTabBarController()
                self?.profileImageService.fetchProfileImage(token: token, username: profile.username) { _ in }

            case .failure(let error):
                assertionFailure("ERROR \(error.localizedDescription)")
            }
        }
    }
}
