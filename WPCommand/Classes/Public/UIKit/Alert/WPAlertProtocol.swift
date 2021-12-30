//
//  WPAlertProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/30.
//

import UIKit
private var AlertTargetViewPointer = "WPAlertProtocolTargetViewPointer"
private var AlertStatePointer = "WPAlertStatePointer"

/// 弹窗协议都是可选实现,实现协议后由WPAlertManager弹出,show时可携带maskHandler处理点击 dismiss时可携带handler处理弹窗状态
public protocol WPAlertProtocol: UIView {
    /// 弹窗根视图
    var targetView: UIView? { get set }
    /// 弹窗状态变化后执行
    func stateDidUpdate(state: WPAlertManager.State)
    /// 弹窗的属性
    func alertInfo()->WPAlertManager.Alert
    /// 蒙板属性
    func maskInfo()->WPAlertManager.Mask
    /// 弹窗等级 等级越小越靠前弹出
    func alertLevel()->UInt
    /// 点击了蒙版
    func touchMask()
}



public extension WPAlertProtocol {
    /// 弹窗状态处理
    typealias StateHandler = ((WPAlertManager.State)->Void)?

    /// 弹窗根视图
    var targetView: UIView? {
        get {
            return WPRunTime.get(self, &AlertTargetViewPointer)
        }
        set {
            return WPRunTime.set(self, newValue, &AlertTargetViewPointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 弹窗的属性
    func alertInfo()->WPAlertManager.Alert {
        return .init(.default,
                     location: .center(),
                     showDuration: 0.3,
                     direction: .center,
                     dismissDuration: 0.3)
    }

    /// 蒙板属性
    func maskInfo()->WPAlertManager.Mask {
        return .init(color: UIColor(0, 0, 0, 0.15),
                     enabled: false,
                     isHidden: false)
    }

    /// 点击了蒙版
    func touchMask() {}

    /// 弹窗度状态更新
    func stateDidUpdate(state: WPAlertManager.State) {}

    /// 弹窗弹出的等级 越小越靠前
    func alertLevel()->UInt { return 1000 }

    /// 弹窗状态
    var stateHandler: StateHandler {
        get {
            return WPRunTime.get(self, &AlertStatePointer)
        }
        set {
            return WPRunTime.set(self, newValue, &AlertStatePointer, .OBJC_ASSOCIATION_COPY)
        }
    }
}

public extension WPSpace where Base : WPAlertProtocol{
    /// 快速显示弹窗默认显示在window上，注：如果接入了IQkeyboard想适配键盘显示在View上，如果想要全屏那么显示在keyWindow?.rootViewController?.view上
    /// - Parameters:
    ///   - targetView: 根视图
    ///   - option: 选项 默认添加到下一个
    ///   - manager: 弹窗管理者 可自定义
    ///   - stateHandler: 弹窗状态
    func show(in targetView: UIView? = nil,
              option: WPAlertManager.Option = .add,
              by manager: WPAlertManager = WPAlertManager.default,
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
    func dismiss(by manager: WPAlertManager = WPAlertManager.default,
                 stateHandler: Base.StateHandler = nil)
    {
        base.stateHandler = stateHandler
        manager.dismiss()
    }
}
