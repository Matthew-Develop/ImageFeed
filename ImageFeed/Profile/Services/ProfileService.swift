//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Matthew on 03.03.2025.
//

import UIKit

final class ProfileService {
    static let shared = ProfileService()
    
    private let getData = NetworkClientAndDecode.shared
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private enum GetProfileError: Error {
        case badRequest
        case taskIssue
        case failConvertToProfile
    }
    
    private init() { }
    
    //MARK: Public Functions
    func fetchProfile(token: String, handler: @escaping (Result<Profile, Error>)-> Void) {
        
        assert(Thread.isMainThread)
        guard lastToken != token
        else {
            handler(.failure(GetProfileError.taskIssue))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileDataRequest(token: token)
        else {
            handler(.failure(GetProfileError.badRequest))
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
//                print(NetworkError.codeError(response.statusCode).localizedDescription)
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
//                let decodedData = try decoder.decode(ProfileResult.self, from: data)
//                
//                print(decodedData)
//                
//                v
//            } catch {
//                handlerOnMainThread(.failure(error))
//                print(error.localizedDescription)
//            }
//            
//            self?.task = nil
//            self?.lastToken = nil
//        }
        
        let task = getData.decodeData(request: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let decodedData):
                guard let profile = self?.convertResponseToProfile(data: decodedData)
                else {
                    print("ERROR Convert Profile: \(GetProfileError.failConvertToProfile))")
                    return
                }
                handler(.success(profile))
                self?.profile = profile
                
            case .failure(let error):
                handler(.failure(error))
            }
            
            self?.lastToken = nil
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    //MARK: Private Functions
    private func makeProfileDataRequest(token: String) -> URLRequest? {
        var request = URLRequest(url: Constants.unsplashGetProfileDataURL)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        print(request)
        return request
    }
    
    private func convertResponseToProfile(data: ProfileResult) -> Profile {
        guard let bio = data.bio else {
            return Profile(username: data.username, name: "\(data.firstName) \(data.lastName)")
        }
        let profile = Profile(username: data.username, name: "\(data.firstName) \(data.lastName)", bio: bio)
        
        return profile
    }
}
