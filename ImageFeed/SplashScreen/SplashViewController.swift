//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Matthew on 18.02.2025.
//

import UIKit

final class SplashViewController: UIViewController {
   
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let authTokenService = AuthTokenService.shared
    
    // MARK: Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showNextController()
        print(checkToken())
    }
    
    // MARK: Private Methods
    private func showNextController() {
        let token = checkToken()
        
        if isUserAuthorized(with: token) {
            fetchProfile(token)
        } else {
            guard let authViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            
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
        
        let tabBarController = TabBarController()
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
        !token.isEmpty
    }
}

//Setup view
extension SplashViewController {
    private func setupView() {
        view.backgroundColor = .ypBlack
        addYpImageLogo()
    }
    
    private func addYpImageLogo() {
        let imageLogo = UIImageView(image: UIImage(named: "launchScreenLogo"))
        imageLogo.autoResizeOff()
        view.addSubview(imageLogo)
        NSLayoutConstraint.activate([
            imageLogo.heightAnchor.constraint(equalToConstant: 75),
            imageLogo.widthAnchor.constraint(equalToConstant: 72),
            
            imageLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension SplashViewController: AuthViewControllerDelegate {
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
