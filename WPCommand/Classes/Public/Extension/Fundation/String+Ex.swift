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
    
    /// 是否包含数字
    var isOfNumber: Bool {
        return base.range(of: "[0-9]", options: .regularExpression) != nil
    }
    
    /// 是否包含字母大小写
    var isOfA_z: Bool {
        return base.range(of: "[A-z]", options: .regularExpression) != nil
    }
    
    /// 是否包含字符
    var isOfSymbol: Bool {
        return base.range(of: "[(?=.*[\\p{P}\\p{S}])]", options: .regularExpression) != nil
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
    
    /// 转浮点数
    var cgFloat:CGFloat?{
        if float == nil{
            return nil
        }
        return CGFloat(float!)
    }

    /// 转浮点数
    var float: Float? {
        return NumberFormatter().number(from: base)?.floatValue
    }
    
    /// 转浮点数
    var double: Double?{
        return NumberFormatter().number(from: base)?.doubleValue
    }
    
    /// 是否安装当前协议app
    var isInstalled:Bool{
        if let url = URL(string: base){
            return UIApplication.shared.canOpenURL(url)
            
        }else{
            return false
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
    
    /// 检查当前字符里的关键字
    /// - Parameters:
    ///   - patterns: 关键字 || 正则表达式
    ///   - options: 选项
    /// - Returns: 结果
    func checkingResult(_ patterns:[String],
                        options:NSRegularExpression.Options = [.caseInsensitive])->[NSTextCheckingResult]{
        var res: [NSTextCheckingResult] = []
        patterns.forEach { key in
            let regex = try? NSRegularExpression(pattern: key, options: .caseInsensitive)
            res.append(contentsOf: regex?.matches(in: base, range: .init(0, base.count)) ?? [])
        }
        
       return res
    }
    
    /// 根据扩展名获取MineType 未实现
    func mimeType()->String{
//        import MobileCoreServices
//        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
//                                                           base as NSString,
//                                                           nil)?.takeRetainedValue()
//        {
//            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?
//                .takeRetainedValue()
//            {
//                return mimetype as String
//            }
//        }
//        // 未知文件资源类型，可传万能类型application/octet-stream，服务器会自动解析文件类型
//        return "application/octet-stream"
        return ""
    }
    
    /// 整数位字体和小数位字体设置
    /// - Parameters:
    ///   - intFont: 整数位字体
    ///   - intColor: 整数位颜色
    ///   - doubleFont: 小数位字体
    ///   - doubleColor: 小数位颜色
    /// - Returns: 结果
    func color(intFont:UIFont,
                intColor:UIColor,
                doubleFont:UIFont,
                doubleColor:UIColor) -> NSAttributedString {
        if isContent("."){
            let range = of(".")
            let intStr = subString(of: .init(0, range.location))
            let doubleStr = subString(of: .init(range.location,base.count - range.location))
            return intStr.wp.attributed.font(intFont).foregroundColor(intColor).append(doubleStr.wp.attributed.font(doubleFont).foregroundColor(doubleColor)).value()
        }else{
            return attributed.font(intFont).foregroundColor(intColor).value()
        }
    }

}

public extension WPSpace where Base == String{
    /// base64字符串转图片
    /// - Parameter options: 选项
    /// - Returns: 结果
    func base64Image(_ options:NSData.Base64DecodingOptions = .ignoreUnknownCharacters) -> UIImage? {
        if let data = NSData.init(base64Encoded: base,options: options){
            return UIImage(data: data as Data)
        }
        return nil
    }
    
    /// 编码
    func encoding(_ withAllowedCharacters: CharacterSet = .alphanumerics) -> String {
        return base.addingPercentEncoding(withAllowedCharacters: withAllowedCharacters) ?? ""
    }
    
    /// 获取网络图片横竖
    func networkImageIsHorizontal() -> Bool {
        let urlQuery = base.components(separatedBy: ",")
        //获取长宽值
        guard urlQuery.count > 2,
              let widthStr = urlQuery.first(where: {$0.hasPrefix("w_")}),
              let heightStr = urlQuery.first(where: {$0.hasPrefix("h_")}) else {
            return true
        }

        //从字符串中获取Int类型的长宽
        let nonDigits = CharacterSet.decimalDigits.inverted
        guard let width = Int(widthStr.trimmingCharacters(in: nonDigits)),
              let height = Int(heightStr.trimmingCharacters(in: nonDigits)) else {
            return true
        }

        if width > height {
            return true
        }
        return false
    }
}

public extension WPSpace where Base == String{
    
    /// 生成二维码
    /// - Parameters:
    ///   - width: 二维码宽
    ///   - fillImage: 中心图片
    ///   - color: 二维码颜色
    /// - Returns: 结果
    func QRImage( _ width: CGFloat, _ fillImage: UIImage? = nil, _ color: UIColor? = nil) -> UIImage? {
        // 给滤镜设置内容
        guard let data = base.data(using: .utf8) else {
            return nil
        }
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            // 设置生成的二维码的容错率
            // value = @"L/M/Q/H"
            filter.setValue("H", forKey: "inputCorrectionLevel")
            // 获取生成的二维码
            guard let outPutImage = filter.outputImage else {
                return nil
            }
            // 设置二维码颜色
            let colorFilter = CIFilter(name: "CIFalseColor", parameters: ["inputImage": outPutImage, "inputColor0": CIColor(cgColor: color?.cgColor ?? UIColor.black.cgColor), "inputColor1": CIColor(cgColor: UIColor.clear.cgColor)])
            
            // 获取带颜色的二维码
            guard let newOutPutImage = colorFilter?.outputImage else {
                return nil
            }
            let scale = width/newOutPutImage.extent.width
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            let output = newOutPutImage.transformed(by: transform)
            let QRCodeImage = UIImage(ciImage: output)
            guard let fillImage = fillImage else {
                return QRCodeImage
            }
            let imageSize = QRCodeImage.size
            UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
            QRCodeImage.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
            let fillRect = CGRect(x: (width - width/5)/2, y: (width - width/5)/2, width: width/5, height: width/5)
            fillImage.draw(in: fillRect)
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return QRCodeImage }
            UIGraphicsEndImageContext()
            return newImage
        }
        
        return nil
    }
    
    
    /// 生成条形码
    /// - Parameters:
    ///   - size: 条形码尺寸
    ///   - color: 条形码颜色
    /// - Returns: 结果
    func code128(_ size: CGSize, _ color: UIColor? = nil) -> UIImage?
    {
        // 给滤镜设置内容
        guard let data = base.data(using: .utf8) else {
            return nil
        }
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setDefaults()
            filter.setValue(data, forKey: "inputMessage")
            // 获取生成的条形码
            guard let outPutImage = filter.outputImage else {
                return nil
            }
            // 设置条形码颜色
            let colorFilter = CIFilter(name: "CIFalseColor", parameters: ["inputImage": outPutImage, "inputColor0": CIColor(cgColor: color?.cgColor ?? UIColor.black.cgColor), "inputColor1": CIColor(cgColor: UIColor.clear.cgColor)])
            // 获取带颜色的条形码
            guard let newOutPutImage = colorFilter?.outputImage else {
                return nil
            }
            let scaleX: CGFloat = size.width/newOutPutImage.extent.width
            let scaleY: CGFloat = size.height/newOutPutImage.extent.height
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            let output = newOutPutImage.transformed(by: transform)
            let barCodeImage = UIImage(ciImage: output)
            return barCodeImage
        }
        
        return nil
    }
}

