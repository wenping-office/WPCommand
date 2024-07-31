//
//  UIViewController+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

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
        return rootVC(vc: UIApplication.wp.mainWindow?.rootViewController)
    }
}
 
// 扩展 UIViewController 添加生命周期的 Rx 支持
public extension WPSpace where Base: UIViewController {
    
    /// 当 viewDidLoad 被调用时发出信号
    var viewDidLoad: ControlEvent<Void> {
        let source = base.rx.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    /// 当 viewWillAppear 被调用时发出信号
    var viewWillAppear: ControlEvent<Bool> {
        let source = base.rx.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    /// 当 viewDidAppear 被调用时发出信号
    var viewDidAppear: ControlEvent<Bool> {
        let source = base.rx.methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    /// 当 viewWillDisappear 被调用时发出信号
    var viewWillDisappear: ControlEvent<Bool> {
        let source = base.rx.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    /// 当 viewDidDisappear 被调用时发出信号
    var viewDidDisappear: ControlEvent<Bool> {
        let source = base.rx.methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    /// 当 viewWillLayoutSubviews 被调用时发出信号
    var viewWillLayoutSubviews: ControlEvent<Void> {
        let source = base.rx.methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }
    
    /// 当 viewDidLayoutSubviews 被调用时发出信号
    var viewDidLayoutSubviews: ControlEvent<Void> {
        let source = base.rx.methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }
}

