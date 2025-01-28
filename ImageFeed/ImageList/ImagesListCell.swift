//
//  ImageListCell.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/27/25.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var gradientDateBox: UIView!
    
    static let reuseIdentifier = "ImagesListCell"
    
    
}
