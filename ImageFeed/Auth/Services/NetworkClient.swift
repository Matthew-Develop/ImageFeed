//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Matthew on 16.02.2025.
//

import UIKit

protocol NetworkRouting {
    func fetchOAuthToken(url: URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
}

final class NetworkClient {
    
    static let shared = NetworkClient()
    
    private enum NetworkError: Error {
        case codeError(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    func fetchOAuthToken(urlRequest: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        let handlerOnMainThread: (Result<Data, Error>) ->Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                handlerOnMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handlerOnMainThread(.failure(NetworkError.codeError(response.statusCode)))
                return
            }
            
            guard let data = data
            else {
                handlerOnMainThread(.failure(NetworkError.urlSessionError))
                print ("No data")
                return
            }
            
            handlerOnMainThread(.success(data))
        }
        task.resume()
    }
}
