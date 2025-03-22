//
//  SingleImageScrollView.swift
//  ImageFeed
//
//  Created by Matthew on 22.03.2025.
//

import UIKit

final class SingleImageScrollView: UIScrollView {
    
    private var imageView: UIImageView?
    private lazy var zoomTap: UITapGestureRecognizer = {
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomTap))
        zoomTap.numberOfTapsRequired = 2
        return zoomTap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.normal
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.centerImage()
    }
    
    //MARK: Public Functions
    func set(image: UIImage) {
        imageView?.removeFromSuperview()
        imageView = nil
        
        imageView = UIImageView(image: image)
        
        guard let imageView = imageView else { return }
        imageView.autoResizeOff()
        self.addSubview(imageView)
        
        configurateFor(imageSize: image.size)
    }
    
    private func configurateFor(imageSize: CGSize) {
        let window = UIApplication.shared.windows.first!

        self.contentSize = imageSize
        let boundsSize = window.bounds.size
        
        let x = abs((imageSize.width - boundsSize.width) / 2)
        let y = abs((imageSize.height - boundsSize.height) / 2)
    
        self.setContentOffset(CGPoint(x: x ,y: y), animated: true)
        
        setCurrentMaxAndMinZoomScale()
        self.imageView?.addGestureRecognizer(self.zoomTap)
        self.imageView?.isUserInteractionEnabled = true
    }
    
    private func setCurrentMaxAndMinZoomScale() {
        let boundsSize = self.bounds.size
        guard let imageSize = imageView?.bounds.size else { return }
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        var maxScale: CGFloat = 1.3
        
        if minScale < 0.1 {
            maxScale = 0.3
        } else if minScale >= 0.1 && minScale < 0.5 {
            maxScale = 0.7
        } else {
            maxScale = 1.3
        }
        
        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale
    }
    
    private func centerImage() {
        guard let imageView else { return }
        let boundsSize = self.bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }

        self.imageView?.frame = frameToCenter
    }
    
    //MARK: Gesture Tap
    private func zoom(point: CGPoint, animated: Bool) {
        let currentScale = self.zoomScale
        let minScale = self.minimumZoomScale
        let maxScale = self.maximumZoomScale
        
        if minScale == maxScale && minScale > 1.0 { return }
        
        let toScale = maxScale
        let finalScale = (currentScale == minScale) ? toScale : minScale
        let zoomRect = self.zoomRect(scale: finalScale, center: point)
        
        self.zoom(to: zoomRect, animated: animated)
    }
    
    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = self.bounds
        
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        
        return zoomRect
    }
    
    @objc private func handleZoomTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        self.zoom(point: location, animated: true)
    }
}

extension SingleImageScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
}

