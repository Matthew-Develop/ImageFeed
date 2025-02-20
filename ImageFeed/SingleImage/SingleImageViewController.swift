//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 2/2/25.
//

import UIKit

class SingleImageViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private var singleImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Public Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded,
                  let image = image else { return }
            singleImageView.image = image
            singleImageView.frame.size = image.size
            
            changeScaleAndCenterImage(image: image)
        }
    }

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image = image else { return }
        singleImageView.image = image
        singleImageView.frame.size = image.size
        
        changeScaleAndCenterImage(image: image)
        
        scrollView.minimumZoomScale = 0.3
        scrollView.maximumZoomScale = 1.3
    }
    
    // MARK: - IB Actions
    @IBAction private func didTapSingleBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = image else { return }
        let items: [Any] = [image,"Изображение"]
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        
        present(activity, animated: true, completion: nil)
    }

    // MARK: - Private Methods
    private func changeScaleAndCenterImage(image: UIImage) {
        let minZoom = scrollView.minimumZoomScale
        let maxZoom = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        
        let imageSize = image.size
        let rectSize = scrollView.bounds.size
        
        if rectSize.width == 0 || rectSize.height == 0 {
            return
        }
        
        let hScale = rectSize.width / imageSize.width
        let vScale = rectSize.height / imageSize.height
        
        let theoreticalScale = min(hScale, vScale)
        let scale = min(maxZoom, max(minZoom, theoreticalScale))
        
        scrollView.setZoomScale(scale, animated: false)
        
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        
        let x = (newContentSize.width - rectSize.width) / 2
        let y = (newContentSize.height - rectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        
        updateInset()
    }
    
    private func updateInset() {
        let rectSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
                
        let vInset = max((rectSize.height - contentSize.height) / 2, 0)
        let hInset = max((rectSize.width - contentSize.width) / 2, 0)
                
        scrollView.contentInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return singleImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateInset()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        updateInset()
    }
}
