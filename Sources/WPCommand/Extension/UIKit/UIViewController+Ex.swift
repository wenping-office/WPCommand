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
                          animated : Bool = true,
                          info: Any? = nil,
                          completion: ((UIViewController) -> Void)? = nil)
    {
        viewController.navigationController?.wp.push(self.init(), animated: animated, completion: completion)
    }

    /// 弹出一个controller
    /// - Parameters:
    ///   - viewControl: 根Controller
    ///   - style: 样式
    ///   - info: 信息
    ///   - completion: 完成回调
    class func present(in viewControl: UIViewController?,
                       style: UIModalPresentationStyle = .fullScreen,
                       animated : Bool = true,
                       info: Any? = nil,
                       completion: (() -> Void)? = nil)
    {
        let control = self.init()
        control.modalPresentationStyle = style
        viewControl?.present(control, animated: animated, completion: completion)
    }
}


public extension WPSpace where Base: UIViewController {
    /// 当前显示的VC
   static var current: UIViewController? {
        func rootVC(vc: UIViewController?) -> UIViewController? {
            if let presentedVC = vc?.presentedViewController { return rootVC(vc: presentedVC) }

            if let tabBarVC = vc as? UITabBarController,
               let selectedVC = tabBarVC.selectedViewController {
                return rootVC(vc: selectedVC)
            }
            if let navigationVC = vc as? UINavigationController,
               let visibleVC = navigationVC.visibleViewController {
                return rootVC(vc: visibleVC)
            }
            if let pageVC = vc as? UIPageViewController,
               pageVC.viewControllers?.count == 1 {
                return rootVC(vc: pageVC.viewControllers?.first)
            }

            for elmt in vc?.view?.subviews ?? [] {
                if let childViewController = elmt.next as? UIViewController {
                    return rootVC(vc: childViewController)
                }
            }
            weak var weakVC = vc
            return  weakVC
        }
        return rootVC(vc: UIApplication.wp.keyWindow?.rootViewController)
    }
}

