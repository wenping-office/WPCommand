//
//  UITableViewHeaderFooterView+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

fileprivate var WPTableGroupPointer = "WPTableGroupPointer"

extension UITableViewHeaderFooterView : WPTableHeaderFooterViewlProtocol{

    /// 加载group 每次显示时都会调用一次
    /// - Parameter group: 模型
    @objc open func reloadGroup(group: WPTableGroup) {}
}

public protocol WPTableHeaderFooterViewlProtocol : NSObjectProtocol{

    func reloadGroup(group:WPTableGroup)
    
    var group : WPTableGroup?{ get set}
}

extension WPTableHeaderFooterViewlProtocol{
    
    public var group : WPTableGroup? {
        get{
            return objc_getAssociatedObject(self, &WPTableGroupPointer) as? WPTableGroup
        }
        set{
            objc_setAssociatedObject(self, &WPTableGroupPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


