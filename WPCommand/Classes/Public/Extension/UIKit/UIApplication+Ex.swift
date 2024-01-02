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
}
