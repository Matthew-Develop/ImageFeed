//
//  AuthTokenService.swift
//  ImageFeed
//
//  Created by Matthew on 10.03.2025.
//

import UIKit
import SwiftKeychainWrapper

final class AuthTokenService {
    
    static let shared = AuthTokenService()
    private let userTokenKey = Constants.userTokenKey
    
    private init() {}
    
    func saveToken(_ token: String) {
        let isSuccess = KeychainWrapper.standard.set(token, forKey: userTokenKey)
        guard isSuccess else {
            assertionFailure("ERROR: Failed to save auth token")
            return
        }
    }
    
    func getToken() -> String? {
        let token: String? = KeychainWrapper.standard.string(forKey: userTokenKey)
        return token
    }
    
    func removeToken() {
        _ = KeychainWrapper.standard.removeObject(forKey: userTokenKey)
    }
}
