//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/30/25.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileData(profile: Profile?)
    func updateProfileImage(url: URL?)
    var presenter: ProfileViewPresenterProtocol? { get set }
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    //MARK: View
    private var profileImage = UIImageView()
    private var profileName = UILabel()
    private var profileLoginName = UILabel()
    private var profileBio = UILabel()
    private var vStack = UIStackView(arrangedSubviews: [])
    
    //MARK: Public Properties
    var presenter: ProfileViewPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        setupView()
    }
    
    //MARK: Public Functions
    func updateProfileData(profile: Profile?) {
        guard let profile = profile
        else {
            print("ERROR getting profile data")
            return
        }
        profileName.text = profile.name
        profileLoginName.text = profile.loginName
        profileBio.text = profile.bio
    }
    
    func updateProfileImage(url: URL?) {
        guard let url = url
        else {
            print("ERROR getting profileImage URL")
            return
        }
        
        if url.description.contains("placeholder") {
            profileImage.image = UIImage(named: "placeholder_profile_image")
        } else {
            profileImage.kf.indicatorType = .activity
            profileImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder_profile_image")
            )
        }
    }
    
    @objc
    private func exitButton() {
        showLogoutAlert()
    }
}

//Setup view
extension ProfileViewController {
    private func setupView() {
        view.backgroundColor = .ypBlack
        
        setupUserInfo()
        addProfileImage()
        addUserInfo()
        addExitButton()
        addFavoriteImages()
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
        button.accessibilityIdentifier = AccessID.profileLogoutButton
        
        button.tintColor = .ypRed
        button.imageEdgeInsets = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
        
        button.autoResizeOff()
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
}

//Alert
extension ProfileViewController {
    func showLogoutAlert() {
        presenter?.showLogoutAlert(view: self)
    }
}
