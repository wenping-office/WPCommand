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
    // 水印位置枚举
    enum WaterMarkCorner {
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
    func waterMarkedImage(waterMarkImage: UIImage, corner: WaterMarkCorner = .BottomRight,
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
            let arr = [asset]

            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCollectionChangeRequest(for: collection)
                request?.addAssets(arr as NSFastEnumeration)
            } completionHandler: { isSuccess, error in
                WPGCD.main_Async {
                    complete?(isSuccess, asset, error)
                }
            }
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
