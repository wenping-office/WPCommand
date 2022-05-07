//
//  String.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CommonCrypto
import UIKit

public extension WPSpace where Base == String {
    /// 当前app版本
    static var appVersion: Base? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? Base
    }
    
    /// 当前appBuild版本
    static var appBuildVersion: Base? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? Base
    }
        
    /// 当前app的包标识符
    static var appIdentifier: Base? {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? Base
    }
    
    /// 当前app的包名
    static var appName: Base? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? Base
    }
    
    /// 16进制颜色
    var color : UIColor{
        return UIColor.wp.initWith(base)
    }

    /// 是否是邮箱
    var isEmail: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        return predicate.evaluate(with: base)
    }
    
    /// 是否全中文
    var isChinese: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[\\u4E00-\\u9FA5]+$")
        return predicate.evaluate(with: base)
    }
    
    /// 是否是数字
    var isDigital: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9]+(.[0-9]{1,8})?$")
        return predicate.evaluate(with: base)
    }
    
    /// 是否是电话
    var isMobile: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^1(3[0-9]|4[579]|5[0-35-9]|6[2567]|7[0-35-8]|8[0-9]|9[189])\\d{8}$")
        return predicate.evaluate(with: self)
    }
    
    /// 小数位数
    var minNumCount: Int {
        if base.contains(".") {
            let separatedArray = base.components(separatedBy: ".")
            let numberStr = separatedArray.last
            return numberStr?.count ?? 0
        } else {
            return -base.count
        }
    }

    /// 加载一个bundle
    var bundle: Bundle? {
        var bundle: Bundle?
        if let url = Bundle.main.url(forResource: base, withExtension: "bundle") {
            bundle = Bundle(url: url)
        }
        return bundle
    }

    /// 加密成md5字符串
    var md5: Base {
        let str = base.cString(using: Base.Encoding.utf8)
        let strLen = CUnsignedInt(base.lengthOfBytes(using: Base.Encoding.utf8))
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
    var image: UIImage {
        return UIImage(named: base) ?? UIImage()
    }
    
    /// 加密成base64字符串
    var wp_base64: String? {
        let da = base.data(using: String.Encoding.utf8)
        return da?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }

    /// 生成二维码图片
    /// - Returns: 二维码图片
    var qrImage: UIImage? {
        let data = base.data(using: Base.Encoding.ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 9, y: 9)
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        return UIImage(ciImage: output)
    }
    
    /// 过滤表情
    /// - Returns: 结果
    var filterEmoji: Base {
        if base == "➊" || base == "➋" || base == "➌" || base == "➍" || base == "➎" || base == "➏" || base == "➐" || base == "➑" || base == "➒" {
            return base
        }
        let regex = try! NSRegularExpression(pattern: "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]", options: .caseInsensitive)
        
        let modifiedString = regex.stringByReplacingMatches(in: base, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: base.count), withTemplate: "")
        return modifiedString
    }
    
    /// 过滤空格
    var filterSpace: Base {
        return filter(" ")
    }
    
    /// 过滤换行
    var filterLineFeed: Base {
        return filter("\n")
    }
}

public extension WPSpace where Base == String {
    /// 转日期
    /// - Parameters:
    ///   - format: 日期格式
    ///   - timeZone: 时区 默认UTC
    /// - Returns: 日期
    func date(_ format: String,
              timeZone: TimeZone? = .init(identifier: "UTC")) -> Date?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: base)
    }
    
    /// 秒转 00:00:00
    /// - Parameter time: 秒级时间戳
    static func hourMin(second: Int64) -> String {
        let allTime = Int64(second)
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

    /// 生成随机数字+字母字符串
    /// - Parameter length: 字符串长度
    /// - Returns: 结果
    static func random(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    /// 加载图片
    /// - Parameter bundle: 包
    /// - Returns: 图片
    func image(_ bundle: Bundle) -> UIImage {
        return UIImage(named: base, in: bundle, compatibleWith: nil) ?? UIImage()
    }

    /// 过滤字符串
    /// - Parameter str: 关键字
    /// - Returns: 过滤后的结果
    func filter(_ str: String) -> Base {
        return base.replacingOccurrences(of: str, with: "", options: .literal, range: nil)
    }
    
    /// 返回子字符串在当前字符串的位置 如果有多个将会找最后一个
    /// - Parameter str: 关键字
    func of(_ keyword: Base) -> NSRange {
        return (base as NSString).range(of: keyword)
    }
    
    /// 判断是否包含某个字符串
    /// - Parameter keyword: 关键字
    /// - Returns: 结果
    func isContent(_ keyword: String) -> Bool {
        let resualt = of(keyword)
        return resualt.length != 0
    }
    
    /// 复制到粘贴版
    func copyToPasteboard() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = base
    }
    
    /// 从头部开始取值 数量不足则返回所有
    /// - Parameter count: 个数
    /// - Returns: 结果
    func first(of count: Int) -> Base {
        return subString(of: .init(location: 0, length: count))
    }
    
    /// 从尾部开始取值 数量不足则返回所有
    /// - Parameter count: 个数
    /// - Returns: 结果
    func last(of count: Int) -> Base {
        let location = base.count - count
        if count <= base.count {
            return subString(of: .init(location: location, length: count))
        } else {
            return subString(of: .init(location: 0, length: base.count))
        }
    }
    
    /// 截取子字符串 如果length越界 则返回最大的可取范围
    /// - Parameter range: 返回
    /// - Returns: 结果
    func subString(of range: NSRange) -> Base {
        let lenght = range.length
        let maxLenght = base.count - range.location
        if lenght <= maxLenght {
            return (base as NSString).substring(with: range)
        } else {
            return (base as NSString).substring(with: .init(location: range.location, length: base.count))
        }
    }
    
    /// 获取文字的高度
    /// - Parameters:
    ///   - font: 字体
    ///   - maxWidth: 最大的宽
    /// - Returns: 高
    func height(_ font: UIFont, maxWidth: CGFloat) -> CGFloat {
        let size = CGSize(width: maxWidth, height: CGFloat(MAXFLOAT))

        let dic = [NSAttributedString.Key.font: font] // swift 3.0

        let strSize = base.boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: dic, context: nil).size

        return ceil(strSize.height) + 1
    }
    
    /// 获取文字的宽度
    /// - Parameters:
    ///   - font: 字体
    ///   - maxHeight: 最大的高
    /// - Returns: 宽
    func width(_ font: UIFont, _ maxHeight: CGFloat) -> CGFloat {
        let size = CGSize(width: CGFloat(MAXFLOAT), height: maxHeight)

        let dic = [NSAttributedString.Key.font: font] // swift 3.0

        let cString = base.cString(using: Base.Encoding.utf8)
        let str = String(cString: cString!, encoding: Base.Encoding.utf8)
        let strSize = str?.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic, context: nil).size
        return strSize?.width ?? 0
    }
}
