//
//  PHAssetCollection+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/1.
//

import Photos

public extension WPSpace where Base: PHAssetCollection {
    /// 系统所有相册
    static var AllAssetCollection: PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
    }
    
    /// 系统默认相册
    static var defautAssetCollection: PHAssetCollection {
        return AllAssetCollection.firstObject!
    }
    
    /// 获取系统相册所有符合类型的媒体资源
    /// - Parameter types: 媒体类型
    /// - Parameter condition: 自定义条件 true 为添加  false 为过滤
    /// - Returns: 结果
    static func allMedia(in types: [PHAssetMediaType],
                         condition: ((PHAsset)->Bool)? = nil)->[PHAsset]
    {
        var kes: [PHAssetMediaType: Any] = [:]
        types.forEach { elmt in
            kes[elmt] = ""
        }
        var source: [PHAsset] = []
        PHAssetCollection.wp.AllAssetCollection.enumerateObjects { collection, _, _ in
            source.append(contentsOf: collection.wp.media(in: types, condition: condition))
        }
        return source
    }
    
    /// 创建一个相册
    /// - Parameters:
    ///   - title: 相册标题
    ///   - success: 成功
    ///   - failed: 失败
    static func create(_ title: String, success: @escaping (PHAssetCollection, String)->Void, failed: ((Error?)->Void)? = nil) {
        var identifier: String = ""
        var collection: PHAssetCollection?
        PHPhotoLibrary.shared().performChanges({
            identifier = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title).placeholderForCreatedAssetCollection.localIdentifier
        }, completionHandler: { _, error in
            collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [identifier], options: nil).firstObject
            DispatchQueue.main.async {
                if collection != nil {
                    success(collection!, identifier)
                } else {
                    failed?(error)
                }
            }
        })
    }
    
    /// 获取一个自定义相册
    /// - Parameter identifier: 相册唯一标识
    /// - Returns: 结果
    static func get(in identifier: String)->PHAssetCollection? {
        return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [identifier], options: nil).firstObject
    }
    
    /// 获取当前相册下的资源
    /// - Parameter type: 媒体类型
    /// - Parameter condition: 自定义条件 true 为添加  false 为过滤
    /// - Returns: 结果
    func media(in types: [PHAssetMediaType],
               condition: ((PHAsset)->Bool)? = nil)->[PHAsset]
    {
        var kes: [PHAssetMediaType: Any] = [:]
        types.forEach { elmt in
            kes[elmt] = ""
        }
        var source: [PHAsset] = []
        let fetchResult = Photos.PHAsset.fetchAssets(in: base, options: nil)
        fetchResult.enumerateObjects { asset, _, _ in
            if condition != nil {
                if kes[asset.mediaType] != nil, condition!(asset) {
                    source.append(asset)
                }
            } else {
                if kes[asset.mediaType] != nil {
                    source.append(asset)
                }
            }
        }
        return source
    }
}
