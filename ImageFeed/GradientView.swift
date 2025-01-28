//
//  GradientView.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/28/25.
//

import UIKit

class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let firstColor = UIColor.ypBlack.cgColor.copy(alpha: 0.025)
    private let secondColor = UIColor.ypBlack.cgColor.copy(alpha: 1)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGradient(firstColor, secondColor)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func addGradient(_ first: CGColor?,_ second: CGColor?) {
        self.layer.addSublayer(gradientLayer)
        guard let first = first,
              let second = second else { return }
        gradientLayer.colors = [first, second]
    }
}
