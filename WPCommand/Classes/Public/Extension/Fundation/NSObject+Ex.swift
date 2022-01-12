//
//  NSObject+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/28.
//

import RxSwift
import UIKit

private var wp_disposeBagPointer = "wp_disposeBag"

public extension NSObject {
    /// 懒加载垃圾桶
    var wp_disposeBag: DisposeBag {
        set {
            WPRunTime.set(self, newValue, &wp_disposeBagPointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let disposeBag: DisposeBag = WPRunTime.get(self, &wp_disposeBagPointer) else {
                let bag = DisposeBag()
                self.wp_disposeBag = bag
                return bag
            }
            return disposeBag
        }
    }
}

public extension WPSpace where Base: NSObject {
    /// 懒加载垃圾袋
    var disposeBag: DisposeBag {
        set {
            base.wp_disposeBag = newValue
        }
        get {
            return base.wp_disposeBag
        }
    }

    /// 当前keyWindow
    static var keyWindow : UIWindow? {
        return NSObject.wp.keyWindow
    }

    /// 当前KeyController
    static var keyController: UIViewController? {
        return NSObject().wp.keyController
    }

    /// 当前keyWindow
    var keyWindow: UIWindow? {
        return UIApplication.shared.windows.wp_elmt { elmt in
            elmt.windowLevel == .normal
        }
    }

    /// 当前KeyController
    var keyController: UIViewController? {
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
            return vc
        }
        return rootVC(vc: keyWindow?.rootViewController)
    }
}
