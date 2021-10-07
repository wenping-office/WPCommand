//
//  UINavigationController+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension UINavigationController{
    
    /// 返回到栈里的某一个controller
    /// - Parameters:
    ///   - type: vc类型
    ///   - completion: 完成回调
    func wp_popToViewController<T:UIViewController>(type:T.Type,completion:((T)->Void?)?=nil){
        let targetControl = viewControllers.wp_elmt(by: { elmt in
            return elmt.isKind(of: type)
        })
        guard
            let control = targetControl
        else { return }
        popToViewController(control, animated: true)
        completion?(control as! T)
    }
    
    /// 返回到上一个controller
    /// - Parameters:
    ///   - animated: 是否显示动画
    ///   - completion: 完成回调
    func wp_popViewController(animated:Bool = true,completion:((UIViewController)->Void?)?=nil){
        if viewControllers.count <= 1 { return }
        if let viewController = viewControllers.wp_safeGet(of: viewControllers.count - 1){
            let pushCompletion : ()->Void = {
                completion?(viewController)
            }
            
            CATransaction.begin()
            CATransaction.setCompletionBlock(pushCompletion)
            popToViewController(viewController, animated: animated)
            CATransaction.commit()
        }
    }
    
    /// 返回到rootVC
    /// - Parameters:
    ///   - animated: 是否显示动画
    ///   - completion: 完成回调
    func wp_popToRootViewController(animated:Bool = true,completion:((UIViewController)->Void?)?=nil){
        if let viewController = viewControllers.first{
            let pushCompletion : ()->Void = {
                completion?(viewController)
            }
            
            CATransaction.begin()
            CATransaction.setCompletionBlock(pushCompletion)
            popToViewController(viewController, animated: animated)
            CATransaction.commit()
        }
    }
    
    /// push到新的controller
    /// - Parameters:
    ///   - viewController: controller
    ///   - completion: 完成回调
    func wp_pushViewController<T:UIViewController>(viewController: T, completion: ((T) -> Void)? = nil) {
        let pushCompletion : ()->Void = {
            completion?(viewController)
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock(pushCompletion)
        pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
    
}
