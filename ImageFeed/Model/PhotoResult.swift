//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Matthew on 24.03.2025.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let description: String?
    let urls: [String: String]
    let likedByUser: Bool
}
