//
//  WPCollectionCellProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

var WPCollectionItemPointer = "WPCollectionItemPointer"

public protocol WPCollectionCellProtocol: NSObjectProtocol, UICollectionViewCell {}

public extension WPCollectionCellProtocol {
    var item: WPCollectionItem? {
        get {
            return WPRunTime.get(self, withUnsafePointer(to: &WPCollectionItemPointer, {$0}))
        }
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &WPCollectionItemPointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UICollectionViewCell: WPCollectionCellProtocol {
    /// 加载itemInfo时调用
    /// - Parameter info: 附件
    @objc open func reloadItemInfo(info: Any?) {}
}
