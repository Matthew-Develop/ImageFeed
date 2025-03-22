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
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.setLocalizedDateFormatFromTemplate("dMMMMyyy")
        return formatter
    }()
    
    // MARK: Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    //MARK: Private Methods
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
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName: String = photosName[indexPath.row]
        
        guard let image = UIImage(named: imageName) else { return }
        cell.setImage(image: image)
        
        cell.setDate(dateString: dateFormatter.string(from: Date()).replacingOccurrences(of: "г.", with: ""))
        
        guard let buttonImage = indexPath.row % 2 == 0 ? UIImage(named: "like_active") : UIImage(named: "like_no_active") else { return }
        cell.setLikeButton(image: buttonImage)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let singleImageViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "SingleImageViewController") as? SingleImageViewController else { return }
        
        let image = UIImage(named: photosName[indexPath.row])
        singleImageViewController.image = image
        
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = UIImage(named: photosName[indexPath.row])
        guard let image = image else { return 200 }
        
        let imageViewWidth = tableView.bounds.width - 2*16
        let imageViewHeight = (imageViewWidth / image.size.width) * image.size.height
        
        let dynamicCellHeight = imageViewHeight + 4*2
        
        return dynamicCellHeight
    }
}
