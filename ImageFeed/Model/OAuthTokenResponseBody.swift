//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Matthew on 16.02.2025.
//

import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
