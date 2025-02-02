//
//  ViewController.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/23/25.
//

import UIKit

class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.setLocalizedDateFormatFromTemplate("dMMMMyyy")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName: String = photosName[indexPath.row]
        
        guard let image = UIImage(named: imageName) else { return }
        cell.imageCell.image = image
        
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        indexPath.row % 2 == 0 ? cell.likeButton.setImage(UIImage(named: "like_active"), for: .normal) : cell.likeButton.setImage(UIImage(named: "like_no_active"), for: .normal)
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
