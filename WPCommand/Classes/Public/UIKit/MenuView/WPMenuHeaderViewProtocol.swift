//
//  WPMenuHeaderViewProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/22.
//

import UIKit

public protocol WPMenuHeaderViewProtocol: WPMenuViewChildViewProtocol {
    /// 需要展示的视图
    func menuHeaderView() -> UIView?

    /// 返回header的高度 默认是autoLayout自动布局高度
    func menuHeaderViewAtHeight() -> WPMenuView.HeaderHeightOption
}

public extension WPMenuHeaderViewProtocol {
    func menuHeaderViewAtHeight() -> WPMenuView.HeaderHeightOption { return .autoLayout }

    /// 子视图状态更新
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus) {}
}
