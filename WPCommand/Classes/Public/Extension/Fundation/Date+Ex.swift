//
//  Date+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

public extension Date{
    
    /// 获取当月最大天数
    var wp_dayInMonth : Int{
        return wp_offSetDay(-self.wp_day+1)?.wp_day ?? 0
    }

    /// 当天零点
    var wp_zero : Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month,.day], from: self)
        return calendar.date(from: components)
    }
    
    /// 年
    var wp_year : Int{
      return Calendar.current.component(.year, from: self)
    }
    
    /// 月
    var wp_month : Int{
      return Calendar.current.component(.month, from: self)
    }
    
    /// 日
    var wp_day : Int{
      return Calendar.current.component(.day, from: self)
    }
    
    /// 时
    var wp_hour : Int{
    return Calendar.current.component(.hour, from: self)
    }
    
    /// 分
    var wp_minute : Int{
      return Calendar.current.component(.minute, from: self)
    }
    
    /// 秒
    var wp_second : Int{
      return Calendar.current.component(.second, from: self)
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

public extension Date{
    
    /// 转日期
    /// - Parameter format: format
    /// - Returns: 结果
    func wp_format(_ format:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    /// 日期转本地时间字符串
    /// - Parameter format: 日期格式
    /// - Returns:
    func wp_toZh_ChString(_ format:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    /// 当前的网络时间
    /// - Parameter resualt: 结果
    static func wp_Net(_ resualt:@escaping(Date)->Void){
        let url = URL(string: "http://www.baidu.com")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        
        let task = session.dataTask(with: request) { data, response, error in
            
            let resp = response as? HTTPURLResponse
            let str =  resp?.allHeaderFields["Date"] as? String
            guard
                let str = str
            else { return }
            
            let fomat = DateFormatter()
            fomat.locale = Locale(identifier: "en")
            fomat.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
            let date = fomat.date(from: str)
            
            DispatchQueue.main.async {
                if let date = date{
                    resualt(date + 8.wp_hour)
                }else{

                }
            }
        }
        
        task.resume()
    }
}

public extension Date{
    
    /// 偏移年
    /// - Parameter year: 年
    /// - Returns: 结果
    func wp_offSetYear(_ year:Int,_ calendar : Calendar = Calendar.current)->Date?{
        let date = self
        var comps = calendar.dateComponents([.year], from: date)
        comps.year = year
        return calendar.date(byAdding: comps, to: date)
    }
    
    /// 偏移月
    /// - Parameter month: 月
    /// - Returns: 结果
    func wp_offSetMonth(_ month:Int,_ calendar : Calendar = Calendar.current)->Date?{
        let date = self
        var comps = calendar.dateComponents([.month], from: date)
        comps.month = month
        return calendar.date(byAdding: comps, to: date)
    }
    
    /// 偏移日
    /// - Parameter day: 日
    /// - Returns: 结果
    func wp_offSetDay(_ day:Int,_ calendar : Calendar = Calendar.current)->Date?{
        let date = self
        var comps = calendar.dateComponents([.day], from: date)
        comps.day = day
        return calendar.date(byAdding: comps, to: date)
    }
    
    /// 偏移时
    /// - Parameter hour: 时
    /// - Returns: 结果
    func wp_offSetHour(_ hour:Int,_ calendar : Calendar = Calendar.current)->Date?{
        let date = self
        var comps = calendar.dateComponents([.hour], from: date)
        comps.hour = hour
        return calendar.date(byAdding: comps, to: date)
    }
    
    /// 偏移分
    /// - Parameter minute: 分
    /// - Returns: 结果
    func wp_offSetMinute(_ minute:Int,_ calendar : Calendar = Calendar.current)->Date?{
        let date = self
        var comps = calendar.dateComponents([.minute], from: date)
        comps.minute = minute
        return calendar.date(byAdding: comps, to: date)
    }
    
    /// 偏移秒
    /// - Parameter second: 秒
    /// - Returns: 结果
    func wp_offSetSecond(_ second:Int,_ calendar : Calendar = Calendar.current)->Date?{
        let date = self
        var comps = calendar.dateComponents([.second], from: date)
        comps.second = second
        return calendar.date(byAdding: comps, to: date)
    }
}
