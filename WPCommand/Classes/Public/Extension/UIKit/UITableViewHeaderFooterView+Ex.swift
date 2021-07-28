//
//  UITableViewHeaderFooterView+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UITableViewHeaderFooterView : WPTableHeaderFooterViewlProtocol{

    /// 加载group 每次显示时都会调用一次
    /// - Parameter group: 模型
    @objc open func reloadGroup(group: WPTableGroup) {}
}




