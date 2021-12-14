//
//  Date+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

public extension WPSpace where Base == Date{

    /// 获取当月最大天数
    var dayInMonth : Int{
        let date = offSet(month: 1)
        return date.wp.offSet(day: -date.wp.day).wp.day
    }

    /// 当天零点
    var zero : Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month,.day], from: base)
        return calendar.date(from: components)
    }
    
    /// 年
    var year : Int{
      return Calendar.current.component(.year, from: base)
    }
    
    /// 月
    var month : Int{
      return Calendar.current.component(.month, from: base)
    }
    
    /// 日
    var day : Int{
      return Calendar.current.component(.day, from: base)
    }
    
    /// 时
    var hour : Int{
    return Calendar.current.component(.hour, from: base)
    }
    
    /// 分
    var minute : Int{
      return Calendar.current.component(.minute, from: base)
    }
    
    /// 秒
    var second : Int{
      return Calendar.current.component(.second, from: base)
    }
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = base.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = base.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
    /// 星期 [0星期天,1星期一,2星期二，已此类推]
    var weekday : Int {
        let interval = base.timeIntervalSince1970;
        let days = Int(interval / 86400);
        return (days - 3) % 7
    }
    
    /// 是否是当天
    var isToDay : Bool {
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        let selfComponents = calendar.dateComponents([.day, .month, .year], from: base)
        return (selfComponents.year == nowComponents.year) && (selfComponents.month == nowComponents.month) && (selfComponents.day == nowComponents.day)
    }
    
    /// 是否是当月
    var isToMonth : Bool{
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.month, .year], from: Date())
        let selfComponents = calendar.dateComponents([.month, .year], from: base)
        return (selfComponents.year == nowComponents.year) && (selfComponents.month == nowComponents.month)
    }
    
    /// 是否是当年
    var isToYear : Bool{
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.year], from: Date())
        let selfComponents = calendar.dateComponents([.year], from: base)
        return (selfComponents.year == nowComponents.year)
    }
}

// 不要的扩展
public extension WPSpace where Base == Date{
    
    /// 日期转本地时间字符串
    /// - Parameter format: 日期格式
    /// - Returns:
    func toZh_ChString(_ format:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: base)
    }
    
    /// 转日期
    /// - Parameter format: format
    /// - Returns: 结果
    func format(_ format:String,
                timerZone:TimeZone = .init(identifier: "UTC")!)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timerZone
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.string(from: base)
    }
}

public extension WPSpace where Base == Date{
    
    /// 转日期
    /// - Parameter format: format
    /// - Parameter timerZone: 时区
    /// - Parameter locale: 默认中国
    /// - Returns: 结果
    func string(_ format:String,
                timerZone:TimeZone? = .init(identifier: "UTC")!,
                locale : Locale? = Locale.current)->String{
        let dateFormatter = DateFormatter()
        if timerZone != nil{
            dateFormatter.timeZone = timerZone
        }
        if locale != nil {
            dateFormatter.locale = locale
        }
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: base)
    }
}

public extension WPSpace where Base == Date{

    /// 偏移年
    /// - Parameter year: 年
    /// - Returns: 结果
    func offSet(year:Int,
                    _ calendar : Calendar = Calendar.current)->Base{
        var comps = calendar.dateComponents([.year], from: base)
        comps.year = year
        return calendar.date(byAdding: comps, to: base) ?? Date()
    }
    
    /// 偏移月
    /// - Parameter month: 月
    /// - Returns: 结果
    func offSet(month:Int,
                     _ calendar : Calendar = Calendar.current)->Base{
        var comps = calendar.dateComponents([.month], from: base)
        comps.month = month
        return calendar.date(byAdding: comps, to: base) ?? Date()
    }
    
    /// 偏移日
    /// - Parameter day: 日
    /// - Returns: 结果
    func offSet(day:Int,
                   _ calendar : Calendar = Calendar.current)->Base{
        var comps = calendar.dateComponents([.day], from: base)
        comps.day = day

        return calendar.date(byAdding: comps, to: base) ?? Date()
    }
    
    /// 偏移时
    /// - Parameter hour: 时
    /// - Returns: 结果
    func offSet(hour:Int,
                    _ calendar : Calendar = Calendar.current)->Base{
        var comps = calendar.dateComponents([.hour], from: base)
        comps.hour = hour
        return calendar.date(byAdding: comps, to: base) ?? Date()
    }
    
    /// 偏移分
    /// - Parameter minute: 分
    /// - Returns: 结果
    func offSet(minute:Int,
                      _ calendar : Calendar = Calendar.current)->Base{
        var comps = calendar.dateComponents([.minute], from: base)
        comps.minute = minute

        return calendar.date(byAdding: comps, to: base) ?? Date()
    }
    
    /// 偏移秒
    /// - Parameter second: 秒
    /// - Returns: 结果
    func offSet(second:Int,
                      _ calendar : Calendar = Calendar.current)->Base{
        var comps = calendar.dateComponents([.second], from: base)
        comps.second = second
        return calendar.date(byAdding: comps, to: base) ?? Date()
    }
}

public extension WPSpace where Base == Date{
    
    /// 获取当前网络时间
    /// - Parameters:
    ///   - success: 成功
    ///   - failed: 失败
    static func currentInNet(success:(@escaping(Base)->Void),
                             failed:(()->Void)?=nil){
        let url = URL(string: "http://www.baidu.com")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request) { data, response, error in
            let resp = response as? HTTPURLResponse
            if let str =  resp?.allHeaderFields["Date"] as? String{
                let fomat = DateFormatter()
                fomat.locale = Locale(identifier: "en")
                fomat.timeZone = .init(identifier: "UTC")
                fomat.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
                let date = fomat.date(from: str)
                WPGCD.main_Async {
                    if let date = date{
                        success(date)
                    }else{
                        failed?()
                    }
                }
            }else{
                WPGCD.main_Async {
                    failed?()
                }
            }
        }
        task.resume()
    }
}
