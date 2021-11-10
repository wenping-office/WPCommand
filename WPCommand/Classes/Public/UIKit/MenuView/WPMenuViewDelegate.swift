//
//  WPMenuViewDelegate.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/14.
//

import UIKit

public protocol WPMenuViewDelegate: NSObjectProtocol {
    /// 选中一个索引后调用
    /// - Parameter index: 索引
    func menuViewDidSelected(index: Int)
}

public extension WPMenuViewDelegate {
    /// 选中一个索引后调用
    /// - Parameter index: 索引
    func menuViewDidSelected(index: Int) {}
}
