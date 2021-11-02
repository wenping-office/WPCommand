//
//  UINavigationController+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension WPSpace where Base : UINavigationController{
    
    /// 返回到栈里的某一个controller
    /// - Parameters:
    ///   - type: vc类型
    ///   - completion: 完成回调
    func popToViewController<T:UIViewController>(_ type:T.Type,completion:((T)->Void?)?=nil){
        let targetControl = base.viewControllers.wp_elmt(of: { elmt in
            return elmt.isKind(of: type)
        })
        guard
            let control = targetControl
        else { return }
        base.popToViewController(control, animated: true)
        completion?(control as! T)
    }
    
    /// 返回到上一个controller
    /// - Parameters:
    ///   - animated: 是否显示动画
    ///   - completion: 完成回调
    func popViewController(animated:Bool = true,completion:((UIViewController)->Void?)?=nil){
        if base.viewControllers.count <= 1 { return }
        if let viewController = base.viewControllers.wp_get(of: base.viewControllers.count - 2){
            let pushCompletion : ()->Void = {
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
    func popToRootViewController(animated:Bool = true,completion:((UIViewController)->Void?)?=nil){
        if let viewController = base.viewControllers.first{
            let pushCompletion : ()->Void = {
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
    ///   - completion: 完成回调
    func pushViewController<T:UIViewController>(_ viewController: T, completion: ((T) -> Void)? = nil) {
        let pushCompletion : ()->Void = {
            completion?(viewController)
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock(pushCompletion)
        base.pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
    
}
