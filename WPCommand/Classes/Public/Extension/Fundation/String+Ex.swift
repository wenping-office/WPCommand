//
//  String.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import CommonCrypto

public extension String{
    
    /// 一个可变富文本
    var wp_attStr : NSMutableAttributedString{
        return NSMutableAttributedString(string: self)
    }

    /// 加载一个bundle
    var wp_bundle : Bundle?{
        var bundle: Bundle?
        if let url = Bundle.main.url(forResource: self, withExtension: "bundle") {
            bundle = Bundle(url: url)
        }
        return bundle
    }

    /// 加密成md5字符串
    var wp_md5 : String{
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
    
    /// 加密成base64字符串
    var wp_base64 : String?{
        let da = data(using: String.Encoding.utf8)
        return da?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }

    /// 生成二维码图片
    /// - Returns: 二维码图片
    var wp_qrImage : UIImage?{
        let data = self.data(using: String.Encoding.ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 9, y: 9)
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        return UIImage(ciImage: output)
    }
    
    /// 过滤表情
    /// - Returns: 结果
    var wp_filterEmoji : String{
        if self == "➊" || self == "➋" || self == "➌" || self == "➍" || self == "➎" || self == "➏" || self == "➐" || self == "➑" || self == "➒" {
            return self
        }
        let regex = try!NSRegularExpression.init(pattern: "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]", options: .caseInsensitive)
        
        let modifiedString = regex.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange.init(location: 0, length: self.count), withTemplate: "")
        return modifiedString
    }
    
    /// 过滤空格
    var wp_filterSpace : String{
        return wp_filter(" ")
    }
    
    /// 过滤换行
    var wp_filterLineFeed : String{
        return wp_filter("\n")
    }
}

public extension String{
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
    
    
    /// 加载图片
    /// - Parameter bundle: 包
    /// - Returns: 图片
    func wp_image(_ bundle: Bundle) -> UIImage {
        return UIImage(named: self, in: bundle, compatibleWith: nil) ?? UIImage()
    }
    
    
    /// 过滤字符串
    /// - Parameter str: 关键字
    /// - Returns: 过滤后的结果
    func wp_filter(_ str:String)->String{
        return replacingOccurrences(of: str, with: "", options: .literal, range: nil)
    }
    
    /// 返回子字符串在当前字符串的位置 如果有多个将会找最后一个
    /// - Parameter str: 关键字
    func wp_Of(_ keyword: String)->NSRange{
        return (self as NSString).range(of: keyword)
    }
    
    /// 复制到粘贴版
    func wp_sopyToPasteboard(){
        let pasteboard = UIPasteboard.general
        pasteboard.string = self
    }
}
