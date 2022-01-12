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
    
    /// 滚动百分比
    func willRolling(with percentage:CGFloat)

}

public extension WPMenuNavigationViewProtocol{
    
    func willRolling(with percentage:CGFloat){}
}
