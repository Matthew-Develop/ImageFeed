//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Matthew on 16.02.2025.
//

import Foundation

class OLDOAuth2TokenStorage {
    var token: String {
        get {
            UserDefaults.standard.string(forKey: Constants.accessToken) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.accessToken)
        }
    }
}
