//
//  KTVHTTPCacheManager.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import KTVHTTPCache

// 单例批量视频预加载管理器（支持本地缓存检测）
class VideoPreloader {

    static let shared = VideoPreloader() // 单例
    
    /// 视频 URL 队列
    private var urlQueue: [URL] = []
    
    /// 已添加 / 已缓存的 URL 集合，用于去重
    private var urlSet: Set<URL> = []
    
    /// 并发数量
    private let maxConcurrentTasks: Int
    
    /// 当前正在下载的任务数
    private var currentTasks: Int = 0
    
    /// 下载完成回调
    var onProgress: ((URL, Bool) -> Void)?  // URL + 是否成功
    
    /// 初始化
    private init(maxConcurrentTasks: Int = 2) {
        self.maxConcurrentTasks = maxConcurrentTasks
        // 启动 KTVHTTPCache 代理
        try? KTVHTTPCache.proxyStart()
    }
    
    /// 添加需要预加载的视频，自动去重 + 自动过滤已缓存
    func add(urls: [URL]) {
        let filteredURLs = urls.filter { url in
            // 去重 + 本地缓存检查
            if urlSet.contains(url) { return false }
            if isCached(url: url) { return false } // 已缓存，跳过
            return true
        }
        
        guard !filteredURLs.isEmpty else { return }
        
        urlQueue.append(contentsOf: filteredURLs)
        urlSet.formUnion(filteredURLs)
        
        startNextTasks()
    }
    
    /// 开始下载队列中的下一个任务
    private func startNextTasks() {
        while currentTasks < maxConcurrentTasks, !urlQueue.isEmpty {
            let url = urlQueue.removeFirst()
            preload(url: url)
        }
    }
    
    /// 预加载单个视频
    private func preload(url: URL) {
        guard let proxyURL = KTVHTTPCache.proxyURL(withOriginalURL: url) else {
            onProgress?(url, false)
            startNextTasks()
            return
        }
        currentTasks += 1
        let task = URLSession.shared.dataTask(with: proxyURL) { [weak self] _, _, error in
            guard let self = self else { return }
            
            if let error = error {
                print("预加载失败: \(url.lastPathComponent), error: \(error)")
                // 可重试一次
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    self.urlQueue.append(url)
                    self.currentTasks -= 1
                    self.startNextTasks()
                }
                self.onProgress?(url, false)
            } else {
                print("预加载成功: \(url.lastPathComponent)")
                self.currentTasks -= 1
                self.startNextTasks()
                self.onProgress?(url, true)
            }
        }
        
        task.resume()
    }
    
    /// 检查单个 URL 是否有本地缓存
    func isCached(url: URL) -> Bool {
        if let path = KTVHTTPCache.cacheCompleteFileURL(with: url),
           FileManager.default.fileExists(atPath: path.path) {
            return true
        }
        return false
    }
    
    /// 队列是否为空
    var isEmpty: Bool {
        return urlQueue.isEmpty && currentTasks == 0
    }
    
    /// 重置缓存管理器
    func reset() {
        urlQueue.removeAll()
        urlSet.removeAll()
        currentTasks = 0
    }
}

