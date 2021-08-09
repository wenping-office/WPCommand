//
//  WPRunTime.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/9.
//

import UIKit

class WPRunTime: NSObject {
    
    /// 返回指针指向的对象
    static func get(_ target:Any,_ key:UnsafeRawPointer)->Any?{
        return objc_getAssociatedObject(target, key)
    }
    /// 动态添加一个属性
    static func set(_ target:Any,_ value:Any?,_ key:UnsafeRawPointer,_ policy:objc_AssociationPolicy){
        objc_setAssociatedObject(target, key, value, policy)
    }
}
