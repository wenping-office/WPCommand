//
//  WPMenuViewINavigationProtol.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/13.
//

import UIKit


public protocol WPMenuViewNavigationProtocol:UIView {
    /// 状态更新以后回调用
    func upledeStatus(status:WPMenuView.NavigationStatus)
}

public extension WPMenuViewNavigationProtocol{
    /// 状态更新以后回调用
    func upledeStatus(status:WPMenuView.NavigationStatus){}
}
