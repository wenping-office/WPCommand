//
//  WPCollectionReusableViewProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

fileprivate var WPCollectionGroupPointer = "WPCollectionGroupPointer"

/// group协议
protocol WPCollectionReusableViewProtocol : NSObjectProtocol{

    /// 即将加载group
    /// - Parameter model: 模型
    func didSetHeaderFooterModel(model:WPCollectionGroup)
    
    /// group模型
    var group : WPCollectionGroup?{ get set}
}

extension WPCollectionReusableViewProtocol{
    
    var group : WPCollectionGroup? {
        get{
            return objc_getAssociatedObject(self, &WPCollectionGroupPointer) as? WPCollectionGroup
        }
        set{
            objc_setAssociatedObject(self, &WPCollectionGroupPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
