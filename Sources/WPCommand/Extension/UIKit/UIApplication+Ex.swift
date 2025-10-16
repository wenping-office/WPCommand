//
//  UIApplication+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2022/4/27.
//

import UIKit

public extension WPSpace where Base: UIApplication {

    /// 当前显示的window
   static var keyWindow: UIWindow? {
       if #available(iOS 13.0, *) {
           return UIApplication.shared.connectedScenes
               .compactMap { $0 as? UIWindowScene }
               .flatMap { $0.windows }
               .first(where: { $0.isKeyWindow })
       } else {
           return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
       }
    }
}
