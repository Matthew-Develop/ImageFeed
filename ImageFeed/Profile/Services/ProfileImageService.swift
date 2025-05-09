//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Matthew on 04.03.2025.
//

import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private var getData = NetworkClientAndDecode.shared
    private(set) var profileImageURL: URL?
    
    private init() {}
    
    //MARK: Public Functions
    func fetchProfileImage(token: String, username: String, handler: @escaping (Result<URL, Error>) -> Void) {
        
        guard let request = makeProfileImageRequest(token: token, username: username)
        else {
            handler(.failure(GetProfileImageError.badRequest))
            return
        }
        
        let task = getData.decodeData(request: request) { [weak self] (result: Result<UserResult, Error>) in
            
            switch result {
            case .success(let decodedData):
                guard let largeImage = decodedData.profileImage["large"]
                else {
                    print("ERROR Get large image: \(GetProfileImageError.smallImageIssue), Decoded data: \(decodedData)")
                    return
                }
                
                guard let url = URL(string: largeImage)
                else {
                    print("ERROR Get URL large image: \(GetProfileImageError.smallImageIssue), Image string: \(largeImage)")
                    return
                }
                
                self?.profileImageURL = url
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["url": url]
                    )
                
                handler(.success(url))
                
            case .failure(let error):
                handler(.failure(error))
                print("ERROR Get Decoded Data: \(error.localizedDescription))")
            }
        }
        
        task.resume()
    }
    
    //MARK: Private Functions
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.unsplashGetProfileImageURLString)\(username)") else { return nil }
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        return request
    }
}

//Logout clear
extension ProfileImageService {
    func clearProfileImage() {
        profileImageURL = nil
    }
}

//ERROR keys
extension ProfileImageService {
    private enum GetProfileImageError: Error {
        case badRequest
        case taskIssue
        case smallImageIssue
    }
}
