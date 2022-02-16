//
//  NSMutableAttributedString+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/28.
//

import UIKit

public extension WPSpace where Base == String{
    /// 可变富文本
    var attributed: WPSpace<NSMutableAttributedString> {
        return .init(NSMutableAttributedString(string: base))
    }
}

public extension WPSpace where Base: NSMutableAttributedString {
    /// 快速设置行间距
    /// - Parameters:
    ///   - spacing: 行间距
    ///   - range: 范围
    /// - Returns: 结果
    func lineSpacing(_ spacing: CGFloat,
                     range: NSRange?=nil) -> Self
    {
        let style=NSMutableParagraphStyle()
        style.lineSpacing=spacing
        return paragraph(style, range: range)
    }

    /// 快速添加一张图片
    /// - Parameters:
    ///   - image: 图片
    ///   - bounds: 图片的bounds
    ///   - range: 图片插入的位置
    /// - Returns: 结果
    func image(_ image: UIImage,
               bounds: CGRect,
               at index: Int=0) -> Self
    {
        let attachment=NSTextAttachment()
        attachment.image=image
        attachment.bounds=bounds
        return self.attachment(attachment, at: index)
    }

    /// 数字部分单独设置字体
    /// - Parameters:
    ///   - numberFont: 字体
    /// - Returns: 结果
    func alphanumeric(font: UIFont) -> Self {
        do {
            let regular=try NSRegularExpression(pattern: "[a-zA-Z0-9(:/%)]+", options: .caseInsensitive)
            let results=regular.matches(in: base.string, options: .reportProgress, range: NSRange(location: 0, length: base.string.count))
            for result in results {
                base.addAttributes([.font: font], range: result.range)
            }
        } catch {
            return self
        }
        return self
    }

    /// 添加一个字符串
    /// - Parameter string: 字符串
    /// - Returns: 结果
    func append(str string: String) -> Self {
        base.append(NSMutableAttributedString(string: string))
        return self
    }

    /// 添加一个属性字符串
    /// - Parameter string: 属性字符串
    /// - Returns: 结果
    func append(attributedStr string: NSMutableAttributedString) -> Self {
        base.append(string)
        return self
    }
    
    /// 获取文本size
    /// - Parameters:
    ///   - maxSize: 最大尺寸
    ///   - options: 选项
    /// - Returns: 结果
    func size(with maxSize:CGSize,
              options:NSStringDrawingOptions) -> CGSize{
        return  base.string.boundingRect(with: maxSize,
                                         options: options,
                                         attributes: base.wp.get, context: nil).size
    }
    
    /// 获取富文本全部属性
    var get: [NSAttributedString.Key : Any] {
        guard base.string.count > 0 else { return [:] }
        return base.attributes(at: 0, effectiveRange: nil)
    }
}

public extension WPSpace where Base: NSMutableAttributedString {
    /// 下划线删除线枚举
    enum Style: Int {
        /// 没有
        case nothing=0
        /// 有
        case some=1
    }

