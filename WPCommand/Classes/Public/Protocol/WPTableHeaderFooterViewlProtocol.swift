//
//  WPTableHeaderFooterViewlProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

fileprivate var WPTableGroupPointer = "WPTableGroupPointer"

public protocol WPTableHeaderFooterViewlProtocol : NSObjectProtocol{

    func reloadGroup(group:WPTableGroup)
    
    /// group模型
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
