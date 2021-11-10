//
//  UIViewController+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension UIViewController {
    /// 显示一个controller 可以重写
    /// - Parameters:
    ///   - viewController: 根controllr
    ///   - info: 信息
    @objc class func show(in viewController: UIViewController,
                          info: Any? = nil,
                          completion: ((UIViewController) -> Void)? = nil)
    {
        viewController.navigationController?.wp.pushViewController(self.init(), completion: completion)
    }

    /// 弹出一个controller
    /// - Parameters:
    ///   - viewControl: 根Controller
    ///   - style: 样式
    ///   - info: 信息
    ///   - completion: 完成回调
    class func present(in viewControl: UIViewController?,
                       style: UIModalPresentationStyle = .fullScreen,
                       info: Any? = nil,
                       completion: (() -> Void)? = nil)
    {
        let control = self.init()
        control.modalPresentationStyle = style
        viewControl?.present(control, animated: true, completion: completion)
    }
}
