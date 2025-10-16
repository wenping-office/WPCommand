//
//  NSObject+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/28.
//

import UIKit

public extension WPSpace where Base: NSObject {
    
    /// 对象文件所在bundle
    static var bundle:Bundle{
        return Bundle(for: Base.classForCoder())
    }

    /// 初始化配置
    /// - Parameter config: 配置
    /// - Returns: 对象
    @discardableResult
    static func initConfig(_ config:((Base)->Void)? = nil) -> Base{
        let obj = Base()
        weak var weakObj = obj

        if  weakObj != nil {
            config?(weakObj!)
        }
        return obj
    }
}
