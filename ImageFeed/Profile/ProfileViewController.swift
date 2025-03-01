//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/30/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let profileImage = UIImageView()
    let profileName = UILabel()
    let profileUsername = UILabel()
    let profileDescription = UILabel()
    
    var vStack = UIStackView(arrangedSubviews: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupUserInfo()
        addProfileImage()
        addUserInfo()
        addExitButton()
        addFavoriteImages()
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
    }
    
    private func setupUserInfo() {
        profileName.text = "Екатерина Новикова"
        profileName.font = .systemFont(ofSize: 23, weight: .bold)
        profileName.textColor = .ypWhite
        
        profileUsername.text = "@ekaterina_nov"
        profileUsername.font = .systemFont(ofSize: 13)
        profileUsername.textColor = .ypGray
        
        profileDescription.text = "Hello, world!"
        profileDescription.font = .systemFont(ofSize: 13)
        profileDescription.textColor = .ypWhite
    }
    
    private func addProfileImage() {
        profileImage.autoResizeOff()
        profileImage.image = UIImage(named: "photo_profile")
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
        vStack.addArrangedSubview(profileUsername)
        vStack.addArrangedSubview(profileDescription)
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
    
    @objc private func exitButton() {
        UserDefaults.standard.removeObject(forKey: Constants.accessToken)
    }
}
