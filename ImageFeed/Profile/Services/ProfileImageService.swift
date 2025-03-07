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
    private(set) var profileImageURL: String?
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private enum GetProfileImageError: Error {
        case badRequest
        case taskIssue
        case smallImageIssue
    }
    
    private init() {}
    
    //MARK: Public Functions
    func fetchProfileImage(token: String, username: String, handler: @escaping (Result<String, Error>) -> Void) {
        
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
        
//        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            if let error = error {
//                handlerOnMainThread(.failure(NetworkError.urlRequestError))
//                print(error.localizedDescription)
//                return
//            }
//            
//            if let response = response as? HTTPURLResponse,
//               response.statusCode < 200 || response.statusCode >= 300 {
//                handlerOnMainThread(.failure(NetworkError.codeError(response.statusCode)))
//                print(response.statusCode)
//                return
//            }
//            
//            guard let data = data
//            else {
//                handlerOnMainThread(.failure(NetworkError.urlSessionError))
//                print(NetworkError.urlSessionError.localizedDescription)
//                return
//            }
//            
//            do {
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                
//                let decodedData = try decoder.decode(UserResult.self, from: data)
//                
//                guard let smallImageURL = decodedData.profileImage["small"]
//                else {
//                    print("ERROR getting small image")
//                    return
//                }
//                
//                handlerOnMainThread(.success(smallImageURL))
//                self?.profileImageURL = smallImageURL
//                
//                NotificationCenter.default
//                    .post(
//                        name: ProfileImageService.didChangeNotification,
//                        object: self,
//                        userInfo: ["url": smallImageURL]
//                    )
//            } catch {
//                handlerOnMainThread(.failure(error))
//                print(error.localizedDescription)
//            }
//            
//            self?.lastToken = nil
//            self?.task = nil
//        }
        let task = getData.decodeData(request: request) { [weak self] (result: Result<UserResult, Error>) in
            
            switch result {
            case .success(let decodedData):
                guard let smallImageURL = decodedData.profileImage["small"]
                else {
                    print("ERROR Get small image: \(GetProfileImageError.smallImageIssue), Decoded data: \(decodedData)")
                    return
                }
                
                handler(.success(smallImageURL))
                self?.profileImageURL = smallImageURL
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["url": smallImageURL]
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
