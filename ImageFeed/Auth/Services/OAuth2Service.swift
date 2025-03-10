//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Matthew on 16.02.2025.
//

import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let getData = NetworkClientAndDecode.shared
    private let authTokenService = AuthTokenService.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private enum LoadTokenError: Error {
        case badRequest
        case taskIssue
    }
    
    private init() {}
    
    func loadToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        guard lastCode != code else {
            handler(.failure(LoadTokenError.taskIssue))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeTokenRequestOAuth(code: code)
        else {
            handler(.failure(LoadTokenError.badRequest))
            print("ERROR URL Request: \(LoadTokenError.badRequest))")
            return
        }
        
        let task = getData.decodeData(request: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let tokenDecoded):
                self?.authTokenService.saveToken(tokenDecoded.accessToken)
                handler(.success(tokenDecoded.accessToken))
            case .failure(let error):
                handler(.failure(error))
            }
            
            self?.lastCode = nil
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeTokenRequestOAuth(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeTokenURLString)
        else {
            assertionFailure("ERROR creating oAuthTokenRequest URLComponents")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url
        else {
            assertionFailure("ERROR creating oAuthTokenRequest URL from URLComponents")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
