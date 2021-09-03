//
//  PHAsset+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/1.
//

import Photos

public extension PHAsset{
    
    /// 转换成图片data
    /// - Parameters:
    ///   - option: 取出图片的方式
    ///   - complete: 结果
    func wp_imageData(in option:PHImageRequestOptions? ,
                      resultHandler:@escaping(Data?,String?,UIImage.Orientation,[AnyHashable:Any]?)->Void){
        let imageManager = PHImageManager.default()
        imageManager.requestImageData(for: self, options: option) { data, str, orientation, info in
            WPGCD.main_Async {
                resultHandler(data,str,orientation,info)
            }
        }
    }
    
    /// 转换成图片
    /// - Parameters:
    ///   - size: 图片大小
    ///   - contentMode: 图片内容模式
    ///   - option: 选项
    ///   - resultHandler: 结果
    func wp_image(in size:CGSize,
                  contentMode:PHImageContentMode,
                  option:PHImageRequestOptions?,
                  resultHandler:@escaping(UIImage?,[AnyHashable:Any]?)->Void) {
        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: self, targetSize: size, contentMode: contentMode, options: option) { img, info in
            WPGCD.main_Async {
                resultHandler(img,info)
            }
        }
    }
    
    /// 获取源图
    /// - Parameter complete: 结果
    func wp_orginImage(_ complete:@escaping(Data?,String?,UIImage.Orientation,[AnyHashable:Any]?)->Void){
        let option = PHImageRequestOptions()
        // 只返回一次结果
        option.isSynchronous = true
        // 缩略图的压缩模式设置为无
        option.resizeMode = .none
        // 缩略图的质量为高质量，不管加载时间花多少
        option.deliveryMode = .highQualityFormat
        
        wp_imageData(in: option, resultHandler: complete)
    }
    
    
    /// 获取一张缩略图
    /// - Parameters:
    ///   - size: 尺寸
    ///   - contentModel: 内容模式
    ///   - complete: 结果
    func wp_placeholderImage(in size:CGSize,
                             contentModel:PHImageContentMode,
                             complete:@escaping(UIImage?,[AnyHashable:Any]?)->Void){

        // 新建一个PHImageRequestOptions对象
        let option = PHImageRequestOptions()
        // PHImageRequestOptions是否有效
        option.isSynchronous = true
        // 缩略图的压缩模式设置为无
        option.resizeMode = .none
        // 缩略图的质量为高质量，不管加载时间花多少
        option.deliveryMode = .fastFormat
        wp_image(in: size, contentMode: contentModel, option: option, resultHandler: complete)
    }
    
    /// 从系统相册中删除
    /// - Parameter complete: 结果
    func wp_delete(complete:@escaping(Bool,Error?)->Void){
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets([self] as NSFastEnumeration)
        } completionHandler: { success, error in
            WPGCD.main_Async {
                complete(success,error)
            }
        }
    }
}
