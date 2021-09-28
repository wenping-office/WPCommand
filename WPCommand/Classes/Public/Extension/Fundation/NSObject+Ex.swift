//
//  NSObject+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/28.
//

import UIKit
import RxSwift

fileprivate var wp_disposeBagPointer = "wp_disposeBag"

public extension NSObject {

    /// 懒加载垃圾桶
    var wp_disposeBag: DisposeBag {
        set {
            WPRunTime.set(self, newValue, &wp_disposeBagPointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let disposeBag: DisposeBag =  WPRunTime.get(self, &wp_disposeBagPointer) else {
                let bag = DisposeBag()
                self.wp_disposeBag = bag
                return bag
            }
            return disposeBag
        }
    }
}
