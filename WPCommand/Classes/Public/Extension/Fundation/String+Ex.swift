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
    
    /// 当前app版本
    static var wp_appVersion : String?{
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    /// 是否是邮箱
    var wp_isEmail : Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        return predicate.evaluate(with: self)
    }
    
    /// 是否全中文
    var wp_isChinese : Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[\\u4E00-\\u9FA5]+$")
        return predicate.evaluate(with: self)
    }
    
    /// 是否是数字
    var wp_isDigital: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9]+(.[0-9]{1,8})?$")
        return predicate.evaluate(with: self)
    }
    
    /// 是否是电话
    var isMobile: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^1(3[0-9]|4[579]|5[0-35-9]|6[2567]|7[0-35-8]|8[0-9]|9[189])\\d{8}$")
        return predicate.evaluate(with: self)
    }
    
    /// 小数位数
    var wp_minNumCount : Int {
        if self.contains(".") {
            let separatedArray = self.components(separatedBy: ".")
            let numberStr = separatedArray.last
            return numberStr?.count ?? 0
        }else{
            return -self.count
        }
    }
    
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
    
    /// mainBundle中的图片
    var wp_image : UIImage{
        return UIImage.init(named: self) ?? UIImage()
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

    /// 转日期 默认本地日期
    /// - Parameter format: 日期格式
    /// - Parameter locale: 默认zh_CN
    /// - parameter timeZone: 默认当前时区
    /// - Returns: 日期
    func wp_toDate(_ format:String,
                   locale:Locale? = Locale(identifier: "zh_CN"),
                   timeZone:TimeZone? = TimeZone.current)->Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }

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
    
    /// 从头部开始取值 数量不足则返回所有
    /// - Parameter count: 个数
    /// - Returns: 结果
    func wp_fistTo(_ count:Int) -> String{
        return wp_subStrTo(.init(location: 0, length: count))
    }
    
    /// 从尾部开始取值 数量不足则返回所有
    /// - Parameter count: 个数
    /// - Returns: 结果
    func wp_lastTo(_ count:Int) -> String {

        let location = self.count - count
        if count <= self.count {
            return self.wp_subStrTo(.init(location: location, length: self.count))

        }else{
            return self.wp_subStrTo(.init(location: 0, length: self.count))
        }
    }
    
    /// 截取数组 如果lenght越界 则返回最大的可取范围
    /// - Parameter range: 返回
    /// - Returns: 结果
    func wp_subStrTo(_ range:NSRange) -> String{
        let lenght = range.length
        let maxLenght = self.count - range.location
        if lenght <= maxLenght {
            let count = range.location + range.length
            return (self as NSString).substring(with: .init(location: range.location, length: count))
        }else{
            return (self as NSString).substring(with: .init(location: range.location, length: self.count))
        }

    }
    
    /// 获取文字的高度
    /// - Parameters:
    ///   - font: 字体
    ///   - maxWidth: 最大的宽
    /// - Returns: 高
    func wp_height(_ font:UIFont,maxWidth:CGFloat) -> CGFloat {

        let size = CGSize.init(width: maxWidth, height:  CGFloat(MAXFLOAT))

        let dic = [NSAttributedString.Key.font:font] // swift 3.0

        let strSize = self.boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: dic, context:nil).size

        return ceil(strSize.height) + 1
    }
    
    /// 获取文字的宽度
    /// - Parameters:
    ///   - font: 字体
    ///   - maxHeight: 最大的高
    /// - Returns: 宽
    func wp_width(_ font:UIFont,_ maxHeight:CGFloat) -> CGFloat {

        let size = CGSize.init(width: CGFloat(MAXFLOAT), height: maxHeight)

        let dic = [NSAttributedString.Key.font:font] // swift 3.0

        let cString = self.cString(using: String.Encoding.utf8)
        let str = String.init(cString: cString!, encoding: String.Encoding.utf8)
        let strSize = str?.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic, context:nil).size
        return strSize?.width ?? 0
    }
}
