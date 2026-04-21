//
//  ShimmerView.swift
//  Snabum
//
//  Created by mac on 16/01/2026.
//

import UIKit

final class ShimmerView: UIView {

    private var gradientLayer: CAGradientLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShimmer()
    }

    private func setupShimmer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.lightGray.withAlphaComponent(0.3).cgColor,
            UIColor.lightGray.withAlphaComponent(0.1).cgColor,
            UIColor.lightGray.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func startShimmer() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.2
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }

    func stopShimmer() {
        gradientLayer.removeAnimation(forKey: "shimmerAnimation")
    }
}
