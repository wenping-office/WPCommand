//
//  WPTimerProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/27.
//

import UIKit

/// 时间协议
public protocol WPTimerProtocol {}

extension Int: WPTimerProtocol, WPSpaceProtocol {}
extension Int8: WPTimerProtocol, WPSpaceProtocol {}
extension Int16: WPTimerProtocol, WPSpaceProtocol {}
extension Int32: WPTimerProtocol, WPSpaceProtocol {}
extension Int64: WPTimerProtocol, WPSpaceProtocol {}
extension UInt: WPTimerProtocol, WPSpaceProtocol {}
extension UInt8: WPTimerProtocol, WPSpaceProtocol {}
extension UInt16: WPTimerProtocol, WPSpaceProtocol {}
extension UInt32: WPTimerProtocol, WPSpaceProtocol {}
extension UInt64: WPTimerProtocol, WPSpaceProtocol {}
extension CGFloat: WPTimerProtocol, WPSpaceProtocol {}
extension Double: WPTimerProtocol, WPSpaceProtocol {}

public extension WPSpace where Base: WPTimerProtocol {
    /// 日
    var day: TimeInterval {
        if let Int = base as? Int {
            return TimeInterval(60 * 60 * 24 * Int)
        } else if let Int8 = base as? Int32 {
            return TimeInterval(60 * 60 * 24 * Int8)
        } else if let Int16 = base as? Int32 {
            return TimeInterval(60 * 60 * 24 * Int16)
        } else if let Int32 = base as? Int32 {
            return TimeInterval(60 * 60 * 24 * Int32)
        } else if let Int64 = base as? Int64 {
            return TimeInterval(60 * 60 * 24 * Int64)
        } else if let UInt = base as? UInt {
            return TimeInterval(60 * 60 * 24 * UInt)
        } else if let UInt8 = base as? UInt {
            return TimeInterval(60 * 60 * 24 * UInt8)
        } else if let UInt16 = base as? UInt {
            return TimeInterval(60 * 60 * 24 * UInt16)
        } else if let UInt32 = base as? UInt32 {
            return TimeInterval(60 * 60 * 24 * UInt32)
        } else if let UInt64 = base as? UInt64 {
            return TimeInterval(60 * 60 * 24 * UInt64)
        } else if let CGFloat = base as? CGFloat {
            return TimeInterval(60 * 60 * 24 * CGFloat)
        } else if let Double = base as? Double {
            return TimeInterval(60 * 60 * 24 * Double)
        }
        return 0
    }

    /// 时
    var hour: TimeInterval {
        if let Int = base as? Int {
            return TimeInterval(60 * 60 * Int)
        } else if let Int8 = base as? Int32 {
            return TimeInterval(60 * 60 * Int8)
        } else if let Int16 = base as? Int32 {
            return TimeInterval(60 * 60 * Int16)
        } else if let Int32 = base as? Int32 {
            return TimeInterval(60 * 60 * Int32)
        } else if let Int64 = base as? Int64 {
            return TimeInterval(60 * 60 * Int64)
        } else if let UInt = base as? UInt {
            return TimeInterval(60 * 60 * UInt)
        } else if let UInt8 = base as? UInt {
            return TimeInterval(60 * 60 * UInt8)
        } else if let UInt16 = base as? UInt {
            return TimeInterval(60 * 60 * UInt16)
        } else if let UInt32 = base as? UInt32 {
            return TimeInterval(60 * 60 * UInt32)
        } else if let UInt64 = base as? UInt64 {
            return TimeInterval(60 * 60 * UInt64)
        } else if let CGFloat = base as? CGFloat {
            return TimeInterval(60 * 60 * CGFloat)
        } else if let Double = base as? Double {
            return TimeInterval(60 * 60 * Double)
        }
        return 0
    }

    /// 分
    var minute: TimeInterval {
        if let Int = base as? Int {
            return TimeInterval(60 * Int)
        } else if let Int8 = base as? Int32 {
            return TimeInterval(60 * Int8)
        } else if let Int16 = base as? Int32 {
            return TimeInterval(60 * Int16)
        } else if let Int32 = base as? Int32 {
            return TimeInterval(60 * Int32)
        } else if let Int64 = base as? Int64 {
            return TimeInterval(60 * Int64)
        } else if let UInt = base as? UInt {
            return TimeInterval(60 * UInt)
        } else if let UInt8 = base as? UInt {
            return TimeInterval(60 * UInt8)
        } else if let UInt16 = base as? UInt {
            return TimeInterval(60 * UInt16)
        } else if let UInt32 = base as? UInt32 {
            return TimeInterval(60 * UInt32)
        } else if let UInt64 = base as? UInt64 {
            return TimeInterval(60 * UInt64)
        } else if let CGFloat = base as? CGFloat {
            return TimeInterval(60 * CGFloat)
        } else if let Double = base as? Double {
            return TimeInterval(60 * Double)
        }
        return 0
    }

    /// 秒
    var second: TimeInterval {
        if let Int = base as? Int {
            return TimeInterval(Int)
        } else if let Int8 = base as? Int32 {
            return TimeInterval(Int8)
        } else if let Int16 = base as? Int32 {
            return TimeInterval(Int16)
        } else if let Int32 = base as? Int32 {
            return TimeInterval(Int32)
        } else if let Int64 = base as? Int64 {
            return TimeInterval(Int64)
        } else if let UInt = base as? UInt {
            return TimeInterval(UInt)
        } else if let UInt8 = base as? UInt {
            return TimeInterval(UInt8)
        } else if let UInt16 = base as? UInt {
            return TimeInterval(UInt16)
        } else if let UInt32 = base as? UInt32 {
            return TimeInterval(UInt32)
        } else if let UInt64 = base as? UInt64 {
            return TimeInterval(UInt64)
        } else if let CGFloat = base as? CGFloat {
            return TimeInterval(CGFloat)
        } else if let Double = base as? Double {
            return TimeInterval(Double)
        }
        return 0
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
}
