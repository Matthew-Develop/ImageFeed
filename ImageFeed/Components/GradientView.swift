//
//  GradientView.swift
//  ImageFeed
//
//  Created by Матвей Сюзев on 1/28/25.
//

import UIKit

final class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let firstColor = UIColor.ypBlack.withAlphaComponent(0.025).cgColor
    private let secondColor = UIColor.ypBlack.withAlphaComponent(1).cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGradient(firstColor, secondColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGradient(firstColor, secondColor)
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
