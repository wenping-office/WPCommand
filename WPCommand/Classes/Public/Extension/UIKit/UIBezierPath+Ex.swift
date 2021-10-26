//
//  UIBezierPath+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/10/22.
//

import UIKit


public extension UIBezierPath {
    
    
    /// 获取一个选择性圆角Path
    /// - Parameters:
    ///   - corners: 圆角方向
    ///   - radius: 圆角
    ///   - rect: 矩形
    /// - Returns: path路径
    static func wp_corner(_ corners: [UIRectCorner], radius: CGFloat,in rect:CGRect)->UIBezierPath{
        var value : UInt = 0
        corners.forEach { elmt in
            value += elmt.rawValue
        }
        return UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner(rawValue: value), cornerRadii: CGSize(width: radius, height: radius))
    }
}
