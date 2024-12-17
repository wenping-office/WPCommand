//
//  UIApplication+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2022/4/27.
//

import UIKit

public extension WPSpace where Base: UIApplication {

    /// 程序启动时的window
   static var mainWindow: UIWindow? {
        return UIApplication.shared.windows.wp_elmt { elmt in
            elmt.windowLevel == .normal
        }
    }
    
    /// 获取当前的window
    static var current: UIWindow? {
        if #available(iOS 13.0, *) {
            if let window =  UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first{
                return window
            }else if let window = UIApplication.shared.delegate?.window{
                return window
            }else{
                return nil
            }
        } else {
            if let window = UIApplication.shared.delegate?.window{
                return window
            }else{
                return nil
            }
        }
    }
}
