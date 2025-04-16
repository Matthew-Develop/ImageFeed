//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Matthew on 11.04.2025.
//

import UIKit

public protocol ImagesListViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func displayPhotos(indexPath: IndexPath)
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func updateTableViewAnimated()
    func didTapLikeButtonTableView(cell: ImagesListCell, view: UIViewController)
    func didTapLikeButtonSingleImageView(_ singleImageViewController: SingleImageViewController)
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    //MARK: Public Properties
    weak var view: ImagesListViewControllerProtocol?
    
    //MARK: Private Properties
    private let imagesListService = ImagesListService.shared
    var photos: [Photo] = []
    
    private lazy var dateFormatterFromString = ISO8601DateFormatter()
    private lazy var dateFormatterToString: DateFormatter = {
        let dateFormatterToString = DateFormatter()
        dateFormatterToString.dateFormat = "d MMM yyyy"
        return dateFormatterToString
    }()
   
    //MARK: Public Functions
    func reloadTableRow(indexPath: IndexPath) {
        view?.reloadTableRow(indexPath: indexPath)
    }
    
    func insertTableRows(indexPathArray: [IndexPath]) {
        view?.insertTableRows(indexPathArray: indexPathArray)
    }
    
    func viewDidLoad() {
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextpage { result in
            switch result {
            case .failure(let error):
                print("ERROR fetch next page: \(error.localizedDescription)")
            case .success:
                print("success fetch next page")
            }
        }
    }
    
    func displayPhotos(indexPath: IndexPath) {
        if !ProcessInfo().arguments.contains("testMode") {
            print("Not test mode")
            if indexPath.row + 1 == photos.count {
                fetchPhotosNextPage()
            }
        }
        print("test mode")
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        let regularURLString = photo.regularImageURL
        let regularURL = URL(string: regularURLString)
        cell.setImage(url: regularURL) { [weak self] in
            self?.reloadTableRow(indexPath: indexPath)
        }
        
        let date = photo.createdAt
        var dateString: String = ""
        if let dateGet = dateFormatterFromString.date(from: date) {
            dateString = dateFormatterToString.string(from: dateGet)
        }
        cell.setDate(dateString: dateString)
        
        cell.setLikeButton(isLiked: photo.isLiked)
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        photos = imagesListService.photos
        
        if oldCount != newCount {
            var indexPathArray: [IndexPath] = []
            for i in oldCount..<newCount {
                indexPathArray.append(IndexPath(row: i, section: 0))
            }
            
            insertTableRows(indexPathArray: indexPathArray)
        }
    }
    
    //MARK: Did TapLike Functions
    func didTapLikeButtonTableView(cell: ImagesListCell, view: UIViewController) {
        guard let indexPath = self.view?.getIndexPath(from: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.toggleLike(photoID: photo.id, toLike: !photo.isLiked, indexPath: indexPath) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.changeLikeButtonImage(changeToLike: !photo.isLiked)
                self.reloadTableRow(indexPath: indexPath)
            case .failure(let error):
                print("ERROR like photo: \(error.localizedDescription)")
                let errorMessage = error.localizedDescription.components(separatedBy: "(")[0]
                self.showLikeAlertTableView(view: view, message: errorMessage)
            }
        }
    }
    
    func didTapLikeButtonSingleImageView(_ singleImageViewController: SingleImageViewController) {
        guard let photoFromController = singleImageViewController.photo,
              let index = photos.firstIndex(where: { $0.id == photoFromController.id })
        else { return }
        let indexPath = IndexPath(row: index, section: 0)
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.toggleLike(photoID: photo.id, toLike: !photo.isLiked, indexPath: indexPath) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("ERROR like photo: \(error.localizedDescription)")
                let errorMessage = error.localizedDescription.components(separatedBy: "(")[0]
                self.showLikeAlertSingleImage(view: singleImageViewController, message: errorMessage)
            case .success():
                self.photos = self.imagesListService.photos
                singleImageViewController.changeLikeButtonImage(changeToLike: !photo.isLiked)
                self.reloadTableRow(indexPath: indexPath)
            }
        }
    }
    
    //MARK: Show Like Alert
    func showLikeAlertTableView(view: UIViewController, message: String) {
        AlertPresenter.showAlert(
            viewController: view,
            title: "Что-то пошло не так :(",
            message: "Не удалось поставить/снять лайк\n\(message)",
            buttonTitle: nil,
            completionFirstButton: {},
            completionSecondButton: {}
        )
    }
    
    func showLikeAlertSingleImage(view: UIViewController, message: String) {
        AlertPresenter.showAlert(
            viewController: view,
            title: "Что-то пошло не так",
            message: "Не удалось поставить/снять лайк\n\(message)",
            buttonTitle: nil,
            completionFirstButton: {},
            completionSecondButton: {}
        )
    }
}
