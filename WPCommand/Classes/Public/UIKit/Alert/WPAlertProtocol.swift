//
//  WPAlertProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/30.
//

import UIKit

fileprivate var AlertTargetViewPointer = "WPAlertProtocolTargetViewPointer"

/// 弹窗协议都是可选实现,实现协议后由WPAlertManager弹出
public protocol WPAlertProtocol:UIView {
    
    /// 弹窗根视图
    var targetView : UIView? { get set }
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

public extension WPAlertProtocol{
    
    
    /// 弹窗根视图
    var targetView : UIView? {
        get{
            return WPRunTime.get(self, &AlertTargetViewPointer)
        }
        set{
            return WPRunTime.set(self, newValue, &AlertTargetViewPointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 弹窗的属性
    func alertInfo()->WPAlertManager.Alert{
        return .init(.default,
                     startLocation: .center(),
                     startDuration: 0.3,
                     stopLocation: .center,
                     stopDuration: 0.3)
    }
    
    /// 蒙板属性
    func maskInfo()->WPAlertManager.Mask{
        return .init(color: UIColor.init(0, 0, 0,0.15),
                     enabled: false,
                     isHidden: false)
    }
    
    /// 点击了蒙版
    func touchMask(){}
    
    /// 弹窗度状态更新
    func updateStatus(status: WPAlertManager.Progress){}
    
    /// 弹窗弹出的等级 越小越靠前
    func alertLevel()->UInt{ return 1000 }
}

public extension WPAlertProtocol{
    
    /// 快速显示一个弹窗
    /// - Parameters:
    ///   - targetView: 弹窗根视图
    ///   - option: 选项
    func show(in targetView:UIView? = nil,
              option:WPAlertManager.Option = .add,
              by manager:WPAlertManager = WPAlertManager.default){
        self.targetView = targetView
        manager.showNext(self, option: option)
    }
    
    /// 隐藏弹框
    func dismiss(by manager:WPAlertManager = WPAlertManager.default){
        manager.dismiss()
    }
}
