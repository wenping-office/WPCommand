//
//  WPTableHeaderFooterViewlProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

private var WPTableGroupPointer = "WPTableGroupPointer"

public protocol WPTableHeaderFooterViewlProtocol: NSObjectProtocol, UITableViewHeaderFooterView {
    /// 加载模型时调用
    /// - Parameter group: group模型
    func reloadGroup(group: WPTableGroup)

    /// group模型
    var group: WPTableGroup? { get set }
}

public extension WPTableHeaderFooterViewlProtocol {
    var group: WPTableGroup? {
        get {
            return WPRunTime.get(self, withUnsafePointer(to: &WPTableGroupPointer, {$0}))
        }
        set {
            return WPRunTime.set(self, newValue, withUnsafePointer(to: &WPTableGroupPointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
