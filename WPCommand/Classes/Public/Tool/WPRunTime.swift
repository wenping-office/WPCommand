//
//  WPRunTime.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/9.
//

import UIKit

open class WPRunTime: NSObject {
    
    /// 返回指针指向的对象
    public static func get<T>(_ target:Any,_ key:UnsafeRawPointer)->T?{
        return objc_getAssociatedObject(target, key) as? T
    }
    /// 动态添加一个属性
    public static func set(_ target:Any,_ value:Any?,_ key:UnsafeRawPointer,_ policy:objc_AssociationPolicy){
        objc_setAssociatedObject(target, key, value, policy)
    }
}
