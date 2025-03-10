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
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private enum GetProfileImageError: Error {
        case badRequest
        case taskIssue
        case smallImageIssue
    }
    
    private init() {}
    
    //MARK: Public Functions
    func fetchProfileImage(token: String, username: String, handler: @escaping (Result<URL, Error>) -> Void) {
        
        if lastToken != lastToken {
            handler(.failure(GetProfileImageError.taskIssue))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileImageRequest(token: token, username: username)
        else {
            handler(.failure(GetProfileImageError.badRequest))
            return
        }
        
        let task = getData.decodeData(request: request) { [weak self] (result: Result<UserResult, Error>) in
            
            switch result {
            case .success(let decodedData):
                guard let mediumImage = decodedData.profileImage["medium"]
                else {
                    print("ERROR Get medium image: \(GetProfileImageError.smallImageIssue), Decoded data: \(decodedData)")
                    return
                }
                
                guard let url = URL(string: mediumImage) else {
                    print("ERROR Get URL medium image: \(GetProfileImageError.smallImageIssue), Image string: \(mediumImage)")
                    return
                }
                handler(.success(url))
                print(url)
                self?.profileImageURL = url
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["url": url]
                    )
                
            case .failure(let error):
                handler(.failure(error))
                print("ERROR Get Decoded Data: \(error.localizedDescription))")
            }
            
            self?.lastToken = nil
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    //MARK: Private Functions
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        let url = URL(string: "\(Constants.unsplashGetProfileImageURLString)\(username)")!
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        print(request)
        return request
    }
}
