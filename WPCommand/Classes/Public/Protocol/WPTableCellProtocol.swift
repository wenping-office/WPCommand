//
//  WPTableCellProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

fileprivate var WPitemPointer = "WPItemsModelPointer"

public protocol WPTableCellProtocol : NSObjectProtocol{
    
    /// item模型创建时是什么item cell就会获得一个什么样的item
    var item : WPTableItem?{ get set}
}

extension WPTableCellProtocol{

    public var item : WPTableItem? {
        get{
            return objc_getAssociatedObject(self, &WPitemPointer) as? WPTableItem
        }
        set{
            objc_setAssociatedObject(self, &WPitemPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
