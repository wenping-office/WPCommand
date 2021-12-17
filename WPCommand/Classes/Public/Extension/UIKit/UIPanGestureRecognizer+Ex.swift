//
//  UIPanGestureRecognizer+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/12/16.
//

import UIKit
public extension UIPanGestureRecognizer{
    /// 滑动方向
    enum ScrollDirection {
        /// 左边滑动
        case left
        /// 右边滑动
        case right
        /// 上拉滑动
        case top
        /// 下拉滑动
        case bottom
        /// 未知
        case unknown
    }
}

public extension WPSpace where Base: UIPanGestureRecognizer{
    
    /// 滑动方向
    var direction : Base.ScrollDirection{

        let point = base.velocity(in: base.view)

        let absX : CGFloat = abs(point.x)
        let absY : CGFloat = abs(point.y)

        if absX > absY {
            if point.x < 0{
                return .left
            }else{
                return .right
            }
        }else if absY > absX{
            if point.y < 0{
                return .top
            }else{
                return .bottom
            }
        }
        
        return .unknown
    }
    
}
