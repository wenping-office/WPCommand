//
//  WPAlertProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/30.
//

import UIKit
private var AlertTargetViewPointer = "WPAlertProtocolTargetViewPointer"
private var AlertStatePointer = "WPAlertStatePointer"
private var AlertStateHandlerPointer = "AlertStateHandlerPointer"

/// 弹窗协议都是可选实现,实现协议后由WPAlertManager弹出、可使用WPAlertManager动态修改alert高度或者offset，可搭配WPSystem.KeyBoard适配键盘，可使用frame固定布局或layout布局、如使用frame布局，需要初始时设置frame.size
public protocol WPQueueAlertable: UIView {
    
    /// 当前弹窗状态
    var currentAlertState: WPQueueAlertCenter.State { get set }
    /// 弹窗根视图
    var targetView: UIView? { get set }
    /// 弹窗状态变化后执行
    func stateDidUpdate(state: WPQueueAlertCenter.State)
    /// 弹窗的属性
    func alertInfo()->WPQueueAlertCenter.Alert
    /// 蒙板属性
    func maskInfo()->WPQueueAlertCenter.Mask
    /// 弹窗等级 等级越小越靠前弹出
    func alertLevel()->UInt
    /// 点击了蒙层
    func touchMask()
}



public extension WPQueueAlertable {
    /// 弹窗状态处理
    typealias StateHandler = ((WPQueueAlertCenter.State)->Void)?

    /// 弹窗根视图
    var targetView: UIView? {
        get {
            return WPRunTime.get(self, withUnsafePointer(to: &AlertTargetViewPointer, {$0}))
        }
        set {
            return WPRunTime.set(self, newValue, withUnsafePointer(to: &AlertTargetViewPointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 弹窗根视图
    var currentAlertState: WPQueueAlertCenter.State {
        get {
            let state : WPQueueAlertCenter.State = WPRunTime.get(self, withUnsafePointer(to: &AlertStatePointer, {$0})) ?? WPQueueAlertCenter.State.unknown
            return state
        }
        set {
            return WPRunTime.set(self, newValue, withUnsafePointer(to: &AlertStatePointer, {$0}), .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// 弹窗的属性
    func alertInfo()->WPQueueAlertCenter.Alert {
        return .init(.default,
                     location: .center(),
                     showDuration: 0.3,
                     direction: .center,
                     dismissDuration: 0.3)
    }

    /// 蒙板属性
    func maskInfo()->WPQueueAlertCenter.Mask {
        return .init(color: .wp.initWith(0, 0, 0, 0.15),
                     enabled: false,
                     hidden: false)
    }

    /// 点击了蒙层
    func touchMask() {}

    /// 弹窗度状态更新
    func stateDidUpdate(state: WPQueueAlertCenter.State) {}

    /// 弹窗弹出的等级 越小越靠前
    func alertLevel()->UInt { return 1000 }

    /// 弹窗状态
    var stateHandler: StateHandler {
        get {
            return WPRunTime.get(self, withUnsafePointer(to: &AlertStateHandlerPointer, {$0}))
        }
        set {
            return WPRunTime.set(self, newValue, withUnsafePointer(to: &AlertStateHandlerPointer, {$0}), .OBJC_ASSOCIATION_COPY)
        }
    }
}

public extension WPSpace where Base : WPQueueAlertable{
    /// 快速显示弹窗默认显示在window上，注：如果接入了IQkeyboard想适配键盘显示在View上，如果想要全屏那么显示在keyWindow?.rootViewController?.view上
    /// - Parameters:
    ///   - targetView: 根视图
    ///   - option: 选项 默认添加到下一个
    ///   - manager: 弹窗管理者 可自定义
    ///   - stateHandler: 弹窗状态
    func show(in targetView: UIView? = nil,
              option: WPQueueAlertCenter.Option = .add,
              by manager: WPQueueAlertCenter = WPQueueAlertCenter.default,
              stateHandler: Base.StateHandler = nil)
    {
        base.targetView = targetView
        base.stateHandler = stateHandler
        manager.show(next: base,option: option)
    }

    /// 隐藏弹窗
    /// - Parameters:
    ///   - manager: 弹窗管理者 必须和显示的时候使用的同一个管理者
    ///   - statusHandler: 弹窗状态处理
    func dismiss(by manager: WPQueueAlertCenter = WPQueueAlertCenter.default,
                 stateHandler: Base.StateHandler = nil)
    {
        base.stateHandler = stateHandler
        manager.dismiss()
    }
}
