//
//  WPMenuViewINavigationProtol.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/13.
//

import UIKit

public protocol WPMenuNavigationViewProtocol: WPMenuViewChildViewProtocol, UIView {
    /// 每一个菜单item的width
    func menuItemWidth() -> CGFloat
}

