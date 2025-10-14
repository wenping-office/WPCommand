//
//  Combine+Ex.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/9/4.
//

import Combine
import ObjectiveC

private var wp_cancellablePointer = "wp_cancellables"


@available(iOS 13.0, *)
open class CancellableBox {
   public var set: Set<AnyCancellable> = []
}

public extension WPSpace where Base : NSObject{
    
    /// 懒加载垃圾袋
    @available(iOS 13.0, *)
    var cancellables: CancellableBox {
        set {
            WPRunTime.set(base, newValue, withUnsafePointer(to: &wp_cancellablePointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let disposeBag: CancellableBox = WPRunTime.get(base, withUnsafePointer(to: &wp_cancellablePointer, {$0})) else {
                let box = CancellableBox()
                WPRunTime.set(base, box, withUnsafePointer(to: &wp_cancellablePointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return box
            }
            return disposeBag
        }
    }
}



