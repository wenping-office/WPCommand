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
    
