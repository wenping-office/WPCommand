//
//  Any+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/12/15.
//

import UIKit


public extension WPSpace where Base : AnyObject {
    
    /// 所在内存地址
    var memoryAddress : String{
        let str = Unmanaged<AnyObject>.passRetained(base).toOpaque()
        return String(describing: str)
    }
}

public extension WPSpace where Base == Int {
    
    /// 判断是否在范围内
    /// - Parameter range: 范围
    /// - Returns: 结果
    func locationIn(_ range:Range<Base>) -> Bool {
        return NSLocationInRange(base, .init(range.lowerBound, range.upperBound))
    }
    
    /// 判断是否在范围内
    /// - Parameter range: 范围
    /// - Returns: 结果
    func locationIn(_ range:NSRange) -> Bool {
        return NSLocationInRange(base, range)
    }
}
