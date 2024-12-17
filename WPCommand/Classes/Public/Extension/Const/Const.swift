//
//  Const.swift
//  Alamofire
//
//  Created by Wen on 2024/1/16.
//

import UIKit

/// 输入模式
public enum InputMode {
    /// 过滤模式 过滤当前的关键字
    case filter(keys: [String] = [])
    /// 输入模式 只能输入当前的关键字
    case input(keys: [String] = [])
}

public extension UIEdgeInsets {
    init(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }

    init(_ value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    init(_ top: CGFloat, _ bottom: CGFloat) {
        self.init(top: top, left: 0, bottom: bottom, right: 0)
    }
    
    var horizontal: CGFloat {
        return self.left + self.right
    }
    
    var vertical: CGFloat {
        return self.top + self.bottom
    }
}

public extension CGSize {
    init(_ width: CGFloat, _ height: CGFloat) {
        self.init(width: width, height: height)
    }
}

public extension CGPoint {
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }
}

public extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init(x: x, y: y, width: width, height: height)
    }

    init(_ origin: CGPoint, _ size: CGSize) {
        self.init(origin: origin, size: size)
    }
}

public extension NSRange {
    init(_ location: Int, _ length: Int) {
        self.init(location: location, length: length)
    }
}
