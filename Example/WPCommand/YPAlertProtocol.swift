//
//  YPAlertProtocol.swift
//  YPCommand
//
//  Created by WenPing on 2021/7/30.
//

import UIKit
private var AlertTargetVieYPointer = "YPAlertProtocolTargetVieYPointer"
private var AlertStatePointer = "YPAlertStatePointer"

/// 弹窗协议
public protocol YPAlertProtocol: UIView {
    /// 弹窗根视图
    var targetView: UIView? { get set }
    /// 弹窗状态变化后执行
    func stateDidUpdate(state: YPAlertManager.State)
    /// 弹窗的属性
    func alertInfo()->YPAlertManager.Alert
    /// 蒙板属性
    func maskInfo()->YPAlertManager.Mask
    /// 弹窗等级 等级越小越靠前弹出
    func alertLevel()->UInt
    /// 点击了蒙版
    func touchMask()
}



public extension YPAlertProtocol {
    typealias StateHandler = ((YPAlertManager.State)->Void)?

    /// 弹窗根视图
    var targetView: UIView? {
        get {
            return YPRunTime.get(self, &AlertTargetVieYPointer)
        }
        set {
            return YPRunTime.set(self, newValue, &AlertTargetVieYPointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 弹窗的属性
    func alertInfo()->YPAlertManager.Alert {
        return .init(.default,
                     location: .center(),
                     showDuration: 0.3,
                     direction: .center,
                     dismissDuration: 0.3)
    }

    /// 蒙板属性
    func maskInfo()->YPAlertManager.Mask {
        return .init(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3*255/255),
                     enabled: false,
                     hidden: false)
    }

    /// 点击了蒙版
    func touchMask() {}

    /// 弹窗度状态更新
    func stateDidUpdate(state: YPAlertManager.State) {}

    /// 弹窗弹出的等级 越小越靠前
    func alertLevel()->UInt { return 1000 }

    /// 弹窗状态
    var stateHandler: StateHandler {
        get {
            return YPRunTime.get(self, &AlertStatePointer)
        }
        set {
            return YPRunTime.set(self, newValue, &AlertStatePointer, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    /// 快速显示弹窗默认显示在window上
    /// - Parameters:
    ///   - targetView: 根视图
    ///   - option: 选项 默认添加到下一个
    ///   - manager: 弹窗管理者 可自定义
    ///   - stateHandler: 弹窗状态
    func show(in targetView: UIView? = nil,
              option: YPAlertManager.Option = .add,
              by manager: YPAlertManager = YPAlertManager.default,
              stateHandler: StateHandler = nil)
    {
        self.targetView = targetView
        self.stateHandler = stateHandler
        manager.show(next: self,option: option)
    }

    /// 隐藏弹窗
    /// - Parameters:
    ///   - manager: 弹窗管理者 必须和显示的时候使用的同一个管理者
    ///   - statusHandler: 弹窗状态处理
    func dismiss(by manager: YPAlertManager = YPAlertManager.default,
                 stateHandler: StateHandler = nil)
    {
        self.stateHandler = stateHandler
        manager.dismiss()
    }
}

open class YPRunTime: NSObject {
    /// 返回指针指向的对象
    public static func get<T>(_ target: Any, _ key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(target, key) as? T
    }

    /// 动态添加一个属性
    public static func set(_ target: Any, _ value: Any?, _ key: UnsafeRawPointer, _ policy: objc_AssociationPolicy) {
        objc_setAssociatedObject(target, key, value, policy)
    }
}
