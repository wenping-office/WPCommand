//
//  WPProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/24.
//

import UIKit

/// 排序协议
public protocol WPRepeatProtocol{
    /// 排序唯一标识
    func wp_repeatKey() -> String
}

extension Int:   WPRepeatProtocol {}
extension Int16: WPRepeatProtocol {}
extension Int32: WPRepeatProtocol {}
extension Int64: WPRepeatProtocol {}
extension UInt:  WPRepeatProtocol {}
extension UInt8: WPRepeatProtocol {}
extension UInt16: WPRepeatProtocol {}
extension UInt32: WPRepeatProtocol {}
extension UInt64: WPRepeatProtocol {}
extension Double: WPRepeatProtocol {}
extension CGFloat: WPRepeatProtocol {}
extension String:  WPRepeatProtocol {}
extension NSString: WPRepeatProtocol {}
extension Date: WPRepeatProtocol {}

public extension WPRepeatProtocol{
    
    func wp_repeatKey() -> String{
        if let int = self as? Int{ return int.description }
        if let int16 = self as? Int16{ return int16.description }
        if let int32 = self as? Int32{ return int32.description }
        if let int64 = self as? Int64{ return int64.description }
        if let uInt8 = self as? UInt8{ return uInt8 .description }
        if let uInt16 = self as? UInt16{ return uInt16.description }
        if let uInt32 = self as? UInt32{ return uInt32.description }
        if let uInt64 = self as? UInt64{ return uInt64.description }
        if let double = self as? Double{ return double.description }
        if let cGFloat = self as? CGFloat{ return cGFloat.description }
        if let string = self as? String{ return string }
        if let nSString = self as? NSString{ return nSString as String}
        if let date = self as? Date{ return date.wp_milliStamp}
        return ""
    }
    
}

