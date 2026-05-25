//
//  Any+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/12/15.
//

import UIKit

func WPDLog(_ items: Any..., separator: String = " ", terminator: String = "\n",
          file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let filename = (file as NSString).lastPathComponent
    let output = items.map { "\($0)" }.joined(separator: separator)
    print("[\(filename):\(line) \(function)] \(output)", terminator: terminator)
    #endif
}


public extension WPSpace where Base : AnyObject {
    /// 自定义
    /// - Parameter make: block
    /// - Returns: 语法糖
    @discardableResult
    func `do`(_ make:(Base)->Void) -> Self {
        weak var weakBase = base
        if let newBase = weakBase{
            make(newBase)
        }
        return self
    }
    
    /// 自定义
    /// - Parameter make: block
    /// - Returns: 对象实体
    @discardableResult
    func make(_ make:(Base)->Void) -> Base {
        return self.do(make).value()
    }
}

