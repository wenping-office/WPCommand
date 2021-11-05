//
//  NSObject+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/28.
//

import UIKit
import RxSwift

fileprivate var wp_disposeBagPointer = "wp_disposeBag"

public extension NSObject {

    /// 懒加载垃圾桶
    var wp_disposeBag: DisposeBag {
        set {
            WPRunTime.set(self, newValue, &wp_disposeBagPointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let disposeBag: DisposeBag =  WPRunTime.get(self, &wp_disposeBagPointer) else {
                let bag = DisposeBag()
                self.wp_disposeBag = bag
                return bag
            }
            return disposeBag
        }
    }
}

public extension WPSpace where Base : NSObject{
    
    /// 懒加载垃圾袋
    var disposeBag : DisposeBag{
        set{
            base.wp_disposeBag = newValue
        }
        get{
            return base.wp_disposeBag
        }
    }
    
    /// 当前keyWindow
    var keyWindow : UIWindow?{
        return UIApplication.shared.windows.wp_elmt { elmt in
            return elmt.windowLevel == .normal
        }
    }
    
    /// 当前KeyController
    var keyController : UIViewController?{
        func getRootVC(_ rootVc:UIViewController?)->UIViewController? {
         
            if let presentedVC = rootVc?.presentedViewController {
                return getRootVC(presentedVC)
            }
            if let tabBarVC = rootVc as? UITabBarController,
               let selectedVC = tabBarVC.selectedViewController {
                return getRootVC(selectedVC)
            }
            if let navigationVC = rootVc as? UINavigationController,
               let visibleVC = navigationVC.visibleViewController {
                return getRootVC(visibleVC)
            }
            if let pageVC = rootVc as? UIPageViewController,
                pageVC.viewControllers?.count == 1 {
                return getRootVC(pageVC.viewControllers?.first)
            }

            for subview in rootVc?.view?.subviews ?? [] {
                return getRootVC(subview.next as? UIViewController)
            }
            return rootVc
        }
        return getRootVC(keyWindow?.rootViewController)
    }
}
