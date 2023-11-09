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
