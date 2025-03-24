//
//  Photo.swift
//  ImageFeed
//
//  Created by Matthew on 24.03.2025.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
