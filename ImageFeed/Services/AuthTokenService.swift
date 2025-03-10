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
    
    private init() {}
    
    func saveToken(_ token: String) {
        let isSuccess = KeychainWrapper.standard.set(token, forKey: "token")
        guard isSuccess else {
            assertionFailure("ERROR: Failed to save auth token")
            return
        }
    }
    
    func getToken() -> String? {
        let token: String? = KeychainWrapper.standard.string(forKey: "token")
        return token
    }
    
    func removeToken() {
        let removeSuccess: Bool = KeychainWrapper.standard.removeObject(forKey: "token")
    }
}
