//
//  FileManager+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2022/2/10.
//

import UIKit

public extension WPSpace where Base == FileManager{

    /// 文档路径
    static var documentsDirectory : URL{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    ///
    static var libraryDirectory : URL{
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first!
    }

    /// 零时文件夹
    static var tempDirectory : URL {
        return FileManager.default.temporaryDirectory
    }
    
    /// 缓存文件夹
    static var librayCaches : URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask).first!
    }
    
    /// 获取缓存大小
    static func cacheSize(complete: ((String) -> Void)?) {
        DispatchQueue.global().async {
            // cache文件夹
            let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
            // 文件夹下所有文件
            let files = FileManager.default.subpaths(atPath: cachePath!)!
            // 遍历计算大小
            var size = 0
            for file in files {
                // 文件名拼接到路径中
                let path = cachePath! + "/\(file)"
                // 取出文件属性
                do {
                    let floder = try FileManager.default.attributesOfItem(atPath: path)
                    for (key, fileSize) in floder {
                        // 累加
                        if key == FileAttributeKey.size {
                            size += (fileSize as AnyObject).integerValue
                        }
                    }
                } catch {
                    WPDLog("出错了！")
                }
            }
            let totalSize = Double(size)/1024.0/1024.0/1000.0
            DispatchQueue.main.async {
                complete?(String(format: "%.1fM", totalSize))
            }
        }
    }
    
    /// 清除缓存
    static func clearCache(complete: (() -> Void)?) {
        // cache文件夹
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        // 文件夹下所有文件
        let files = FileManager.default.subpaths(atPath: cachePath!)!
        // 遍历删除
        for file in files {
            // 文件名
            let path = cachePath! + "/\(file)"
            // 存在就删除
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    WPDLog("出错了！")
                }
            }
        }
        complete?()
        NSCache<AnyObject, AnyObject>().removeAllObjects()
    }
}

