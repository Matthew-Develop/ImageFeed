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
    
    enum RequestError: Error {
        case badRequest
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
    
    func loadToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeTokenRequestOAuth(code: code)
        else {
            handler(.failure(RequestError.badRequest))
            return
        }
        
        networkClient.fetchOAuthToken(code: code, urlRequest: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let tokenDecoded = try decoder.decode(OAuthTokenResponseBody.self, from: data)
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
