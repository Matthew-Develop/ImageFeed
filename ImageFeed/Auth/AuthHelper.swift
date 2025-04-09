//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Matthew on 09.04.2025.
//

import Foundation

public protocol AuthHelperProtocol: AnyObject {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    //MARK: Public Functions
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: {$0.name == "code"} )
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    //MARK: Private Functions
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.unsplashAuthorizeURLString) else {
            print("ERROR Creating URL Components for WebView")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope),
        ]

        return urlComponents.url
    }
}
