//
//  String.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension String{
    /// 字符串转本地日期
    /// - Parameter format: 解码规则
    /// - Returns:
    func wp_toZh_ChDate(_ format:String)->Date?{
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    /// 秒转 00:00:00
    /// - Parameter time: 秒级时间戳
    static func wp_ToHourMin(time: Int64) -> String
    {
        let allTime: Int64 = Int64(time)
        var hours = 0
        var minutes = 0
        var seconds = 0
        var hoursText = ""
        var minutesText = ""
        var secondsText = ""
        hours = Int(allTime / 3600)
        hoursText = hours > 9 ? "\(hours)" : "0\(hours)"
        minutes = Int(allTime % 3600 / 60)
        minutesText = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        seconds = Int(allTime % 3600 % 60)
        secondsText = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        return "\(hoursText):\(minutesText):\(secondsText)"
    }
    
    /// 生成二维码图片
    /// - Returns: 二维码图片
    func wp_qrImage() -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 9, y: 9)
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        return UIImage(ciImage: output)
    }
    
    /// 过滤表情
    /// - Returns: 结果
    func wp_filterEmoji() -> String {
        if self == "➊" || self == "➋" || self == "➌" || self == "➍" || self == "➎" || self == "➏" || self == "➐" || self == "➑" || self == "➒" {
            return self
        }
        let regex = try!NSRegularExpression.init(pattern: "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]", options: .caseInsensitive)
        
        let modifiedString = regex.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange.init(location: 0, length: self.count), withTemplate: "")
        return modifiedString
    }
}
