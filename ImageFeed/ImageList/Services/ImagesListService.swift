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
    
    func fetchPhotosNextpage(handler: @escaping (Result<[Photo], Error>)-> Void) {
        let nextPage = (lastLoadedPage ?? 0 ) + 1
        
        assert(Thread.isMainThread)
        guard lastLoadedPage != nextPage
        else {
            handler(.failure(LoadPhotosError.taskIssue))
            return
        }
        
        task?.cancel()
        
        guard let urlRequest = makeFetchPhotosNextPageURLRequest(page: nextPage)
        else {
            handler(.failure(LoadPhotosError.badRequest))
            return
        }
        
        let task = getData.decodeData(request: urlRequest) { [weak self] (result : Result<[PhotoResult], Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let decodedData):
                guard let photos = self.convertResponseToPhotos(data: decodedData)
                else {
                    print("ERROR converting response to photos \(LoadPhotosError.failToConvertDataToPhotos)")
                    handler(.failure(LoadPhotosError.failToConvertDataToPhotos))
                    return
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: photos)
                }
                
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                                
                handler(.success(photos))
                
                self.lastLoadedPage = nextPage
                
            case .failure(let error):
                handler(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
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
        request.httpMethod = "GET"
        return request
    }
    
    private func convertResponseToPhotos(data: [PhotoResult]) -> [Photo]? {
        var photos: [Photo] = []
        
        for photoResult in data {
            guard let thumb = photoResult.urls["thumb"],
                  let largeImage = photoResult.urls["full"]
            else {
                print("ERROR: Could not get images from response ")
                continue
            }
            
            let photo = Photo(
              id: photoResult.id,
              size: CGSize(width: photoResult.width, height: photoResult.height),
              createdAt: photoResult.createdAt,
              welcomeDescription: photoResult.description,
              thumbImageURL: thumb,
              largeImageURL: largeImage,
              isLiked: photoResult.likedByUser
            )
            
            photos.append(photo)
        }
        
        return photos
    }
}
