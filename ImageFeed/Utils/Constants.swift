//
//  Constants.swift
//  ImageFeed
//
//  Created by Matthew on 14.02.2025.
//

import Foundation

enum Constants {
    static let userTokenKey = "token"
    
    static let accessKey = "Kf7IfaK-L8IDDfOYBQw_FmLs5F_kmTCwNZQuUmoxJbg"
    static let secretKey = "JaaKATcFxgvVe1UOOCPuQFnLgqNi__71RGl6tU8wHxA"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashAuthorizeTokenURLString = "https://unsplash.com/oauth/token"
    static let unsplashGetProfileDataURLString = "https://api.unsplash.com/me"
    static let unsplashGetProfileImageURLString = "https://api.unsplash.com/users/"
}
