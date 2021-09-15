//
//  WPMenuViewDataSource.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/14.
//

import UIKit

public protocol WPMenuViewDataSource:NSObjectProtocol{

    /// 当前索引返回的视图
    /// - Parameter index: 索引
    func viewForIndex(index:Int)->UIView?
    
}
