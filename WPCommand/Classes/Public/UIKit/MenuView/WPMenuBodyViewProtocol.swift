//
//  WPMenuBodyViewProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/18.
//

import UIKit

public protocol WPMenuBodyViewProtocol: WPMenuViewChildViewProtocol {
    /// 需要展示的视图
    func menuBodyView() -> UIView?
}

public extension WPMenuBodyViewProtocol {
    /// 子视图状态更新
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus) {}
}
