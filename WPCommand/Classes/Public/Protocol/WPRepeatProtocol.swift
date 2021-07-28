//
//  WPProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/24.
//

import UIKit

/// 去重协议
public protocol WPRepeatProtocol{
    associatedtype type : Hashable
    /// 去重唯一标识
    var wp_repeatKey : type { get }
}

extension Int:   WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: Int { get { return self } } }

extension Int16: WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: Int16 { get { return self } }
}

extension Int32: WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: Int32 { get { return self } }
}
extension Int64: WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: Int64 { get { return self } }
}

extension UInt:  WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: UInt { get { return self } }
}
extension UInt8: WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: UInt8 { get { return self } }
}
extension UInt16: WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: UInt16 { get { return self } }
}
extension UInt32: WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: UInt32 { get { return self } }
}
extension UInt64: WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: UInt64 { get { return self } }
}
extension Double: WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: Double { get { return self } }
}
extension CGFloat: WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: CGFloat { get { return self } }
}
extension String:  WPRepeatProtocol {
    public typealias key = Self
    public var wp_repeatKey: String { get { return self } }
}
extension NSString: WPRepeatProtocol {
    public typealias key = NSString
    public var wp_repeatKey: NSString { get { return self } }
}

extension Date: WPRepeatProtocol {
    public typealias key = String
    public var wp_repeatKey: String { get { return self.wp_milliStamp } }
 }

