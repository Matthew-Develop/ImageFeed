//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 2/2/25.
//

import UIKit
import Kingfisher

public final class SingleImageViewController: UIViewController {
    weak var delegate: SingleImageViewControllerDelegate?
    
    private var scrollView = UIScrollView()
    private var imageView = UIImageView()
    private lazy var buttonLike = UIButton(type: .custom)
    private lazy var buttonShare = UIButton(type: .custom)
    
    // MARK: Public Properties
    var photo: Photo? {
        didSet {
            guard isViewLoaded else { return }
            loadImage()
        }
    }

    // MARK: Overrides Methods
    public override func viewDidLoad() {
        super.viewDidLoad()
    
        setupView()
        loadImage()
    }

    // MARK: Private Methods
    func changeLikeButtonImage(changeToLike: Bool) {
        let buttonImage = changeToLike ? UIImage(named: "like_active_singleImage") : UIImage(named: "like_no_active_singleImage")
        buttonLike.setImage(buttonImage, for: .normal)
    }
    
    private func setZoomScale(image: UIImage) {
        view.layoutIfNeeded()
        
        let imageSize = image.size
        let rectSize = scrollView.bounds.size
        guard
              imageSize.width != 0, imageSize.height != 0
        else { return }
        
        let hScale = rectSize.width / imageSize.width
        let vScale = rectSize.height / imageSize.height
        
        let minScale = min(hScale, vScale)
        let initialScale = max(hScale, vScale) * 1.2
        let maxScale = max(hScale, vScale) * 2
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale
        scrollView.zoomScale = initialScale
        
        scrollView.layoutIfNeeded()
    }
    
    private func centerImage() {
        let rectSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let x = (contentSize.width - rectSize.width) / 2
        let y = (contentSize.height - rectSize.height) / 2
        
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        
        let vInset = max((rectSize.height - contentSize.height) / 2, 0)
        let hInset = max((rectSize.width - contentSize.width) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
    }
    
    @objc private func didTapSingleBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapLikeButton(_ sender: UIButton) {
        delegate?.didTapLikeButtonSingleImageView(singleImageViewController: self)
        
        UIView.animate(withDuration: 0.05) {
            sender.alpha = 0.7
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 ) {
            UIView.animate(withDuration: 0.1) {
                sender.alpha = 1.0
            }
        }
    }
    
    @objc private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let items: [Any] = [image,"Изображение"]
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }
}

//Setup view
extension SingleImageViewController {
    private func setupView() {
        addImageScrollView()
        addBackButton()
        addLikeShareButtons()
    }
    
    private func loadImage() {
        imageView.kf.cancelDownloadTask()
        imageView.autoResizeOff()
        
        guard let photo = photo,
              let fullURL = URL(string: photo.fullImageURL)
        else  { return }
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.setupScrollView(imageView: imageView, imageSize: imageResult.image.size)
                self.setZoomScale(image: imageResult.image)
                self.centerImage()
            case .failure(let error):
                let errorMessage = "\(error.localizedDescription[error.localizedDescription.startIndex...error.localizedDescription.index(error.localizedDescription.startIndex, offsetBy: 25)])..."
                self.showErrorAlert(String(errorMessage))
            }
        }
    }
    
    private func setupScrollView(imageView: UIImageView, imageSize: CGSize) {
        scrollView.contentSize = imageSize
        scrollView.addSubview(imageView)
    }
    
    private func addImageScrollView() {
        scrollView.delegate = self
        scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .ypBlack
        scrollView.maximumZoomScale = 1.3
        
        scrollView.autoResizeOff()
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9),
        ])
    }
    
    private func addLikeShareButtons() {
        configureLikeButton()
        configureShareButton()
        let hStack = UIStackView(arrangedSubviews: [buttonLike, buttonShare])
        
        hStack.spacing = 137
        hStack.autoResizeOff()
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
    
    private func configureLikeButton() {
        let isLiked = photo?.isLiked ?? false
        let buttonImage = isLiked ? UIImage(named: "like_active_singleImage") : UIImage(named: "like_no_active_singleImage")
        
        buttonLike.autoResizeOff()
        buttonLike.setImage(buttonImage, for: .normal)
        buttonLike.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
    }
    
    private func configureShareButton() {
        buttonShare.autoResizeOff()
        buttonShare.setImage(UIImage(named: "share_button_singleImage"), for: .normal)
        buttonShare.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

//Show alert
extension SingleImageViewController {
    private func repeatLoadImageAction() {
        loadImage()
    }
    
    private func showErrorAlert(_ message: String) {
        AlertPresenter.showAlert(
            viewController: self,
            title: "Что-то пошло не так",
            message: "Не удалось загрузить фото\n\(message)",
            buttonTitle: "OK",
            button2Title: "Повторить",
            completion1: {
                self.dismiss(animated: true)
            },
            completion2: { [weak self] in
                self?.repeatLoadImageAction()
            }
        )
    }
}
