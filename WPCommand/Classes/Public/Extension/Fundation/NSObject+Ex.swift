//
//  NSObject+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/28.
//

import RxSwift
import UIKit

private var wp_disposeBagPointer = "wp_disposeBag"

public extension NSObject {
    /// 懒加载垃圾桶
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
}
