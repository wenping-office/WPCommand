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
    /// - Parameter type: control的类型
    func wp_popToStackViewController<T:UIViewController>(type:T.Type,complete:((T)->Void?)?=nil){
        var targetControl : UIViewController?
        viewControllers.forEach { elmt in
            if elmt.self as? T != nil{
                targetControl = elmt
            }
        }
        guard
            let control = targetControl
        else { return }
        popToViewController(control, animated: true)
        complete != nil ? complete!(control as! T) : print("")
    }
    
    /// push到新的controller
    /// - Parameters:
    ///   - viewController: controller
    ///   - completion: 完成回调
    func wp_pushViewController<T:UIViewController>(viewController: T, completion: ((T) -> Void)? = nil) {
        let pushCompletion = {
            completion != nil ? completion!(viewController) : print()
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock(pushCompletion)
        pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
    
}
