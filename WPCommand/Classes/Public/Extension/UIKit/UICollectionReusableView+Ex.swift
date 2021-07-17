//
//  UICollectionReusableView+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UICollectionReusableView : WPCollectionReusableViewProtocol{
    
    /// 扩展一个即将获得group方法
    /// - Parameter model: 模型
    @objc public func didSetHeaderFooterModel(model: WPCollectionGroup) {}
}

fileprivate var WPCollectionGroupPointer = "WPCollectionGroupPointer"

/// group协议
public protocol WPCollectionReusableViewProtocol : NSObjectProtocol{

    /// 即将加载group
    /// - Parameter model: 模型
    func didSetHeaderFooterModel(model:WPCollectionGroup)
    
    /// group属性
    var group : WPCollectionGroup?{ get set}
}

public extension WPCollectionReusableViewProtocol{
    
    var group : WPCollectionGroup? {
        get{
            return objc_getAssociatedObject(self, &WPCollectionGroupPointer) as? WPCollectionGroup
        }
        set{
            objc_setAssociatedObject(self, &WPCollectionGroupPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


