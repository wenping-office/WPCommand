//
//  UITableViewCell+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

fileprivate var WPitemPointer = "WPItemsModelPointer"

extension UITableViewCell:WPTableCellProtocol{
    /// 给Cell 赋值item后调用
    @objc open func didSetItem(item:WPTableItem){}
    
    /// 付值info后会调用
    /// - Parameter info: info
    @objc open func didSetItemInfo(info:Any?){}
}

protocol WPTableCellProtocol : NSObjectProtocol{
    
    /// item模型创建时是什么item cell就会获得一个什么样的item
    var item : WPTableItem?{ get set}
}

extension WPTableCellProtocol{

     var item : WPTableItem? {
        get{
            return objc_getAssociatedObject(self, &WPitemPointer) as? WPTableItem
        }
        set{
            objc_setAssociatedObject(self, &WPitemPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}




