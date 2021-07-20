//
//  UIImage+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension UIImage {
    //水印位置枚举
    enum WPWaterMarkCorner {
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
    }
   
   /// 添加一个水印
   /// - Parameters:
   ///   - waterMarkImage: 水印图片
   ///   - corner: 水印位置
   ///   - margin: 水印边距
   ///   - alpha: 水印透明度
   /// - Returns: 水印图片
    func wp_waterMarkedImage(waterMarkImage: UIImage , corner: WPWaterMarkCorner = . BottomRight ,
        margin: CGPoint = CGPoint (x: 20, y: 20), alpha: CGFloat = 1) -> UIImage? {
            
        var markFrame = CGRect.init(x: 0, y: 0, width: waterMarkImage.size.width, height: waterMarkImage.size.height)
        let imageSize = self.size

            switch corner{
            case . TopLeft :
                markFrame.origin = margin
            case . TopRight :
                markFrame.origin = CGPoint (x: imageSize.width - waterMarkImage.size.width - margin.x,
                    y: margin.y)
            case . BottomLeft :
                markFrame.origin = CGPoint (x: margin.x,
                    y: imageSize.height - waterMarkImage.size.height - margin.y)
            case . BottomRight :
                markFrame.origin = CGPoint (x: imageSize.width - waterMarkImage.size.width - margin.x,
                    y: imageSize.height - waterMarkImage.size.height - margin.y)
            }

            // 开始给图片添加图片
            UIGraphicsBeginImageContext (imageSize)
            draw(in: CGRect.init(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
            waterMarkImage.draw(in: markFrame, blendMode: .normal, alpha: alpha)
            let waterMarkedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext ()
            
            return waterMarkedImage
    }
}
