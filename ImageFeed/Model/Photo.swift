//
//  Photo.swift
//  ImageFeed
//
//  Created by Matthew on 24.03.2025.
//

import Foundation

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String
    let welcomeDescription: String?
    let regularImageURL: String
    let fullImageURL: String
    let isLiked: Bool
}
