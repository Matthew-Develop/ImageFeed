//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Matthew on 16.02.2025.
//

import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let networkClient = NetworkClient.shared
    
    private init() {}
    
    private func makeTokenRequestOAuth(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeTokenURLString)
        else {
            print("ERROR creating oAuthTokenRequest URLComponents")
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
            print("ERROR creating oAuthTokenRequest URL from URLComponents")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func loadToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeTokenRequestOAuth(code: code) else {return}
        
        networkClient.fetchOAuthToken(urlRequest: request) { result in
            switch result {
            case .success(let data):
                do {
                    let tokenDecoded = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    handler(.success(tokenDecoded.accessToken))
                } catch {
                    handler(.failure(error))
                    print(error.localizedDescription)
                }
            case .failure(let error):
                handler(.failure(error))
                print(error.localizedDescription)
            }
        }
    }
}
