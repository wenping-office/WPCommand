//
//  UIStackView+EX.swift
//  WPCommand
//
//  Created by Wen on 2023/10/25.
//

import UIKit

public extension WPSpace where Base: UIStackView{
    
    /// 移除一个视图
    /// - Parameter view: 视图
    func remove(_ view: UIView) {
        base.removeArrangedSubview(view)
        view.removeFromSuperview()
    }

    /// 移除所有视图
    func removeAllSubView() {
        base.arrangedSubviews.forEach { (view) in
            remove(view)
        }
    }
}

public extension WPSpace where Base: UIStackView{
    
    static func views(_ arrangedSubviews:[UIView]) -> Self {
        return WPSpace(Base(arrangedSubviews: arrangedSubviews))
    }
    
    @discardableResult
    func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        base.axis = axis
        return self
    }
    
    @discardableResult
    func distribution(_ distribution:UIStackView.Distribution) -> Self {
        base.distribution = distribution
        return self
    }
    
    @discardableResult
    func alignment(_ alignment:UIStackView.Alignment) -> Self {
        base.alignment = alignment
        return self
    }
    
    @discardableResult
    func spacing(_ spacing:CGFloat) -> Self {
        base.spacing = spacing
        return self
    }
    
    @discardableResult
    func isBaselineRelativeArrangement(_ isBaselineRelativeArrangement:Bool) -> Self {
        base.isBaselineRelativeArrangement = isBaselineRelativeArrangement
        return self
    }
    
    @discardableResult
    func isLayoutMarginsRelativeArrangement(_ isLayoutMarginsRelativeArrangement:Bool) -> Self {
        base.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
        return self
    }

}
