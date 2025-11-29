//
//  UIImage+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Photos
import UIKit

public extension WPSpace where Base: UIImage {

    /// 填充颜色
    /// - Parameter color: 颜色
    /// - Returns: 结果
    func fill(_ color: UIColor) -> Base? {
        UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: base.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: base.size.width, height: base.size.height) as CGRect
        guard let CGImg = base.cgImage else { return nil }
        context?.clip(to: rect, mask: CGImg)
        color.setFill()
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image as? Base
    }
    
    /// 比例缩放图片
    /// - Parameter scale: 缩放值
    /// - Returns: 缩放后的图片
    func scale(_ scale: CGFloat) -> UIImage?{
        let size = CGSize(width: base.size.width * scale, height: base.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        base.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    /// 按宽度缩放
    /// - Parameter width: 最大宽度
    /// - Returns: 结果
    func scale(width:CGFloat) -> UIImage? {
        let scale = width / base.size.width
        let size = CGSize(width: base.size.width * scale, height: base.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        base.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    /// 按高度比例缩放
    /// - Parameter height: 最大高度
    /// - Returns: 结果
    func scale(height:CGFloat) -> UIImage? {
        let scale = height / base.size.height
        let size = CGSize(width: base.size.width * scale, height: base.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        base.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    /// 按照尺寸拉伸
    /// - Parameter size: 新尺寸
    /// - Returns: 结果
    func scale(size:CGSize) -> UIImage? {
        let scaleH = size.height / base.size.height
        let scaleW = size.width / base.size.width
        let size = CGSize(width: base.size.width * scaleW, height: base.size.height * scaleH)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        base.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    
    /// 范围拉伸图片
    /// - Parameters:
    ///   - insets: 不被拉伸的边距
    ///   - mode: 拉伸模式
    /// - Returns: 结果
    func resizable(_ insets:UIEdgeInsets,mode:UIImage.ResizingMode = .stretch) -> UIImage {
        return base.resizableImage(withCapInsets: insets, resizingMode: mode)
    }
    
    /// 获取圆角图片
    /// - Parameter radius: 圆角
    /// - Returns: 结果
    func corners(_ radius:CGFloat) -> UIImage? {
        let imageView = UIImageView(image: base)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius

        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage
    }
    
    /// 旋转图片（度数）
    /// - Parameters:
    ///   - degrees: 旋转角度（度）
    ///   - fit: 是否扩大画布以完整容纳旋转后的图片
    ///   - scaleFactor: 图片放大比例
    ///   - backgroundColor: 背景色，nil 表示透明
    ///   - opaque: renderer 是否不透明
    /// - Returns: 旋转后的 UIImage
    func rotated(byDegrees degrees: CGFloat,
                 fit: Bool = true,
                 scaleFactor: CGFloat = 1.0,
                 backgroundColor: UIColor? = nil,
                 opaque: Bool = false) -> UIImage
    {
        /// 归一化角度到 [0, 360)
        func normalizedDegrees(_ degrees: CGFloat) -> CGFloat {
            let result = degrees.truncatingRemainder(dividingBy: 360)
            return result >= 0 ? result : result + 360
        }
        
        let normalized = normalizedDegrees(degrees)
        let radians = normalized * .pi / 180
        return rotated(byRadians: radians,
                       fit: fit,
                       scaleFactor: scaleFactor,
                       backgroundColor: backgroundColor,
                       opaque: opaque)
    }
    
    /// 旋转图片 弧度
    /// - Parameters:
    ///   - degrees: 旋转角度（度）
    ///   - fit: 是否扩大画布以完整容纳旋转后的图片
    ///   - scaleFactor: 图片放大比例
    ///   - backgroundColor: 背景色，nil 表示透明
    ///   - opaque: renderer 是否不透明
    /// - Returns: 旋转后的 UIImage
    func rotated(byRadians radians: CGFloat,
                 fit: Bool = true,
                 scaleFactor: CGFloat = 1.0,
                 backgroundColor: UIColor? = nil,
                 opaque: Bool = false) -> UIImage
    {
        // 原始尺寸按 scaleFactor 放大
        let originalSize = CGSize(width: base.size.width * scaleFactor,
                                  height: base.size.height * scaleFactor)
        
        // 旋转后所需画布大小
        let rect = CGRect(origin: .zero, size: originalSize)
        let rotatedRect = rect.applying(CGAffineTransform(rotationAngle: radians))
        let requiredSize = fit ? CGSize(width: abs(rotatedRect.width),
                                        height: abs(rotatedRect.height)) : originalSize
        
        // 设置 renderer
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = base.scale
        format.opaque = opaque
        
        let renderer = UIGraphicsImageRenderer(size: requiredSize, format: format)
        return renderer.image { context in
            let ctx = context.cgContext
            
            // 填充背景（可选）
            if let bg = backgroundColor {
                ctx.setFillColor(bg.cgColor)
                ctx.fill(CGRect(origin: .zero, size: requiredSize))
            }
            
            // 移动坐标原点到画布中心
            ctx.translateBy(x: requiredSize.width / 2, y: requiredSize.height / 2)
            ctx.rotate(by: radians)
            
            // 绘制图片，注意坐标偏移
            let drawRect = CGRect(x: -originalSize.width / 2,
                                  y: -originalSize.height / 2,
                                  width: originalSize.width,
                                  height: originalSize.height)
            base.draw(in: drawRect)
        }
    }
    
    /// 水平翻转（左右翻转）
    func flippedHorizontally() -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = base.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: base.size, format: format)
        return renderer.image { context in
            let ctx = context.cgContext
            
            // 左右翻转 x 轴
            ctx.translateBy(x: base.size.width, y: 0)
            ctx.scaleBy(x: -1, y: 1)
            
            // 绘制原图
            base.draw(in: CGRect(origin: .zero, size: base.size))
        }
    }
    
    /// 垂直翻转（上下镜像）
    func flippedVertically() -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = base.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: base.size, format: format)
        return renderer.image { context in
            let ctx = context.cgContext
            
            // 上下翻转 y 轴
            ctx.translateBy(x: 0, y: base.size.height)
            ctx.scaleBy(x: 1, y: -1)
            
            // 绘制原图
            base.draw(in: CGRect(origin: .zero, size: base.size))
        }
    }
}

public extension WPSpace where Base: UIImage{
    /// 图片二维码内容
    var qrStr: String? {
        guard let ciImage = CIImage(image: base) else {
            return nil
        }
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        if let results = detector?.features(in: ciImage) {
            for result in results {
                let qrCodeResult = result as? CIQRCodeFeature
                return qrCodeResult?.messageString
            }
        }
        return nil
    }
}

public extension UIImage{
    // 水印位置枚举
    enum WaterMarkCorner {
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
    }
}
public extension WPSpace where Base: UIImage {
    /// 添加一个水印
    /// - Parameters:
    ///   - waterMarkImage: 水印图片
    ///   - corner: 水印位置
    ///   - margin: 水印边距
    ///   - alpha: 水印透明度
    /// - Returns: 水印图片
    func waterMarkedImage(waterMarkImage: UIImage, corner: UIImage.WaterMarkCorner = .BottomRight,
                          margin: CGPoint = CGPoint(x: 20, y: 20), alpha: CGFloat = 1) -> UIImage?
    {
        var markFrame = CGRect(x: 0, y: 0, width: waterMarkImage.size.width, height: waterMarkImage.size.height)
        let imageSize = base.size

        switch corner {
        case .TopLeft:
            markFrame.origin = margin
        case .TopRight:
            markFrame.origin = CGPoint(x: imageSize.width - waterMarkImage.size.width - margin.x,
                                       y: margin.y)
        case .BottomLeft:
            markFrame.origin = CGPoint(x: margin.x,
                                       y: imageSize.height - waterMarkImage.size.height - margin.y)
        case .BottomRight:
            markFrame.origin = CGPoint(x: imageSize.width - waterMarkImage.size.width - margin.x,
                                       y: imageSize.height - waterMarkImage.size.height - margin.y)
        }

        // 开始给图片添加图片
        UIGraphicsBeginImageContext(imageSize)
        base.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        waterMarkImage.draw(in: markFrame, blendMode: .normal, alpha: alpha)
        let waterMarkedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return waterMarkedImage
    }
}

public extension WPSpace where Base: UIImage {
    /// image转PHAsset
    var PHAsset: PHAsset? {
        var localId: String?

        try? PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: base)
            localId = request.placeholderForCreatedAsset?.localIdentifier
        }

        if localId != nil {
            let result = Photos.PHAsset.fetchAssets(withLocalIdentifiers: [localId!], options: nil)
            return result.firstObject
        } else {
            return nil
        }
    }

    /// 保存图片到集合
    /// - Parameters:
    ///   - collection: 集合 == 相册
    ///   - complete: 完成回调
    func saveTo(_ collection: PHAssetCollection, complete: ((Bool, PHAsset?, Error?) -> Void)?) {
        if let asset = PHAsset {
            WPSystem.isOpenAlbum(open: {
                let arr = [asset]
                PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetCollectionChangeRequest(for: collection)
                    request?.addAssets(arr as NSFastEnumeration)
                } completionHandler: { isSuccess, error in
                    DispatchQueue.main.async {
                        complete?(isSuccess, asset, error)
                    }
                }
            }, close: {
                let error = NSError(domain: "没有相册权限", code: -101, userInfo: nil) as Error
                complete?(false, nil, error)
            })
        } else {
            let error = NSError(domain: "图片转换失败", code: -100, userInfo: nil) as Error
            complete?(false, nil, error)
        }
    }

    /// 转换成phasset
    /// - Parameter img: 图片
    /// - Returns: 结果
    static func asset(_ img: UIImage) -> PHAsset? {
        var localId: String?

        try? PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: img)
            localId = request.placeholderForCreatedAsset?.localIdentifier
        }

        if localId != nil {
            let result = Photos.PHAsset.fetchAssets(withLocalIdentifiers: [localId!], options: nil)
            return result.firstObject
        } else {
            return nil
        }
    }
}

