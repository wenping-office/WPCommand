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

open class WPGCD: NSObject {
    /// 主线程异步
    public static func main_Async(task:@escaping()->Void){
        DispatchQueue.main.async {
            task()
        }
    }
    /// 主线程同步
    public static func main_Sync(task:@escaping()->Void){
        DispatchQueue.main.sync {
            task()
        }
    }
    
    /// 主线程异步延迟
    public static func main_asyncAfter(_ timer:DispatchTime,task:@escaping()->Void){
        DispatchQueue.main.asyncAfter(deadline:timer , execute: {
            task()
        })
    }
}
