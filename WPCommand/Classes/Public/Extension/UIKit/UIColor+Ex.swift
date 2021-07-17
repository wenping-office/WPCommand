//
//  UIColor+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension UIColor{
    /// 返回一个颜色
    /// - Parameters:
    ///   - r:红色
    ///   - g:绿色
    ///   - b:蓝色
    ///   - a:透明度
    convenience init(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat,_ a:CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a/255)
    }

    /// 随机色
    class var wp_random : UIColor{
        let r = CGFloat(arc4random_uniform(255))
        let g = CGFloat(arc4random_uniform(255))
        let b = CGFloat(arc4random_uniform(255))
        return .init(r, g, b, 1)
    }
    
    /// 转换成图片
    /// - Returns: 图片
    func image(size:CGSize = .init(width: 1, height: 1)) -> UIImage?{
        let rect = CGRect(x:0,y:0,width:size.width,height:size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
