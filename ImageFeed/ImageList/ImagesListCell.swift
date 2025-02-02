//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/27/25.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var gradientDateBox: UIView!
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Private Properties

    // MARK: - Initializers

    // MARK: - Overrides Methods

    // MARK: - IB Actions

    // MARK: - Public Methods

    // MARK: - Private Methods

    
}
