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
    func wp_lineSpacing(spacing:CGFloat,range:NSRange?=nil) -> NSMutableAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacing

        if range != nil{
            self.addAttributes([.paragraphStyle:style], range: range!)
        }else{
            self.addAttributes([.paragraphStyle:style], range: NSMakeRange(0, self.string.count))
        }

        return self
    }
    
    /// 设置font
    /// - Parameters:
    ///   - font: 字体
    ///   - range: 范围
    /// - Returns: 结果
    func wp_font(font:UIFont,range:NSRange?=nil) -> NSMutableAttributedString {

        if range != nil{
            self.addAttributes([.font:font], range: range!)
        }else{
            self.addAttributes([.font:font], range: NSMakeRange(0, self.string.count))
        }

        return self
    }
    
    /// 设置字体颜色
    /// - Parameters:
    ///   - color: 颜色
    ///   - range: 范围
    /// - Returns: 结果
    func wp_foregroundColor(color:UIColor,range:NSRange?=nil) -> NSMutableAttributedString {
        if range != nil{
            self.addAttributes([.foregroundColor:color], range: range!)
        }else{
            self.addAttributes([.foregroundColor:color], range: NSMakeRange(0, self.string.count))
        }
        return self
    }
}
