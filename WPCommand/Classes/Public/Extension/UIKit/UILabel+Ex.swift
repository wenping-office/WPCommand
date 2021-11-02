//
//  UILabel+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension WPSpace where Base : UILabel{

    ///判断文本标签的内容是否被截断
    var isTruncated: Bool {
        guard let labelText = base.text else {
            return false
        }

        //计算理论上显示所有文字需要的尺寸
        let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelTextSize = (labelText as NSString)
            .boundingRect(with: rect, options: .usesLineFragmentOrigin,
                          attributes: [NSAttributedString.Key.font: base.font ?? .systemFont(ofSize: 17)], context: nil)

        //计算理论上需要的行数
        let labelTextLines = Int(ceil(CGFloat(labelTextSize.height) / base.font.lineHeight))

        //实际可显示的行数
        var labelShowLines = Int(floor(CGFloat(bounds.size.height) / base.font.lineHeight))
        if base.numberOfLines != 0 {
            labelShowLines = min(labelShowLines, base.numberOfLines)
        }

        //比较两个行数来判断是否需要截断
        return labelTextLines > labelShowLines
    }

}
