//
//  NetworkClient+Decode.swift
//  ImageFeed
//
//  Created by Matthew on 07.03.2025.
//

import Foundation

final class NetworkClientAndDecode {
    static let shared = NetworkClientAndDecode()
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    private init() {}
    
    private enum NetworkError: Error {
        case httpCodeError(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    func decodeData<T: Decodable>(
        request: URLRequest,
        handler: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let task = fetchData(request) { [weak self] (result: Result<Data, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let decodedData = try self.decoder.decode(T.self, from: data)
                    handler(.success(decodedData))
                } catch {
                    handler(.failure(error))
                    print("ERROR декодирования: \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
        
        return task
    }
    
    private func fetchData(_ request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let handlerOnMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200..<300 ~= statusCode {
                    handlerOnMainThread(.success(data))
                } else {
                    handlerOnMainThread(.failure(NetworkError.httpCodeError(statusCode)))
                    print("ERROR HTTPResponse: \(NetworkError.httpCodeError(statusCode)), Code: \(statusCode))")

                }
            } else if let error = error {
                handlerOnMainThread(.failure(NetworkError.urlRequestError(error)))
                print("ERROR URL Request: \(NetworkError.urlRequestError(error)), Info: \(error.localizedDescription))")
            } else {
                handlerOnMainThread(.failure(NetworkError.urlSessionError))
                print("ERROR URL Session: \(NetworkError.urlSessionError))")
            }
        }
        
        return task
    }
}
