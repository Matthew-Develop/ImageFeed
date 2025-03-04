//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Matthew on 03.03.2025.
//

import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private(set) var profile: Profile?
    
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private init() { }
    
    private enum NetworkError: Error {
        case codeError(Int)
        case urlRequestError
        case urlSessionError
    }
    
    //MARK: Private Functions
    private func makeProfileDataRequest(token: String) -> URLRequest? {
        var request = URLRequest(url: Constants.unsplashGetProfileDataURLString)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        print(request)
        return request
    }
    
    private func convertResponseToProfile(data: ProfileResult) -> Profile {
        guard let bio = data.bio else {
            return Profile(username: data.username, name: "\(data.first_name) \(data.last_name)")
        }
        let profile = Profile(username: data.username, name: "\(data.first_name) \(data.last_name)", bio: bio)
        
        return profile
    }
    
    //MARK: Public Functions
    func fetchProfile(token: String, handler: @escaping (Result<Profile, Error>)-> Void) {
        let handlerOnMainThread: (Result<Profile, Error>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        
        assert(Thread.isMainThread)
        guard lastToken != token
        else {
            handlerOnMainThread(.failure(NetworkError.urlSessionError))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileDataRequest(token: token)
        else {
            handlerOnMainThread(.failure(NetworkError.urlRequestError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                handlerOnMainThread(.failure(NetworkError.urlRequestError))
                print(error.localizedDescription)
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handlerOnMainThread(.failure(NetworkError.codeError(response.statusCode)))
                print(NetworkError.codeError(response.statusCode).localizedDescription)
                return
            }
            
            guard let data = data
            else {
                handlerOnMainThread(.failure(NetworkError.urlSessionError))
                print(NetworkError.urlSessionError.localizedDescription)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                            
                let decodedData = try JSONDecoder().decode(ProfileResult.self, from: data)
                
                print(decodedData)
                
                guard let profile = self?.convertResponseToProfile(data: decodedData)
                else {
                    print("ERROR Could not convert decodedData to Profile")
                    return
                }
                
                handlerOnMainThread(.success(profile))
                
                self?.profile = profile
            } catch {
                handlerOnMainThread(.failure(error))
                print(error.localizedDescription)
            }
            
            self?.task = nil
            self?.lastToken = nil
        }
        
        self.task = task
        task.resume()
    }
}
