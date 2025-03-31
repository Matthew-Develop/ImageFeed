//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Matthew on 24.03.2025.
//

import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    //MARK: Private Properties
    private let getData = NetworkClientAndDecode.shared
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    private init() {}
    
    private enum LoadPhotosError: Error {
        case badRequest
        case taskIssue
        case failToConvertDataToPhotos
    }
    
    private enum LikeError: Error {
        case badRequest
        case taskIssue
        case httpCodeError(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    //MARK: - Public Functions
    func fetchPhotosNextpage(handler: @escaping (Result<[Photo], Error>)-> Void) {
        let nextPage = (lastLoadedPage ?? 0 ) + 1
        
        assert(Thread.isMainThread)
        guard lastLoadedPage != nextPage
        else {
            handler(.failure(LoadPhotosError.taskIssue))
            return
        }
        
        task?.cancel()
        
        guard let request = makeFetchPhotosNextPageURLRequest(page: nextPage)
        else {
            handler(.failure(LoadPhotosError.badRequest))
            return
        }
        
        let task = getData.decodeData(request: request) { [weak self] (result : Result<[PhotoResult], Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let decodedData):
                guard let photos = self.convertResponseToPhotos(data: decodedData)
                else {
                    print("ERROR converting response to photos \(LoadPhotosError.failToConvertDataToPhotos)")
                    handler(.failure(LoadPhotosError.failToConvertDataToPhotos))
                    return
                }
                
                self.lastLoadedPage = nextPage
                self.photos += photos
                                
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                                
                handler(.success(photos))
                
            case .failure(let error):
                handler(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func toggleLike(photoID: String, toLike: Bool, indexPath: IndexPath, handler: @escaping (Result<Void, Error>) -> Void ) {
        let handlerOnMainThread: (Result<Void, Error>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        
        guard let request = makeToggleLikeURLRequest(photoID: photoID, toLike: toLike)
        else {
            handler(.failure(LikeError.badRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (_, response, error) in
            guard let self = self else { return }
            
            if let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode < 200 && statusCode > 300 {
                    handlerOnMainThread(.failure(LikeError.httpCodeError(statusCode)))
                    print("ERROR HTTPResponse: \(LikeError.httpCodeError(statusCode)), Code: \(statusCode))")
                }
            } else if let error = error {
                handlerOnMainThread(.failure(LikeError.urlRequestError(error)))
                print("ERROR URL Request: \(LikeError.urlRequestError(error)), Info: \(error.localizedDescription))")
            } else {
                handlerOnMainThread(.failure(LikeError.urlSessionError))
                print("ERROR URL Session: \(LikeError.urlSessionError))")
            }
            
            let photo = self.photos[indexPath.row]
            let newPhoto = Photo(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                welcomeDescription: photo.welcomeDescription,
                regularImageURL: photo.regularImageURL,
                fullImageURL: photo.fullImageURL,
                isLiked: !photo.isLiked
            )
            self.photos[indexPath.row] = newPhoto
            
            handlerOnMainThread(.success(()))
        }
        
        task.resume()
    }
    
    //MARK: - Private functions
    private func makeFetchPhotosNextPageURLRequest(page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashGetPhotosURLString)
        else {
            assertionFailure("ERROR creating fetchPhotosNextPage URLComponents")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: page.description),
        ]
        
        guard let url = urlComponents.url
        else {
            assertionFailure("ERROR creating fetchPhotosNextPage URL from URLComponents")
            return nil
        }
        var request = URLRequest(url: url)
        guard let token = AuthTokenService.shared.getToken() else { return nil }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    private func makeToggleLikeURLRequest(photoID: String, toLike: Bool) -> URLRequest? {
        guard let token = AuthTokenService.shared.getToken(),
              let url = URL(string: "\(Constants.unsplashGetPhotosURLString)/\(photoID)/like")
        else {
            print("ERROR: Could not create ToggleLike URLRequest")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = toLike ? "POST" : "DELETE"
        return request
    }
    
    private func convertResponseToPhotos(data: [PhotoResult]) -> [Photo]? {
        var photos: [Photo] = []
        
        for photoResult in data {
            guard let regular = photoResult.urls["regular"],
                  let fullImage = photoResult.urls["full"]
            else {
                print("ERROR: Could not get images from response ")
                continue
            }
            
            let photo = Photo(
              id: photoResult.id,
              size: CGSize(width: photoResult.width, height: photoResult.height),
              createdAt: photoResult.createdAt,
              welcomeDescription: photoResult.description,
              regularImageURL: regular,
              fullImageURL: fullImage,
              isLiked: photoResult.likedByUser
            )
            
            photos.append(photo)
        }
        
        return photos
    }
}
