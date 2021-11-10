//
//  UIApplication+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/28.
//

import UIKit

public extension WPSpace where Base: UIApplication {
    /// 当前最上面的window
    var topWindow: UIWindow {
        guard let window = UIApplication.shared.windows.reversed().filter({ $0.windowLevel == UIWindow.Level.normal }).first else {
            return UIWindow()
        }
        return window
    }

    /// 当前最上层window
    static var topWindow: UIWindow {
        guard let window = UIApplication.shared.windows.reversed().filter({ $0.windowLevel == UIWindow.Level.normal }).first else {
            return UIWindow()
        }
        return window
    }
}
