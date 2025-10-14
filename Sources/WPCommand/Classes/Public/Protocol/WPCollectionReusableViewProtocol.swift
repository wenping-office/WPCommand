//
//  WPCollectionReusableViewProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

private var WPCollectionGroupPointer = "WPCollectionGroupPointer"

/// group协议
protocol WPCollectionReusableViewProtocol: NSObjectProtocol, UICollectionReusableView {
    /// 即将加载group
    /// - Parameter model: 模型
    func didSetHeaderFooterModel(model: WPCollectionGroup)

    /// group模型
    var group: WPCollectionGroup? { get set }
}

extension WPCollectionReusableViewProtocol {
    var group: WPCollectionGroup? {
        get {
            return WPRunTime.get(self, withUnsafePointer(to: &WPCollectionGroupPointer, {$0}))
        }
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &WPCollectionGroupPointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
