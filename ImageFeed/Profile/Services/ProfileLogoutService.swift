//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Matthew on 31.03.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        removeUserInfo()
        removeViewControllersData()
    }
    
    //MARK: Private Functions
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func removeUserInfo() {
        AuthTokenService.shared.removeToken()
    }
    
    private func removeViewControllersData() {
        ProfileService.shared.clearProfile()
        ProfileImageService.shared.clearProfileImage()
        ImagesListService.shared.clearImagesList()
    }
}
