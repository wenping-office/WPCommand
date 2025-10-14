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
                    print("出错了！")
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
                    print("出错了！")
                }
            }
        }
        complete?()
        NSCache<AnyObject, AnyObject>().removeAllObjects()
    }
}


/*
 enum YPDirectories {
     case documents
     case library
     case libraryCaches
     case temp
 }


 class YPFileManager: NSObject {
     
     static let shared = YPFileManager()
     
     //四种路径
     func documentsDirectoryURL() -> URL {
         return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
     }
     
     func libraryDirectoryURL() -> URL {
         return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first!
     }
     
     func tempDirectoryURL() -> URL {
         return FileManager.default.temporaryDirectory
     }
     
     func librayCachesURL() -> URL {
         return FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask).first!
     }
     
     func setupFilePath(directory: YPDirectories, name: String) -> URL {
         return getURL(for: directory).appendingPathComponent(name)
     }
     
     func getURL(for directory: YPDirectories) -> URL {
         switch directory {
         case .documents:
             return documentsDirectoryURL()
         case .libraryCaches:
             return librayCachesURL()
         case .library:
             return libraryDirectoryURL()
         case .temp:
             return tempDirectoryURL()
         }
     }
     
     /// 创建文件夹
     /// - Parameters:
     ///   - basePath: 文件夹所在主目录
     ///   - folderName: 文件夹名字或路径 -- name or folder1/folder2/name
     ///   - createIntermediates: 如果没有对应文件，是否需要创建
     ///   - attributes: attributes
     func createFolder(basePath: YPDirectories, folderName:String, createIntermediates: Bool = true, attributes: [FileAttributeKey : Any]? = nil) -> Bool {
         let filePath = setupFilePath(directory: basePath, name: folderName)
         do {
             try FileManager.default.createDirectory(atPath:filePath.path, withIntermediateDirectories: createIntermediates, attributes: attributes)
             return true
         } catch {
             return false
         }
     }
     
     /// 写
     /// - Parameters:
     ///   - content: 写入内容
     ///   - filePath: 文件路径
     ///   - options: options
     func writeFile(content: Data, filePath: URL, options: Data.WritingOptions = []) -> Bool {
         do {
             try content.write(to: filePath, options: options)
             return true
         } catch {
             return false
         }
     }
     
     /// 读
     /// - Parameter filePath: 文件路径
     func readFile(filePath: URL) -> Data? {
         let fileContents = FileManager.default.contents(atPath: filePath.path)
         if fileContents?.isEmpty == false {
             return fileContents
         } else {
             return nil
         }
     }
     
     /// 删
     /// - Parameter filePath: 文件路径
     func deleteFile(filePath: URL) -> Bool {
         do {
             try FileManager.default.removeItem(at: filePath)
             return true
         } catch {
             return false
         }
     }
     
     /// 移动
     /// - Parameters:
     ///   - formFileName: 文件/或路径 -- name or folder1/folder2/name
     ///   - fromDirectory: 来源
     ///   - toFileName: 文件/或路径 -- name or folder1/folder2/name
     ///   - toDirectory: 目标
     func moveFile(formFileName: String, fromDirectory: YPDirectories, toFileName: String, toDirectory: YPDirectories) -> Bool {
         let originURL = setupFilePath(directory: fromDirectory, name: formFileName)
         let destinationURL = setupFilePath(directory: toDirectory, name: toFileName)
         do {
             try FileManager.default.moveItem(at: originURL, to: destinationURL)
             return true
         } catch {
             return false
         }
     }
     
     /// 拷贝
     /// - Parameters:
     ///   - fileName: 文件/或路径 -- name or folder1/folder2/name
     ///   - fromDirectory: 来源
     ///   - toDirectory: 目标
     func copyFile(fileName: String, fromDirectory: YPDirectories, toDirectory: YPDirectories) throws {
         let originURL = setupFilePath(directory: fromDirectory, name: fileName)
         let destinationURL = setupFilePath(directory: toDirectory, name: fileName)
         return try FileManager.default.copyItem(at: originURL, to: destinationURL)
     }
     
     /// 是否存在
     /// - Parameter filePath: 路径
     func exists(filePath: String) -> Bool {
         if FileManager.default.fileExists(atPath: filePath) {
             return true
         } else {
             return false
         }
     }
     
     /// 是否可写
     /// - Parameter fileURL: 完整路径
     func isWritable(fileURL: String) -> Bool {
         if FileManager.default.isWritableFile(atPath: fileURL) {
             return true
         } else {
             return false
         }
     }
     
     /// 是否可读
     /// - Parameter filePath: 完整路径
     func isReadable(filePath: String) -> Bool {
         if FileManager.default.isReadableFile(atPath: filePath) {
             return true
         } else {
             return false
         }
     }
     
 }
*/
