//
//  BaseNavVC.swift
//  ShoppingCommon
//
//  Created by Wen on 2023/8/22.
//

import WPCommand

open class BaseNavVC: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count >= 1{
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
