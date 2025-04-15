//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Matthew on 10.04.2025.
//

import UIKit

public protocol ProfileViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func showLogoutAlert(view: UIViewController)
    var view: ProfileViewControllerProtocol? { get set }
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    //MARK: Public Properties
    weak var view: ProfileViewControllerProtocol?
    
    //MARK: Private Properties
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    //MARK: Public Functions
    func viewDidLoad() {
        let profile = profileService.profile
        let url = profileImageService.profileImageURL
        
        view?.updateProfileData(profile: profile)
        view?.updateProfileImage(url: url)
    }
    
    func showLogoutAlert(view: UIViewController) {
        AlertPresenter.showAlert(
            viewController: view,
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            buttonTitle: "Да",
            button2Title: "Нет",
            completionFirstButton: { [weak self] in
                UIBlockingProgressHUD.show()
                
                self?.profileLogoutService.logout()
                guard let window = UIApplication.shared.windows.first else {
                    assertionFailure("ERROR window configuration after user Logout")
                    return
                }
                let splashViewController = SplashViewController()
                window.rootViewController = splashViewController
                
                UIBlockingProgressHUD.dismiss()
            },
            completionSecondButton: { }
        )
    }
}
