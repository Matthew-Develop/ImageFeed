//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Matthew on 09.04.2025.
//

import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String

    let unsplashAuthorizeURLString: String
    let unsplashAuthorizeTokenURLString: String
    let unsplashGetProfileDataURLString: String
    let unsplashGetProfileImageURLString: String
    let unsplashGetPhotosURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, unsplashAuthorizeURLString: String, unsplashAuthorizeTokenURLString: String, unsplashGetProfileDataURLString: String, unsplashGetProfileImageURLString: String, unsplashGetPhotosURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.unsplashAuthorizeURLString = unsplashAuthorizeURLString
        self.unsplashAuthorizeTokenURLString = unsplashAuthorizeTokenURLString
        self.unsplashGetProfileDataURLString = unsplashGetProfileDataURLString
        self.unsplashGetProfileImageURLString = unsplashGetProfileImageURLString
        self.unsplashGetPhotosURLString = unsplashGetPhotosURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            unsplashAuthorizeURLString: Constants.unsplashAuthorizeURLString,
            unsplashAuthorizeTokenURLString: Constants.unsplashAuthorizeTokenURLString,
            unsplashGetProfileDataURLString: Constants.unsplashGetProfileDataURLString,
            unsplashGetProfileImageURLString: Constants.unsplashGetProfileImageURLString,
            unsplashGetPhotosURLString: Constants.unsplashGetPhotosURLString
        )
    }
}