public extension WPSpace where Base == String{
    /// 16进制转字节
    /// - Parameter hexStr: 字符串
    /// - Returns: 字节数组
    var bytes: [UInt8] {
          var bytes = [UInt8]()
          var sum = 0
          // 整形的 utf8 编码范围
          let intRange = 48...57
          // 小写 a~f 的 utf8 的编码范围
          let lowercaseRange = 97...102
          // 大写 A~F 的 utf8 的编码范围
          let uppercasedRange = 65...70
          for (index, c) in base.utf8CString.enumerated() {
              var intC = Int(c.byteSwapped)
              if intC == 0 {
                  break
              } else if intRange.contains(intC) {
                  intC -= 48
              } else if lowercaseRange.contains(intC) {
                  intC -= 87
              } else if uppercasedRange.contains(intC) {
                  intC -= 55
              } else {
                  assertionFailure("输入字符串格式不对，每个字符都需要在0~9，a~f，A~F内")
              }
              sum = sum * 16 + intC
              // 每两个十六进制字母代表8位，即一个字节
              if index % 2 != 0 {
                  bytes.append(UInt8(sum))
                  sum = 0
              }
          }
          return bytes
      }
}

public extension WPSpace where Base == String{
    /// 转换成js方法
    /// - Parameter argms: 参数
    /// - Returns: 结果
    func jsFunc(_ argms:[String] = []) -> String {
        var index = 1
        let newArgms = argms.map { str in
            index += 1
            if index == argms.count{
                return "'" + str + "',"
            }else{
                return "'" + str + "'"
            }
        }
        var str = base
        str.append("(")
        newArgms.forEach { elmt in
            str.append(elmt)
        }
        return str.appending(")")
    }

