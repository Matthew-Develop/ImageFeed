//
//  ViewController.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/23/25.
//

import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    func reloadTableRow(indexPath: IndexPath)
    func insertTableRows(indexPathArray: [IndexPath])
    func getIndexPath(from cell: ImagesListCell) -> IndexPath?
    var presenter: ImagesListViewPresenterProtocol? { get set }
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    //MARK: View
    private var tableView = UITableView()
    
    // MARK: Public Properties
    var presenter: ImagesListViewPresenterProtocol?
    
    // MARK: Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        setupView()
        
        NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.presenter?.updateTableViewAnimated()
            }
    }
    
    //MARK: Public Functions
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.displayPhotos(indexPath: indexPath)
    }
    
    func reloadTableRow(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func insertTableRows(indexPathArray: [IndexPath]) {
        tableView.performBatchUpdates {
            self.tableView.insertRows(
                at: indexPathArray,
                with: .automatic)
        } completion: { _ in }
    }
    
    func getIndexPath(from cell: ImagesListCell) -> IndexPath? {
        tableView.indexPath(for: cell)
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
        guard let presenter = presenter else {
            print("ImagesListViewPresenter not created")
            return 0
        }
        return presenter.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        presenter?.configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let singleImageViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "SingleImageViewController") as? SingleImageViewController else { return }
        
        let photo = presenter?.photos[indexPath.row]
        singleImageViewController.delegate = self
        singleImageViewController.photo = photo
        
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photos[indexPath.row]
        else {
            return 200
        }
        let width = photo.size.width
        let height = photo.size.height
        
        let imageViewWidth = tableView.bounds.width - 2*16
        let imageViewHeight = (imageViewWidth / width) * height
        
        let dynamicCellHeight = imageViewHeight + 4*2
        
        return dynamicCellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func didTapLikeButtonTableView(cell: ImagesListCell) {
        presenter?.didTapLikeButtonTableView(cell: cell, view: self)
    }
}

extension ImagesListViewController: SingleImageViewControllerDelegate {
    func didTapLikeButtonSingleImageView(singleImageViewController: SingleImageViewController) {
        presenter?.didTapLikeButtonSingleImageView(singleImageViewController)
    }
}
