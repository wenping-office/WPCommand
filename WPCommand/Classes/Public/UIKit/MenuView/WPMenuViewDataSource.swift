//
//  WPMenuViewDataSource.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/14.
//

import UIKit

public protocol WPMenuViewDataSource: NSObjectProtocol {
    /// 当前索引返回的视图
    /// - Parameter index: 索引
    func menuBodyViewForIndex(index: Int) -> WPMenuBodyViewProtocol

    /// 返回当前页面的headerView
    /// - Parameter index: 索引
    func menuHeaderViewForIndex(index: Int) -> WPMenuHeaderViewProtocol?
}

public extension WPMenuViewDataSource {
    func menuHeaderViewForIndex(index: Int) -> WPMenuHeaderViewProtocol? { return nil }
}
