//
//  CAShapeLayer+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/10/22.
//

import QuartzCore
import UIKit

public extension WPSpace where Base: CAShapeLayer {
    /// 返回一个选择性缕空圆角layer 注：layer的fillColor需要填充
    /// - Parameters:
    ///   - corners: 圆角类型
    ///   - radius: 圆角
    ///   - rect: 矩形
    /// - Returns: layer
    static func shapefillet(_ corners: [UIRectCorner], radius: CGFloat, in rect: CGRect) -> CAShapeLayer {
        let defaultPath = UIBezierPath(rect: rect)
        let cornersPath = UIBezierPath.wp.corner(corners, radius: radius, in: rect)
        defaultPath.append(cornersPath)
        let layer = CAShapeLayer()
        layer.path = defaultPath.cgPath
        layer.fillRule = .evenOdd
        return layer
    }
}
