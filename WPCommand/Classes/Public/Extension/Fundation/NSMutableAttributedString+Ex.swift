//
//  NSMutableAttributedString+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/28.
//

import UIKit


public extension WPSpace where Base == String{
    /// 一个可变富文本
    var attributed : WPSpace<NSMutableAttributedString>{
        return .init(NSMutableAttributedString(string: base))
    }
}

public extension WPSpace where Base : NSMutableAttributedString{
    
    /// 设置行间距
    /// - Parameters:
    ///   - spacing: 行间距
    ///   - range: 范围
    /// - Returns: 结果
    func lineSpacing(_ spacing:CGFloat,
                     range:NSRange?=nil) -> Self {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacing

        if range != nil{
            base.addAttributes([.paragraphStyle:style], range: range!)
        }else{
            base.addAttributes([.paragraphStyle:style], range: NSMakeRange(0, base.string.count))
        }

        return self
    }
    
    /// 设置font
    /// - Parameters:
    ///   - font: 字体
    ///   - range: 范围
    /// - Returns: 结果
    func font(_ font:UIFont,
              range:NSRange?=nil) -> Self {

        if range != nil{
            base.addAttributes([.font:font], range: range!)
        }else{
            base.addAttributes([.font:font], range: NSMakeRange(0, base.string.count))
        }

        return self
    }
    
    /// 设置字体颜色
    /// - Parameters:
    ///   - color: 颜色
    ///   - range: 范围
    /// - Returns: 结果
    func foregroundColor(_ color:UIColor,
                         range:NSRange?=nil) -> Self {
        if range != nil{
            base.addAttributes([.foregroundColor:color], range: range!)
        }else{
            base.addAttributes([.foregroundColor:color], range: NSMakeRange(0, base.string.count))
        }
        return self
    }
    
    /// 数字单独设置字体
    /// - Parameters:
    ///   - numberFont: 字体
    /// - Returns: 结果
    func number(_ numberFont:UIFont) -> Self {
        do {
            let regular = try NSRegularExpression(pattern: "[a-zA-Z0-9(:/%)]+", options: .caseInsensitive)
            let results = regular.matches(in: base.string, options: .reportProgress, range: NSRange(location: 0, length: base.string.count))
            for result in results {
                base.addAttributes([.font:numberFont], range: result.range)
            }
        } catch {
            return self
        }
        return self
    }
    
    /// 获取操作完成后的富文本
    /// - Returns: 富文本
    func complete() -> Base {
        return base
    }
}
