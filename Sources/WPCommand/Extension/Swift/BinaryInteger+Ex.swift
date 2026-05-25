//
//  WPTimerProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/27.
//

import UIKit

public extension WPSpace where Base : BinaryInteger {
    /// 日
    var day:TimeInterval{
        return TimeInterval(60 * 60 * 24 * base)
    }
    
    /// 时
    var hour: TimeInterval{
        return TimeInterval(60 * 60 * base)
    }
    
    /// 分
    var minute: TimeInterval{
        return TimeInterval(60 * base)
    }
    
    /// 秒
    var second: TimeInterval {
        return TimeInterval(base)
    }
        
        ///  秒转计算天时分秒
        /// - Returns: 结果
    func times()->(day:Int,
                       hour:Int,
                       minute:Int,
                       second:Int) {
        let intSecound = Int(second)
        let days = Int(intSecound/(3600*24))
        let hours = Int((intSecound - days*24*3600)/3600)
        let minute = Int((intSecound - days*24*3600-hours*3600)/60)
        let second = Int((intSecound - days*24*3600-hours*3600) - 60*minute)
        return (days,hours,minute,second)
    }
    
    /// 将任意整数类型转换成任意浮点类型
    /// - Returns: 转换后的浮点数
    func toFloat<T: BinaryFloatingPoint>() -> T {
        return T(base)
    }
}
