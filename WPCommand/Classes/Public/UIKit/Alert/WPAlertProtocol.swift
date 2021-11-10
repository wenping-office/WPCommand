//
//  WPAlertProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/30.
//

import UIKit

private var AlertTargetViewPointer = "WPAlertProtocolTargetViewPointer"

/// 弹窗协议都是可选实现,实现协议后由WPAlertManager弹出
public protocol WPAlertProtocol: UIView {
    /// 弹窗根视图
    var targetView: UIView? { get set }
    /// 弹窗状态变化后执行
    func updateStatus(status: WPAlertManager.Progress)
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
                     startLocation: .center(),
                     startDuration: 0.3,
                     stopLocation: .center,
                     stopDuration: 0.3)
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
    func updateStatus(status: WPAlertManager.Progress) {}

    /// 弹窗弹出的等级 越小越靠前
    func alertLevel()->UInt { return 1000 }
}

public extension WPAlertProtocol {
    /// 快速显示弹窗
    /// - Parameters:
    ///   - targetView: 弹窗根视图
    ///   - option: 选项 默认添加到下一个
    ///   - manager: 弹窗管理者 可自定义
    func show(in targetView: UIView? = nil,
              option: WPAlertManager.Option = .add,
              by manager: WPAlertManager = WPAlertManager.default)
    {
        self.targetView = targetView
        manager.showNext(self, option: option)
    }

    /// 隐藏弹窗
    /// - Parameter manager: 弹窗管理者 必须和显示的时候使用的同一个管理者
    func dismiss(by manager: WPAlertManager = WPAlertManager.default) {
        manager.dismiss()
    }
}

private var WPAlertBridgeStatusPointer = "WPAlertBridgeStatusPointer"
private var WPAlertBridgeMaskPointer = "WPAlertBridgeMaskPointer"

/// 弹窗桥接状态协议 show时可携带maskHandler处理点击 dismiss时可携带handler处理弹窗状态
public protocol WPAlertBridgeProtocol: WPAlertProtocol {
    /// 弹窗状态处理 只处理弹出状态
    typealias StatusHandler = ((WPAlertBridgeProtocol, WPAlertManager.Progress)->Void)?
    /// 弹窗蒙层点击处理 只处理didShow后的点击
    typealias MaskHandler = ((WPAlertBridgeProtocol)->Void)?
    /// 弹窗状态
    var statusHandler: StatusHandler { get set }
    /// 蒙层点击
    var maskHandler: MaskHandler { get set }
}

public extension WPAlertBridgeProtocol {
    /// 弹窗状态
    var statusHandler: StatusHandler {
        get {
            return WPRunTime.get(self, &AlertTargetViewPointer)
        }
        set {
            return WPRunTime.set(self, newValue, &AlertTargetViewPointer, .OBJC_ASSOCIATION_COPY)
        }
    }

    /// 弹窗状态
    var maskHandler: MaskHandler {
        get {
            return WPRunTime.get(self, &WPAlertBridgeMaskPointer)
        }
        set {
            return WPRunTime.set(self, newValue, &WPAlertBridgeMaskPointer, .OBJC_ASSOCIATION_COPY)
        }
    }

    /// 弹窗状态更新 重写后statusHandler需要自己调用
    func updateStatus(status: WPAlertManager.Progress) {
        statusHandler?(self, status)
    }

    /// 蒙层点击 重写maskHandler需要自己调用
    func touchMask() {
        maskHandler?(self)
    }

    /// 快速显示弹窗
    /// - Parameters:
    ///   - targetView: 根视图
    ///   - option: 选项 默认添加到下一个
    ///   - manager: 弹窗管理者 可自定义
    ///   - maskHandler: 蒙层点击处理
    func show(in targetView: UIView? = nil,
              option: WPAlertManager.Option = .add,
              by manager: WPAlertManager = WPAlertManager.default,
              maskHandler: MaskHandler = nil)
    {
        self.targetView = targetView
        self.maskHandler = maskHandler
        manager.showNext(self, option: option)
    }

    /// 隐藏弹窗
    /// - Parameters:
    ///   - manager: 弹窗管理者 必须和显示的时候使用的同一个管理者
    ///   - statusHandler: 弹窗状态处理
    func dismiss(by manager: WPAlertManager = WPAlertManager.default,
                 statusHandler: StatusHandler = nil)
    {
        self.statusHandler = statusHandler
        manager.dismiss()
    }
}
