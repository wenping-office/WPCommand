//
//  NSAttributedString.swift
//  WPCommand
//
//  Created by Wen_Ping on 2022/12/13.
//

import Foundation

public extension WPSpace where Base : NSAttributedString{
    /// 可变富文本
    var mutable: WPSpace<NSMutableAttributedString> {
        return .init(NSMutableAttributedString(attributedString: base))
    }
    
    /// 截取子字符串 如果length越界 则返回最大的可取范围
    /// - Parameter range: 返回
    /// - Returns: 结果
    func subString(of range: NSRange) -> Base? {
        let maxLength = base.length - range.location
        if range.location > base.length - 1{ return nil }
        if range.length <= 0 { return nil }
        if maxLength <= 0 { return nil }
        
        if range.length <= maxLength {
            return base.attributedSubstring(from: range) as? Base
        } else {
            return base.attributedSubstring(from: .init(location: range.location, length: maxLength)) as? Base
        }
    }
}


