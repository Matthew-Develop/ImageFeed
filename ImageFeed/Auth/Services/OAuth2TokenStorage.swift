//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Matthew on 16.02.2025.
//

import Foundation

class OAuth2TokenStorage {
    var token: String {
        get {
            UserDefaults.standard.string(forKey: "token") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
}
