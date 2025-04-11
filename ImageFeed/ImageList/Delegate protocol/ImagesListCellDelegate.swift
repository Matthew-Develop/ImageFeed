//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Matthew on 29.03.2025.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func didTapLikeButtonTableView(cell: ImagesListCell)
}
