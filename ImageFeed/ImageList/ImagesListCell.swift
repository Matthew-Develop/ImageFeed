//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/27/25.
//

import UIKit
import Kingfisher

public final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    static let didChangeNotification = Notification.Name("ImagesListCellDidChange")
    weak var delegate: ImagesListCellDelegate?
    
    //MARK: Views
    private var cellImageView = UIImageView()
    private var likeButton = UIButton()
    private var date = UILabel()
    private lazy var gradientBox = GradientView()
    
    private var photo: Photo?
    private var isLiked: Bool = false
    
    //MARK: Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    //MARK: Override Methods
    public override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageView.kf.cancelDownloadTask()
    }
    
    //MARK: Public Functions
    func setImage(url: URL?, completion: @escaping (() -> Void)) {
        guard let url = url else { return }
        cellImageView.kf.indicatorType = .activity
        cellImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder_cell")
        ) { _ in
            completion()
        }
    }
    
    func setLikeButton(isLiked: Bool) {
        guard let buttonImage = isLiked ? UIImage(named: "like_active") : UIImage(named: "like_no_active")
        else { return }
        likeButton.setImage(buttonImage, for: .normal)
    }
    
    func setDate(dateString: String) {
        date.text = dateString
    }
    
    func changeLikeButtonImage(changeToLike: Bool) {
        let buttonImage = changeToLike ? UIImage(named: "like_active") : UIImage(named: "like_no_active")
        likeButton.setImage(buttonImage, for: .normal)
    }
    
    //MARK: Private Functions
    @objc private func toggleLikeButton(_ sender: UIButton) {
        delegate?.didTapLikeButtonTableView(cell: self)
        
        UIView.animate(withDuration: 0.05) {
            sender.alpha = 0.7
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 ) {
            UIView.animate(withDuration: 0.1) {
                sender.alpha = 1.0
            }
        }
    }
}

//Setup view
extension ImagesListCell {
    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        addImage()
        addLikeButton()
        addDateLabel()
    }
    
    private func addImage() {
        cellImageView.contentMode = .scaleAspectFill
        cellImageView.layer.cornerRadius = 16
        cellImageView.layer.masksToBounds = true
        cellImageView.autoResizeOff()
        
        self.addSubview(cellImageView)
        NSLayoutConstraint.activate([
            cellImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            cellImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            cellImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4)
        ])
    }
    
    private func addLikeButton() {
        likeButton.addTarget(self, action: #selector(toggleLikeButton), for: .touchUpInside)
        likeButton.accessibilityIdentifier = "CellLikeButton"
        
        likeButton.autoResizeOff()
        self.addSubview(likeButton)
        NSLayoutConstraint.activate([
            likeButton.heightAnchor.constraint(equalToConstant: 42),
            likeButton.widthAnchor.constraint(equalToConstant: 42),

            likeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor, constant: 0),
            likeButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 0)
        ])
    }
    
    private func addDateLabel() {
        date.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        date.textColor = .ypWhite
        
        addGradientBox()
        date.autoResizeOff()
        self.addSubview(date)
        NSLayoutConstraint.activate([
            date.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            date.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8)
        ])
    }
    
    private func addGradientBox() {
        gradientBox.autoResizeOff()
        
        self.addSubview(gradientBox)
        NSLayoutConstraint.activate([
            gradientBox.heightAnchor.constraint(equalToConstant: 30),
            gradientBox.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor),
            gradientBox.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            gradientBox.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor)
        ])
    }
}
