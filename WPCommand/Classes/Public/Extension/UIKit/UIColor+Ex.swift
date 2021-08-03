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
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a*255/255)
    }
    
    /// 16进制颜色
    /// - Parameter hexString: 16进制string
    convenience init(_ hexString: String) {
        let hexStringTrim = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexStringTrim)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    /// 随机色
    class var wp_random : UIColor{
        let r = CGFloat(arc4random_uniform(255))
        let g = CGFloat(arc4random_uniform(255))
        let b = CGFloat(arc4random_uniform(255))
        
        return .init(r, g, b, 255)
    }
}

public extension UIColor{
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
    
    /// 颜色转换 偏移时渐变
    /// - Parameters:
    ///   - beginColor: 开始渐变时颜色
    ///   - endColor: 结束渐变最终颜色
    ///   - offset: 到某一个点才开始渐变
    ///   - spacing: 渐变颗粒度
    ///   - beginPoint: 开始渐变点
    ///   - endPoint: 结束渐变点
    ///   - handle: 每一次渐变处理最终的rgb
   static func wp_transfrom(of beginColor:UIColor,
                   to endColor:UIColor,
                   offset:CGPoint,
                   spacing:CGFloat,
                   beginPoint:CGFloat,
                   endPoint:CGFloat,
                   handle:(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat,_ a:CGFloat, _ aa:CGFloat,_ ab:CGFloat)->Void){
        
        let ci = (endPoint - beginPoint) / spacing // 每一次的间距
        let t : CGFloat = 255
        
        let bColorRGB = beginColor.cgColor.components; // 开始颜色RGB
        let eColorRGB = endColor.cgColor.components; // 结束颜色RGB
        
        guard
            let br = bColorRGB?[0],
            let bg = bColorRGB?[1],
            let bb = bColorRGB?[2],
            let ba = bColorRGB?[3],
            let er = eColorRGB?[0],
            let eg = eColorRGB?[1],
            let eb = eColorRGB?[2],
            let ea = eColorRGB?[3]
        else { return }
        
        // 每一次渐变的RGB值
        let R : CGFloat = (br - er) * t / ci
        let G : CGFloat = (bg - eg) * t / ci
        let B : CGFloat = (bb - eb) * t / ci
        let A : CGFloat = (ba - ea) * t / ci
        let viewCi = t / ci; // 每一次btn的透明度
        let Y = offset.y
        
        let currentCi = ((Y-beginPoint) / spacing) > 0 ? ((Y-beginPoint) / spacing) : 0;
        let countCi = (endPoint - beginPoint) / spacing;
        let cR = br * t - currentCi * R
        let cG = bg * t - currentCi * G
        let cB = bb * t - currentCi * B
        let cA = ba * t - currentCi * A
        let alphaA = (t - currentCi * viewCi) / t; // 每一次透明减少的度
        let alphaB = currentCi * viewCi / t
        if (currentCi < countCi) {
            handle(cR,cG,cB,cA,alphaA,alphaB)
        }
    }


}


