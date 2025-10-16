//
//  UIViewController+Rx.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/10/16.
//

import UIKit
import RxSwift
import RxCocoa

// 扩展 UIViewController 添加生命周期的 Rx 支持
public extension WPSpace where Base: UIViewController {
    
    /// 当 viewDidLoad 被调用时发出信号
    var viewDidLoad: ControlEvent<Void> {
        let source = base.rx.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    /// 当 viewWillAppear 被调用时发出信号
    var viewWillAppear: ControlEvent<Bool> {
        let source = base.rx.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    /// 当 viewDidAppear 被调用时发出信号
    var viewDidAppear: ControlEvent<Bool> {
        let source = base.rx.methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    /// 当 viewWillDisappear 被调用时发出信号
    var viewWillDisappear: ControlEvent<Bool> {
        let source = base.rx.methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    /// 当 viewDidDisappear 被调用时发出信号
    var viewDidDisappear: ControlEvent<Bool> {
        let source = base.rx.methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    /// 当 viewWillLayoutSubviews 被调用时发出信号
    var viewWillLayoutSubviews: ControlEvent<Void> {
        let source = base.rx.methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }
    
    /// 当 viewDidLayoutSubviews 被调用时发出信号
    var viewDidLayoutSubviews: ControlEvent<Void> {
        let source = base.rx.methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }
}
