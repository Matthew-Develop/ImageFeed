//
//  GradientView.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/28/25.
//

import UIKit

final class GradientView: UIView {
    var alpha1: Float = 0.01
    var alpha2: Float = 0.5
    
    private let gradientLayer = CAGradientLayer()
    private let firstColor = UIColor.ypBlack.withAlphaComponent(0.01).cgColor
    private let secondColor = UIColor.ypBlack.withAlphaComponent(0.5).cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGradient(firstColor, secondColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGradient(firstColor, secondColor)
    }
    
    init(alpha1: Float = 0.01, alpha2: Float = 0.5) {
        super.init(frame: .zero)
        self.alpha1 = alpha1
        self.alpha2 = alpha2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func addGradient(_ first: CGColor?,_ second: CGColor?) {
        self.layer.addSublayer(gradientLayer)
        guard let first = first,
              let second = second else { return }
        gradientLayer.colors = [first, second]
    }
}
