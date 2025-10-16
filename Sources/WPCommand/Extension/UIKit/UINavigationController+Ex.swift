//
//  UINavigationController+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension WPSpace where Base: UINavigationController {
    /// 返回到栈里的某一个controller
    /// - Parameters:
    ///   - type: vc类型
    ///   - completion: 完成回调
    func pop<T: UIViewController>(to type: T.Type,
                                  animated:Bool = true,
                                  completion: ((T)->Void?)? = nil) {
        let targetControl = base.viewControllers.wp.elementFirst(where: { $0.isKind(of: type)})
        guard
            let control = targetControl
        else { return }
        base.popToViewController(control, animated: animated)
        completion?(control as! T)
    }
    
    /// 返回到上一个controller
    /// - Parameters:
    ///   - animated: 是否显示动画
    ///   - completion: 完成回调
    func pop(animated: Bool = true,
             completion: ((UIViewController)->Void?)? = nil) {
        if base.viewControllers.count <= 1 { return }
        if let viewController = base.viewControllers.wp.get(base.viewControllers.count - 2) {
            let pushCompletion: ()->Void = {
                completion?(viewController)
            }

            CATransaction.begin()
            CATransaction.setCompletionBlock(pushCompletion)
            base.popToViewController(viewController, animated: animated)
            CATransaction.commit()
        }
    }
    
    /// 返回到rootVC
    /// - Parameters:
    ///   - animated: 是否显示动画
    ///   - completion: 完成回调
    func popToRootViewController(animated: Bool = true,
                                 completion: ((UIViewController)->Void?)? = nil) {
        if let viewController = base.viewControllers.first {
            let pushCompletion: ()->Void = {
                completion?(viewController)
            }
            
            CATransaction.begin()
            CATransaction.setCompletionBlock(pushCompletion)
            base.popToViewController(viewController, animated: animated)
            CATransaction.commit()
        }
    }
    
    /// push到新的controller
    /// - Parameters:
    ///   - viewController: controller
    ///   - animated: 是否显示动画
    ///   - completion: 完成回调
    func push<T: UIViewController>(_ viewController: T,
                                   animated: Bool = true,
                                   completion: ((T)->Void)? = nil) {
        let pushCompletion: ()->Void = {
            completion?(viewController)
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock(pushCompletion)
        base.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}
