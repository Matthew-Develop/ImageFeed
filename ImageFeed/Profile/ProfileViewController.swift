//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/30/25.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    
    var profileImage = UIImageView()
    var profileName = UILabel()
    var profileLoginName = UILabel()
    var profileBio = UILabel()
    var vStack = UIStackView(arrangedSubviews: [])
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let authTokenService = AuthTokenService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileImageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Обработать / Проверить
        NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main,
                using: { [weak self] result in
                    guard let self = self else { return }
                    self.updateProfileImage(profileImageService.profileImageURL)
                    //пытался через userInfo передать string
//                    let test = result.userInfo?["url"]
//                    self.profileImageURL = URL(string: test as! String)
                })
        updateProfileImage(profileImageService.profileImageURL)
        
        getProfileData(profile: profileService.profile)
        
        setupView()
        setupUserInfo()
        addProfileImage()
        addUserInfo()
        addExitButton()
        addFavoriteImages()
    }
    
    private func getProfileData(profile: Profile?) {
        guard let profile = profile
        else {
            assertionFailure("ERROR getting profile data")
            return
        }
        
        profileName.text = profile.name
        profileLoginName.text = profile.loginName
        profileBio.text = profile.bio
    }
    
    private func updateProfileImage(_ url: URL?) {
        guard let url = url else { return }
        
        if url.description.contains("placeholder") {
            profileImage.image = UIImage(named: "placeholder_profile_image")
        } else {
            let processor = RoundCornerImageProcessor(cornerRadius: 35)
            profileImage.kf.indicatorType = .activity
            profileImage.kf.setImage(with: url,
                                     placeholder: UIImage(named: "placeholder_profile_image"),
                                     options: [.processor(processor)])
        }
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
    }
    
    private func setupUserInfo() {
        profileName.font = .systemFont(ofSize: 23, weight: .bold)
        profileName.textColor = .ypWhite
        
        profileLoginName.font = .systemFont(ofSize: 13)
        profileLoginName.textColor = .ypGray
        
        profileBio.font = .systemFont(ofSize: 13)
        profileBio.textColor = .ypWhite
    }
    
    private func addProfileImage() {
        profileImage.autoResizeOff()
        profileImage.layer.cornerRadius = 35
        profileImage.layer.masksToBounds = true
        view.addSubview(profileImage)
        NSLayoutConstraint.activate([
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    
    private func addUserInfo() {
        vStack.addArrangedSubview(profileName)
        vStack.addArrangedSubview(profileLoginName)
        vStack.addArrangedSubview(profileBio)
        vStack.autoResizeOff()
        
        vStack.axis = .vertical
        vStack.spacing = 8
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vStack.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8)
        ])
    }
    
    private func addExitButton() {
        let button = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward") ?? UIImage(),
            target: self,
            action: #selector(Self.exitButton))
        button.autoResizeOff()
        button.tintColor = .ypRed
        button.imageEdgeInsets = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
        
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 44),
            button.widthAnchor.constraint(equalToConstant: 44),
            
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            button.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)
        ])
    }
    
    private func addFavoriteImages() {
        let titleLabel = UILabel()
        titleLabel.autoResizeOff()
        
        titleLabel.text = "Избранное"
        titleLabel.font = .systemFont(ofSize: 23, weight: .bold)
        titleLabel.textColor = .ypWhite
        
        view.addSubview(titleLabel)
        
        let emptyFavoriteImage = UIImageView()
        emptyFavoriteImage.autoResizeOff()
        emptyFavoriteImage.image = UIImage(named: "empty_favorites_logo_profile")
        
        view.addSubview(emptyFavoriteImage)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 24),
            
            emptyFavoriteImage.heightAnchor.constraint(equalToConstant: 115),
            emptyFavoriteImage.widthAnchor.constraint(equalToConstant: 115),
            emptyFavoriteImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 110),
            emptyFavoriteImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc
    private func exitButton() {
        authTokenService.removeToken()
    }
}
