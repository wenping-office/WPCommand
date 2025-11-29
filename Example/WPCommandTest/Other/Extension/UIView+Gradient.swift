//
//  UIView+Gradient.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/24.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import ObjectiveC

// MARK: - Associated Keys
private var gradientLayerKey: UInt8 = 0
private var borderGradientLayerKey: UInt8 = 0
private var boundsObserverKey: UInt8 = 0

// MARK: - KVO Observer
private class BoundsObserver: NSObject {
    weak var view: UIView?
    let callback: () -> Void

    init(view: UIView, callback: @escaping () -> Void) {
        self.view = view
        self.callback = callback
        super.init()
        view.addObserver(self, forKeyPath: "bounds", options: [.new], context: nil)
    }

    deinit {
        view?.removeObserver(self, forKeyPath: "bounds")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        callback()
    }
}

extension UIView {

    // MARK: - Public API

    /// 渐变背景
    func setGradientBackground(colors: [UIColor],
                               start: CGPoint = CGPoint(x: 0, y: 0.5),
                               end: CGPoint = CGPoint(x: 1, y: 0.5),
                               cornerRadius: CGFloat? = nil) {

        enableBoundsObserver()

        let gradientLayer = getOrCreateLayer(key: &gradientLayerKey)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end

        if let radius = cornerRadius {
            gradientLayer.cornerRadius = radius
        } else {
            gradientLayer.cornerRadius = layer.cornerRadius
        }

        updateGradientFrames()
    }

    /// 渐变边框
    func setGradientBorder(colors: [UIColor],
                           borderWidth: CGFloat,
                           start: CGPoint = CGPoint(x: 0, y: 0.5),
                           end: CGPoint = CGPoint(x: 1, y: 0.5),
                           cornerRadius: CGFloat? = nil) {

        enableBoundsObserver()

        let borderLayer = getOrCreateLayer(key: &borderGradientLayerKey)
        borderLayer.colors = colors.map { $0.cgColor }
        borderLayer.startPoint = start
        borderLayer.endPoint = end

        // Mask shape
        let mask = CAShapeLayer()
        mask.lineWidth = borderWidth
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.black.cgColor
        borderLayer.mask = mask

        if let radius = cornerRadius {
            layer.cornerRadius = radius
        }

        updateGradientFrames()
    }

    // MARK: - Internal

    private func enableBoundsObserver() {
        guard objc_getAssociatedObject(self, &boundsObserverKey) == nil else { return }

        let observer = BoundsObserver(view: self) { [weak self] in
            self?.updateGradientFrames()
        }
        objc_setAssociatedObject(self, &boundsObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func getOrCreateLayer(key: UnsafeRawPointer) -> CAGradientLayer {
        if let layer = objc_getAssociatedObject(self, key) as? CAGradientLayer {
            return layer
        }
        let layer = CAGradientLayer()
        self.layer.insertSublayer(layer, at: 0)
        objc_setAssociatedObject(self, key, layer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return layer
    }

    private func updateGradientFrames() {
        let radius = layer.cornerRadius

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if let bgLayer = objc_getAssociatedObject(self, &gradientLayerKey) as? CAGradientLayer {
            bgLayer.frame = bounds
            bgLayer.cornerRadius = radius
        }

        if let borderLayer = objc_getAssociatedObject(self, &borderGradientLayerKey) as? CAGradientLayer,
           let maskLayer = borderLayer.mask as? CAShapeLayer {

            borderLayer.frame = bounds
            let width = maskLayer.lineWidth

            let insetRect = bounds.insetBy(dx: width / 2, dy: width / 2)
            maskLayer.path = UIBezierPath(roundedRect: insetRect,
                                          cornerRadius: max(0, radius - width / 2)).cgPath
            maskLayer.frame = bounds
        }
        CATransaction.commit()
    }
}

