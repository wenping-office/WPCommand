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
    func removeArrangedSubview(_ view: UIView) {
        base.removeArrangedSubview(view)
        view.removeFromSuperview()
        NSLayoutConstraint.deactivate(view.constraints)
        if let superview = view.superview {
            let relatedConstraints = superview.constraints.filter { constraint in
                return constraint.firstItem as? UIView == view || constraint.secondItem as? UIView == view
            }
            NSLayoutConstraint.deactivate(relatedConstraints)
        }
    }

    /// 移除所有视图并清除相关约束
    func removeAllArrangedSubviews() {
        let removedSubviews = base.arrangedSubviews.reduce([]) { (all, subview) -> [UIView] in
            base.removeArrangedSubview(subview)
            return all + [subview]
        }

        removedSubviews.forEach { subview in
            subview.removeFromSuperview()
            NSLayoutConstraint.deactivate(subview.constraints)
            if let superviewConstraints = subview.superview?.constraints {
                let relatedConstraints = superviewConstraints.filter { constraint in
                    return constraint.firstItem as? UIView == subview || constraint.secondItem as? UIView == subview
                }
                NSLayoutConstraint.deactivate(relatedConstraints)
            }
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