    /// 字间距
    /// - Parameters:
    ///   - value: 间距
    ///   - range: 范围
    /// - Returns: 结果
    func kern(_ value: CGFloat,
              range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.kern: value], range: range!)
        } else {
            base.addAttributes([.kern: value], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 删除线颜色
    /// - Parameters:
    ///   - color: 删除线颜色
    ///   - range: 范围
    /// - Returns: 结果
    func strikethroughColor(_ color: UIColor,
                            range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.strikethroughColor: color], range: range!)
        } else {
            base.addAttributes([.strikethroughColor: color], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 删除线样式
    /// - Parameters:
    ///   - value: 值
    ///   - range: 范围
    /// - Returns: 结果
    func strikethroughStyle(_ value: Int,
                            range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.strikethroughStyle: value], range: range!)
        } else {
            base.addAttributes([.strikethroughStyle: value], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 下划线样式
    /// - Parameters:
    ///   - style: 样式
    ///   - range: 范围
    /// - Returns: 结果
    func underlineStyle(_ style: Style,
                        range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.underlineStyle: style], range: range!)
        } else {
            base.addAttributes([.underlineStyle: style], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 下划线颜色
    /// - Parameters:
    ///   - color: 颜色
    ///   - range: 范围
    /// - Returns: 结果
    func underlineStyle(_ color: UIColor,
                        range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.underlineColor: color], range: range!)
        } else {
            base.addAttributes([.underlineColor: color], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 边线颜色
    /// - Parameters:
    ///   - color: 颜色
    ///   - range: 范围
    /// - Returns: 结果
    func strokeColor(_ color: UIColor,
                     range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.strokeColor: color], range: range!)
        } else {
            base.addAttributes([.strokeColor: color], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 边线宽
    /// - Parameters:
    ///   - width: 线宽 正值空心描边，负值实心描边，默认0(不描边)
    ///   - range: 范围
    /// - Returns: 结果
    func strokeColor(_ width: CGFloat,
                     range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.strokeWidth: width], range: range!)
        } else {
            base.addAttributes([.strokeWidth: width], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 文字阴影
    /// - Parameters:
    ///   - shadow: 阴影
    ///   - range: 范围
    /// - Returns: 结果
    func shadow(_ shadow: NSShadow) -> Self {
        base.addAttributes([.shadow: shadow], range: NSMakeRange(0, 0))
        return self
    }

    /// 文字效果
    /// - Parameters:
    ///   - value: 值
    ///   - range: 范围
    /// - Returns: 结果
    func textEffect(_ value: Int,
                    range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.textEffect: value], range: range!)
        } else {
            base.addAttributes([.shadow: value], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 附件 常用图文混排
    /// - Parameters:
    ///   - attachment: 附件
    ///   - range: 范围
    /// - Returns: 结果
    func attachment(_ attachment: NSTextAttachment,
                    at index: Int=0) -> Self
    {
        let str=NSAttributedString(attachment: attachment)
        base.insert(str, at: index)
        return self
    }

    /// 超链接
    /// - Parameters:
    ///   - link: 超链接 URL方式
    ///   - range: 范围
    /// - Returns: 结果
    func link(url link: URL,
              range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.link: link], range: range!)
        } else {
            base.addAttributes([.link: link], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 超链接
    /// - Parameters:
    ///   - link: 超链接
    ///   - range: string形式
    /// - Returns: 结果
    func link(str link: String,
              range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.link: link], range: range!)
        } else {
            base.addAttributes([.link: link], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 以基线为准便宜
    /// - Parameters:
    ///   - value: 值
    ///   - range: 范围
    /// - Returns: 结果
    func baselineOffset(_ value: CGFloat,
                        range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.baselineOffset: value], range: range!)
        } else {
            base.addAttributes([.baselineOffset: value], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 文字倾斜 取值范围0～1
    /// - Parameters:
    ///   - value: 值
    ///   - range: 范围
    /// - Returns: 结果
    func obliqueness(_ value: CGFloat,
                     range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.obliqueness: value], range: range!)
        } else {
            base.addAttributes([.obliqueness: value], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 文字扁平化 拉伸效果 取值范围0～1
    /// - Parameters:
    ///   - value: 值
    ///   - range: 范围
    /// - Returns: 结果
    func expansion(_ value: CGFloat,
                   range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.expansion: value], range: range!)
        } else {
            base.addAttributes([.expansion: value], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 文字font
    /// - Parameters:
    ///   - font: 字体
    ///   - range: 范围
    /// - Returns: 结果
    func font(_ font: UIFont,
              range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.font: font], range: range!)
        } else {
            base.addAttributes([.font: font], range: NSMakeRange(0, base.string.count))
        }

        return self
    }

    /// 设置字体颜色
    /// - Parameters:
    ///   - color: 颜色
    ///   - range: 范围
    /// - Returns: 结果
    func foregroundColor(_ color: UIColor,
                         range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.foregroundColor: color], range: range!)
        } else {
            base.addAttributes([.foregroundColor: color], range: NSMakeRange(0, base.string.count))
        }
        return self
    }

    /// 设置背景色
    /// - Parameters:
    ///   - color: 颜色
    ///   - range: 范围
    /// - Returns: 结果
    func backgroundColor(_ color: UIColor,
                         range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.backgroundColor: color], range: range!)
        } else {
            base.addAttributes([.backgroundColor: color], range: NSMakeRange(0, base.string.count))
        }
        return self
    }

    /// 连字符
    /// - Parameters:
    ///   - ligature: 连字符
    ///   - range: 范围
    /// - Returns: 结果
    func ligature(_ style: Style,
                  range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.ligature: style.rawValue], range: range!)
        } else {
            base.addAttributes([.ligature: style.rawValue], range: NSMakeRange(0, base.string.count))
        }
        return self
    }

    /// 设置段落样式
    /// - Parameters:
    ///   - style: 段落样式
    ///   NSMutableParagraphStyle属性
    /// lineSpacing 行间距
    /// paragraphSpacing 段间距
    /// alignment 文本对齐方式：（左，中，右，两端对齐，自然)
    /// firstLineHeadIndent 首行缩进
    /// headIndent 整体缩进(首行除外,首行单独控制)
    /// tailIndent 尾部缩进 实际效果：竖着显示
    /// lineBreakMode UILabel省略号位置 default is byTruncatingTail
    /// minimumLineHeight 最低行高 实际效果：不明
    /// maximumLineHeight 最大行高 实际效果：不明
    /// baseWritingDirection 书写方向 （.natural、.leftToRight、.rightToLeft）
    /// lineHeightMultiple 行高倍数 好像是放大lineSpacing 实际效果：很夸张
    /// paragraphSpacingBefore 段前间距 实际效果：与paragraphSpacing效果一样
    /// hyphenationFactor 连字属性 值分别为0和1 实际效果：不明
    ///   - range: 范围
    /// - Returns: 结果
    func paragraph(_ style: NSParagraphStyle,
                   range: NSRange?=nil) -> Self
    {
        if range != nil {
            base.addAttributes([.paragraphStyle: style], range: range!)
        } else {
            base.addAttributes([.paragraphStyle: style], range: NSMakeRange(0, base.string.count))
        }
        return self
    }

    /// 获取操作完成后的富文本
    /// - Returns: 富文本
    func complete() -> Base {
        return base
    }
}
