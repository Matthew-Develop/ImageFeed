//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 2/2/25.
//

import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: Private Properties
    private var scrollView: SingleImageScrollView?
    
    // MARK: Public Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded,
                  let scrollView = scrollView,
                  let image = image else { return }
            scrollView.set(image: image)
        }
    }

    // MARK: Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }

    // MARK: Private Methods
    private func setupView() {
        view.backgroundColor = .ypBlack
        
        addScrollView()
        addBackButton()
        addLikeShareButtons()
    }
    
    private func addScrollView() {
        scrollView = SingleImageScrollView(frame: view.bounds)
        
        guard let scrollView = scrollView,
              let image = image else { return }
        scrollView.set(image: image)
        
        scrollView.autoResizeOff()
        scrollView.backgroundColor = .ypBlack
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func addBackButton() {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTapSingleBackButton), for: .touchUpInside)
        button.setImage(UIImage(named: "singleImage_back_button"), for: .normal)
        button.tintColor = .ypWhite
        
        button.autoResizeOff()
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 24),
            button.widthAnchor.constraint(equalToConstant: 24),
            
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9)
        ])
    }
    
    private func addLikeShareButtons() {
        let buttonLike = UIButton(type: .custom)
        buttonLike.autoResizeOff()
        buttonLike.setImage(UIImage(named: "like_button_singleImage"), for: .normal)
        
        let buttonShare = UIButton(type: .custom)
        buttonShare.autoResizeOff()
        buttonShare.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        buttonShare.setImage(UIImage(named: "share_button_singleImage"), for: .normal)
        
        let hStack = UIStackView(arrangedSubviews: [buttonLike, buttonShare])
        hStack.autoResizeOff()
        hStack.spacing = 137

        view.addSubview(hStack)
        NSLayoutConstraint.activate([
            buttonLike.heightAnchor.constraint(equalToConstant: 51),
            buttonLike.widthAnchor.constraint(equalToConstant: 51),
            buttonShare.heightAnchor.constraint(equalToConstant: 51),
            buttonShare.widthAnchor.constraint(equalToConstant: 51),
            
            hStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -13),
        ])
    }
    
    @objc private func didTapSingleBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapShareButton(_ sender: Any) {
        guard let image = image else { return }
        let items: [Any] = [image,"Изображение"]
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        present(activity, animated: true, completion: nil)
    }
}
