//
//  GradientRingView.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/24.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

/// 渐变loading
class GradientRingView: UIView {

    // MARK: - 可自定义属性
    var gradientColors: [UIColor] = [UIColor.systemPink, UIColor.purple] {
        didSet { updateGradientColors() }
    }

    var lineWidth: CGFloat = 4 {
        didSet { shapeLayer.lineWidth = lineWidth; setNeedsLayout() }
    }

    // MARK: - 私有属性
    private let shapeLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private let rotationKey = "rotationAnimation"

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0.3 // 留一个缺口，更有动感

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        updateGradientColors()

        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)

        startRotating()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds

        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: -.pi / 2,
                                endAngle: 1.5 * .pi,
                                clockwise: true)
        shapeLayer.path = path.cgPath
    }

    // MARK: - 渐变更新
    private func updateGradientColors() {
        gradientLayer.colors = gradientColors.map { $0.cgColor }
    }

    // MARK: - 动画
    private func startRotating() {
        if layer.animation(forKey: rotationKey) != nil { return }

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1.2
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(animation, forKey: rotationKey)
    }

    func stopRotating() {
        layer.removeAnimation(forKey: rotationKey)
    }
}



