//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/27/25.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    //MARK: Private Properties
    private var cellImageView: UIImageView?
    private var likeButton: UIButton?
    private var date: UILabel?
    private var gradientBox = GradientView()
    
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
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    //MARK: Public Functions
    func setImage(image: UIImage) {
        cellImageView?.removeFromSuperview()
        cellImageView = nil
        
        cellImageView = UIImageView(image: image)
        
        guard let cellImageView = cellImageView else { return }
        cellImageView.autoResizeOff()
        
        cellImageView.contentMode = .scaleAspectFill
        cellImageView.layer.cornerRadius = 16
        cellImageView.layer.masksToBounds = true
        self.addSubview(cellImageView)
        
        NSLayoutConstraint.activate([
            cellImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            cellImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            cellImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4)
        ])
    }
    
    func setLikeButton(image: UIImage) {
        likeButton?.removeFromSuperview()
        likeButton = nil
        
        likeButton = UIButton(type: .custom)
       
        guard let likeButton else { return }
        likeButton.autoResizeOff()
        likeButton.setImage(image, for: .normal)
        
        self.addSubview(likeButton)
        guard let cellImageView else { return }
        NSLayoutConstraint.activate([
            likeButton.heightAnchor.constraint(equalToConstant: 42),
            likeButton.widthAnchor.constraint(equalToConstant: 42),

            likeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor, constant: 0),
            likeButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 0)
        ])
    }
    
    func setDate(dateString: String) {
        date?.removeFromSuperview()
        date = nil
        
        date = UILabel()
        
        guard let date else { return }
        date.autoResizeOff()
            
        date.text = dateString
        date.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        date.textColor = .ypWhite
        
        addGradientBox()
        self.addSubview(date)
        guard let cellImageView else { return }
        NSLayoutConstraint.activate([
            date.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            date.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8)
        ])
    }
    
    //MARK: Private Functions
    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    private func addGradientBox() {
        gradientBox.autoResizeOff()
        
        self.addSubview(gradientBox)
        guard let cellImageView else { return }
        NSLayoutConstraint.activate([
            gradientBox.heightAnchor.constraint(equalToConstant: 30),
            gradientBox.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor),
            gradientBox.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            gradientBox.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor)
        ])
    }
}
