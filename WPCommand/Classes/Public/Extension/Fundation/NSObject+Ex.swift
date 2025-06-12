//
//  NSObject+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/28.
//

import RxSwift
import UIKit
import Combine

private var wp_disposeBagPointer = "wp_disposeBag"
private var wp_cancellablePointer = "wp_cancellable"

public extension NSObject {
    /// 懒加载垃圾袋
    var wp_disposeBag: DisposeBag {
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &wp_disposeBagPointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let disposeBag: DisposeBag = WPRunTime.get(self, withUnsafePointer(to: &wp_disposeBagPointer, {$0})) else {
                let bag = DisposeBag()
                self.wp_disposeBag = bag
                return bag
            }
            return disposeBag
        }
    }
}


public extension WPSpace where Base: NSObject {
    /// 懒加载垃圾袋
    var disposeBag: DisposeBag {
        set {
            base.wp_disposeBag = newValue
        }
        get {
            return base.wp_disposeBag
        }
    }
    
    /// 懒加载垃圾袋
    @available(iOS 13.0, *)
    var cancellabel: Set<AnyCancellable>{
        set{
            base.wp_cancellabel = newValue
        }
        get{
            return base.wp_cancellabel
        }
    }

    /// 对象文件所在bundle
    static var bundle:Bundle{
        return Bundle(for: Base.classForCoder())
    }
}

@available(iOS 13.0, *)
public extension NSObject {
    /// 懒加载垃圾袋
    var wp_cancellabel:Set<AnyCancellable>{
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &wp_cancellablePointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let cancellable: Set<AnyCancellable> = WPRunTime.get(self, withUnsafePointer(to: &wp_cancellablePointer, {$0})) else {
                let bag = Set<AnyCancellable>()
                self.wp_cancellabel = bag
                return bag
            }
            return cancellable
        }
    }
}


public extension WPSpace where Base: NSObject {
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
