//
//  WPProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/24.
//

import UIKit

/// 排序协议
public protocol WPRepeatProtocol{
    /// 去重唯一标识
    var wp_repeatKey : String {get}
}

extension Int:   WPRepeatProtocol { public var wp_repeatKey: String { get { return self.description } } }
extension Int16: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension Int32: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension Int64: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension UInt:  WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension UInt8: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension UInt16: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension UInt32: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension UInt64: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension Double: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension CGFloat: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension String:  WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension NSString: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }
extension Date: WPRepeatProtocol {public var wp_repeatKey: String { get { return self.description } } }

