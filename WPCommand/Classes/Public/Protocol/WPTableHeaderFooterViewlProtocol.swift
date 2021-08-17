//
//  WPTableHeaderFooterViewlProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

fileprivate var WPTableGroupPointer = "WPTableGroupPointer"

public protocol WPTableHeaderFooterViewlProtocol : NSObjectProtocol,UITableViewHeaderFooterView{
    
    /// 加载模型时调用
    /// - Parameter group: group模型
    func reloadGroup(group:WPTableGroup)
    
    /// group模型
    var group : WPTableGroup?{ get set}
}

extension WPTableHeaderFooterViewlProtocol{
    
    public var group : WPTableGroup? {
        get{
            return WPRunTime.get(self, &WPTableGroupPointer)
        }
        set{
            return WPRunTime.set(self, newValue, &WPTableGroupPointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
