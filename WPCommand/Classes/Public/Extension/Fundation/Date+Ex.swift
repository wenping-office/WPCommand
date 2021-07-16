//
//  Date+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension Date{
    
    /// 日期转本地时间字符串
    /// - Parameter format: 日期格式
    /// - Returns:
    func wp_toZh_ChString(_ format:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    /// 获取当前 秒级 时间戳 - 10位
    var wp_timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var wp_milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}
