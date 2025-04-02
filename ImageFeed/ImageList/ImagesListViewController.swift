//
//  ViewController.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/23/25.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    private var tableView = UITableView()
    
    // MARK: Private Properties
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    private lazy var dateFormatterFromString = ISO8601DateFormatter()
    private lazy var dateFormatterToString: DateFormatter = {
        let dateFormatterToString = DateFormatter()
        dateFormatterToString.dateFormat = "d MMM yyyy"
        return dateFormatterToString
    }()
    
    // MARK: Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
        
        imagesListService.fetchPhotosNextpage { _ in }
    }
    
    //MARK: Public Functions
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextpage { result in
                switch result {
                case .failure(let error):
                    print("ERROR fetch next page: \(error.localizedDescription)")
                case .success:
                    print("success fetch next page")
                }
            }
        }
    }
    
    //MARK: Private Methods
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        let regularURLString = photo.regularImageURL
        let regularURL = URL(string: regularURLString)
        cell.setImage(url: regularURL) { [weak self] in
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        let date = photo.createdAt
        var dateString: String = ""
        if let dateGet = dateFormatterFromString.date(from: date) {
            dateString = dateFormatterToString.string(from: dateGet)
        }
        cell.setDate(dateString: dateString)
        
        cell.setLikeButton(isLiked: photo.isLiked)
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        photos = imagesListService.photos
        
        if oldCount != newCount {
            var indexPathArray: [IndexPath] = []
            for i in oldCount..<newCount {
                indexPathArray.append(IndexPath(row: i, section: 0))
            }
            
            tableView.performBatchUpdates {
                self.tableView.insertRows(
                    at: indexPathArray,
                    with: .automatic)
            } completion: { _ in }
        }
    }
}

//Setup view
extension ImagesListViewController {
    private func setupView() {
        view.backgroundColor = .ypBlack
        
        addTableView()
    }
    
    private func addTableView() {
        tableView.autoResizeOff()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .ypBlack
        tableView.separatorColor = .clear
        if #available(iOS 15.0, *) {
            UITableView.appearance().isPrefetchingEnabled = false
        }
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let singleImageViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "SingleImageViewController") as? SingleImageViewController else { return }
        
        let photo = photos[indexPath.row]
        singleImageViewController.delegate = self
        singleImageViewController.photo = photo
        
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let width = photo.size.width
        let height = photo.size.height
        
        let imageViewWidth = tableView.bounds.width - 2*16
        let imageViewHeight = (imageViewWidth / width) * height
        
        let dynamicCellHeight = imageViewHeight + 4*2
        
        return dynamicCellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func didLikeButtonTapped(cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.toggleLike(photoID: photo.id, toLike: !photo.isLiked, indexPath: indexPath) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .failure(let error):
                print("ERROR like photo: \(error.localizedDescription)")
                let errorMessage = error.localizedDescription.components(separatedBy: "(")[0]
                self.showLikeAlert(message: errorMessage)
            case .success():
                self.photos = self.imagesListService.photos
                cell.changeLikeButtonImage(changeToLike: !photo.isLiked)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}

extension ImagesListViewController: SingleImageViewControllerDelegate {
    func didLikeButtonTapped(singleImageViewController: SingleImageViewController) {
        guard let photoFromController = singleImageViewController.photo,
              let index = photos.firstIndex(where: { $0.id == photoFromController.id })
        else { return }
        let indexPath = IndexPath(row: index, section: 0)
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.toggleLike(photoID: photo.id, toLike: !photo.isLiked, indexPath: indexPath) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .failure(let error):
                print("ERROR like photo: \(error.localizedDescription)")
                let errorMessage = error.localizedDescription.components(separatedBy: "(")[0]
                self.showLikeAlertSingleImage(message: errorMessage, viewController: singleImageViewController)
            case .success():
                self.photos = self.imagesListService.photos
                singleImageViewController.changeLikeButtonImage(changeToLike: !photo.isLiked)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}

//Show alert
extension ImagesListViewController {
    private func showLikeAlert(message: String) {
        AlertPresenter.showAlert(
            viewController: self,
            title: "Что-то пошло не так :(",
            message: "Не удалось поставить/снять лайк\n\(message)",
            buttonTitle: nil,
            completion1: {},
            completion2: {}
        )
    }
    
    private func showLikeAlertSingleImage(message: String, viewController: SingleImageViewController) {
        AlertPresenter.showAlert(
            viewController: viewController,
            title: "Что-то пошло не так",
            message: "Не удалось поставить/снять лайк\n\(message)",
            buttonTitle: nil,
            completion1: {},
            completion2: {}
        )
    }
}
