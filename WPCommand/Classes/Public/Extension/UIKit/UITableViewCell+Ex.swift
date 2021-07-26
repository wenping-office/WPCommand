//
//  UITableViewCell+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit



extension UITableViewCell:WPTableCellProtocol{
    /// 给Cell 赋值item后调用
    @objc open func didSetItem(item:WPTableItem){}
    
    /// 付值info后会调用
    /// - Parameter info: info
    @objc open func didSetItemInfo(info:Any?){}
}






