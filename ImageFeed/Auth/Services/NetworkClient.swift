//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Matthew on 16.02.2025.
//

import UIKit

final class NetworkClient {
    
    static let shared = NetworkClient()
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    private enum NetworkError: Error {
        case codeError(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    enum AuthServiceError: Error {
        case invalidRequest
    }
    
    func fetchOAuthToken(code: String, urlRequest: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        let handlerOnMainThread: (Result<Data, Error>) ->Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        
        assert(Thread.isMainThread)
        guard lastCode != code else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            if let error = error {
                handlerOnMainThread(.failure(NetworkError.urlRequestError(error)))
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
            
            handlerOnMainThread(.success(data))
            
            self?.task = nil
            self?.lastCode = nil
        }
        self.task = task
        task.resume()
    }
}
