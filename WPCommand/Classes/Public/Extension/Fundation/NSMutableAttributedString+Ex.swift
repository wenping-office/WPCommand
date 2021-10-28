//
//  NSMutableAttributedString+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/28.
//

import UIKit

public extension NSMutableAttributedString{
    
    /// 设置行间距
    /// - Parameters:
    ///   - spacing: 行间距
    ///   - range: 范围
    /// - Returns: 结果
    func wp_lineSpacing(_ spacing:CGFloat,range:NSRange?=nil) -> NSMutableAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacing

        if range != nil{
            addAttributes([.paragraphStyle:style], range: range!)
        }else{
            addAttributes([.paragraphStyle:style], range: NSMakeRange(0, string.count))
        }

        return self
    }
    
    /// 设置font
    /// - Parameters:
    ///   - font: 字体
    ///   - range: 范围
    /// - Returns: 结果
    func wp_font(_ font:UIFont,range:NSRange?=nil) -> NSMutableAttributedString {

        if range != nil{
            addAttributes([.font:font], range: range!)
        }else{
            addAttributes([.font:font], range: NSMakeRange(0, string.count))
        }

        return self
    }
    
    /// 设置字体颜色
    /// - Parameters:
    ///   - color: 颜色
    ///   - range: 范围
    /// - Returns: 结果
    func wp_foregroundColor(_ color:UIColor,range:NSRange?=nil) -> NSMutableAttributedString {
        if range != nil{
            addAttributes([.foregroundColor:color], range: range!)
        }else{
            addAttributes([.foregroundColor:color], range: NSMakeRange(0, string.count))
        }
        return self
    }
    
    /// 数字单独设置字体
    /// - Parameters:
    ///   - numberFont: 字体
    /// - Returns: 结果
    func wp_number(_ numberFont:UIFont) -> NSMutableAttributedString {
        do {
            let regular = try NSRegularExpression(pattern: "[a-zA-Z0-9(:/%)]+", options: .caseInsensitive)
            let results = regular.matches(in: string, options: .reportProgress, range: NSRange(location: 0, length: string.count))
            for result in results {
                addAttributes([.font:numberFont], range: result.range)
            }
        } catch {
            return self
        }
        return self
    }
}