    /// 转换成js方法
    /// - Parameter dataStr: 传递参数 如果多个 可【拼接】
    /// - Returns: js代码字符串
    func jsFunc(_ dataStr:String) -> String {
        return "\(base)('\(dataStr)')"
    }
    
    
    /// 转换成json
    func json()->[String:Any]{
        if let data = base.data(using: .utf8){
            let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any]
            return json ?? [:]
        }
        return [:]
    }
    
    /// 转jsonArr
    func jsonArr() -> [[String:Any]] {
        if let data = base.data(using: .utf8){
            let json = try? JSONSerialization.jsonObject(with: data) as? [[String:Any]]
            return json ?? []
        }
        return []
    }
    
    /// 根据正则表达式筛选字符串
    /// - Parameter regex: 正则
    /// - Returns: 结果
    func matches(in regex:String) -> [NSTextCheckingResult] {
        let regex = try? NSRegularExpression(pattern: regex)
        let range = NSRange(location: 0, length: base.count)
        return regex?.matches(in: base, range: range) ?? []
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
        let res : [NSTextCheckingResult] = of(keyword)
        if res.count > 0{
            return (base as NSString).range(of: keyword)
        }else{
            return .init(location: 0, length: 0)
        }
    }
    
    /// 返回子字符串在当前字符串的位置
    /// - Parameters:
    ///   - keyword: 关键字
    ///   - options: 选择
    ///   - matchingOptions: 选择
    /// - Returns: 结果
    func of(_ keyword:Base,
            options:NSRegularExpression.Options = [] ,
            matchingOptions:NSRegularExpression.MatchingOptions = []) -> [NSTextCheckingResult] {
        let regex = try? NSRegularExpression(pattern: keyword, options: options)
        return regex?.matches(in: base, options: matchingOptions, range: NSRange(location: 0, length: base.count)) ?? []
    }
    
    /// 判断是否包含某个字符串
    /// - Parameter keyword: 关键字
    /// - Returns: 结果
    func isContent(_ keyword: String) -> Bool {
        let resualt : NSRange = of(keyword)
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
        
        let maxLength = base.count - range.location
        if range.location > base.count - 1{ return "" }
        if range.length <= 0 { return "" }
        if maxLength <= 0 { return "" }
        
        if range.length <= maxLength {
            return (base as NSString).substring(with: range)
        } else {
            return (base as NSString).substring(with: .init(location: range.location, length: maxLength))
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