public extension UIImage{
    /// 合并图片大小
    enum MergeSize {
        /// 自定义大小
        case size(_ size: CGSize)
        /// 原图图片大小
        case normal
    }

    struct Item {
        /// 图片
        public var image: UIImage
        /// 图片矩型
        public var rect: CGRect = .zero
        /// 透明度
        public var alpha: CGFloat = 1
        /// 初始图片
        /// - Parameter image: 图片
        /// - Parameter alpha: 透明度
        public init(_ image: UIImage, alpha: CGFloat = 1) {
            self.image = image
            self.rect.size = image.size
            self.alpha = 1
        }

        /// 初始化图片item
        /// - Parameters:
        ///   - image: 原图
        ///   - rect: 矩型
        ///   - alpha: 透明度
        public init(_ image: UIImage, rect: CGRect, alpha: CGFloat = 1) {
            self.image = image
            self.rect = rect
            self.alpha = 1
        }
    }
}

public extension WPSpace where Base: UIImage {
    /// 合并图片
    /// - Parameters:
    ///   - items: 图片组
    ///   - size: 生成的图片大小
    /// - Returns: 图片
    static func merge(_ items: [UIImage.Item], size: CGSize) -> Base {
        return UIImage().wp.merge(items, size: .size(size)) as! Base
    }

    /// 合并图片
    /// - Parameters:
    ///   - items: 图片
    ///   - size: 图片大小
    /// - Returns: 返回图片
    func merge(_ items: [UIImage.Item], size: UIImage.MergeSize = .normal) -> Base {
        var imageSize: CGSize = .init(width: 0, height: 0)
        switch size {
        case .normal:
            imageSize = base.size
        case .size(let size):
            imageSize = size
        }
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        base.draw(in: .init(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        items.forEach { elmt in
            elmt.image.draw(in: elmt.rect, blendMode: .normal, alpha: elmt.alpha)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image as! Base
    }
}
