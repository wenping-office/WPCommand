//
//  UILabel+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension WPSpace where Base: UILabel {
    /// 判断文本标签的内容是否被截断
    var isTruncated: Bool {
        guard let labelText = base.text else {
            return false
        }

        // 计算理论上显示所有文字需要的尺寸
        let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelTextSize = (labelText as NSString)
            .boundingRect(with: rect, options: .usesLineFragmentOrigin,
                          attributes: [NSAttributedString.Key.font: base.font ?? .systemFont(ofSize: 17)], context: nil)

        // 计算理论上需要的行数
        let labelTextLines = Int(ceil(CGFloat(labelTextSize.height) / base.font.lineHeight))

        // 实际可显示的行数
        var labelShowLines = Int(floor(CGFloat(bounds.size.height) / base.font.lineHeight))
        if base.numberOfLines != 0 {
            labelShowLines = min(labelShowLines, base.numberOfLines)
        }

        // 比较两个行数来判断是否需要截断
        return labelTextLines > labelShowLines
    }
}

public extension WPSpace where Base: UILabel {
    @discardableResult
    func text(_ text: String?) -> Self {
        base.text = text
        return self
    }
    
    @discardableResult
    func attText(_ text: NSAttributedString?) -> Self {
        base.attributedText = text
        return self
    }
    
    @discardableResult
    func attText(_ text: WPSpace<NSAttributedString>?) -> Self {
        return attText(text?.base)
    }
    
    @discardableResult
    func attText(_ text: WPSpace<NSMutableAttributedString>?) -> Self {
        return attText(text?.base)
    }
    
    @discardableResult
    func font(_ font: UIFont) -> Self {
        base.font = font
        return self
    }
    
    @discardableResult
    func textColor(_ color: UIColor) -> Self {
        base.textColor = color
        return self
    }
    
    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        base.textAlignment = alignment
        return self
    }

    @discardableResult
    func numberOfLines(_ lines: Int) -> Self {
        base.numberOfLines = lines
        return self
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjusts: Bool) -> Self {
        base.adjustsFontSizeToFitWidth = adjusts
        return self
    }
    
    @discardableResult
    func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
        base.lineBreakMode = lineBreakMode
        return self
    }
    
    @discardableResult
    func highlightedTextColor(_ color: UIColor?) -> Self {
        base.highlightedTextColor = color
        return self
    }
    
    @discardableResult
    func isEnabled(_ enabled: Bool) -> Self {
        base.isEnabled = enabled
        return self
    }
    
    @discardableResult
    func baselineAdjustment(_ baselineAdjustment: UIBaselineAdjustment) -> Self {
        base.baselineAdjustment = baselineAdjustment
        return self
    }
    
    @discardableResult
    func minimumScaleFactor(_ minimumScaleFactor: CGFloat) -> Self {
        base.minimumScaleFactor = minimumScaleFactor
        return self
    }
    
    @discardableResult
    func preferredMaxLayoutWidth(_ preferredMaxLayoutWidth: CGFloat) -> Self {
        base.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        return self
    }
    
    @discardableResult
    func showsExpansionTextWhenTruncated(_ showsExpansionTextWhenTruncated: Bool) -> Self {
        base.showsExpansionTextWhenTruncated = showsExpansionTextWhenTruncated
        return self
    }
    
    @discardableResult
    func allowsDefaultTighteningForTruncation(_ allowsDefaultTighteningForTruncation: Bool) -> Self {
        base.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
        return self
    }
    
    @available(iOS 14.0, *)
    @discardableResult
    func lineBreakStrategy(_ lineBreakStrategy: NSParagraphStyle.LineBreakStrategy) -> Self {
        base.lineBreakStrategy = lineBreakStrategy
        return self
    }
    
    @available(iOS 17.0, *)
    @discardableResult
    func preferredVibrancy(_ preferredVibrancy: UILabelVibrancy) -> Self {
        base.preferredVibrancy = preferredVibrancy
        return self
    }
}
