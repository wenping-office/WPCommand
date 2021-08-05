//
//  WPAlertProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/30.
//

import UIKit

/// 弹窗协议
public protocol WPAlertProtocol:UIView {
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

    /// 弹窗的属性
    func alertInfo()->WPAlertManager.Alert{
        return .init(type: .default,
                     startLocation: .center(),
                     startDuration: 0.3,
                     stopLocation: .center,
                     stopDuration: 0.3)
    }
    
    /// 蒙板属性
    func maskInfo()->WPAlertManager.Mask{
        return .init(color: UIColor.init(0, 0, 0,255 * 0.15),
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