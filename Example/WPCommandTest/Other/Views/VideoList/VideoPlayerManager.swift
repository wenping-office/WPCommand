//
//  VideoPlayerManager.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

/// 单例播放器管理器，复用 SZAVPlayer
class VideoPlayerManager:NSObject {
    static let shared = VideoPlayerManager()
    
    private var player = AVPlayer()
    private var playerLayer: AVPlayerLayer?
    private var currentItem: AVPlayerItem?
    private var retryCount = 0
    private let maxRetry = 3
    
    var currentCell: VideoCell?
    var currentModel:VideoVo?


    private override init() { }
    
    /// 播放指定 cell 的视频
    func playVideo(for cell: VideoCell, model: VideoVo) {

        // 如果当前在同一个 cell，不重复创建
        if currentCell === cell {
            return
        }
        
        // 释放上一个
        releaseCurrentPlayer()

        // 创建播放器
        if playerLayer == nil {
            playerLayer = .init(player: player)
            playerLayer?.videoGravity = .resizeAspect
            
            let item = AVPlayerItem.init(url: model.url)
            player.replaceCurrentItem(with: item)
            self.currentItem = item
            
        }else{
            let item = AVPlayerItem.init(url: model.url)
            self.currentItem = item
            player.replaceCurrentItem(with: item)
        }
        playerLayer?.frame = UIScreen.main.bounds

        cell.videoView.layer.addSublayer(playerLayer!)
        
        obserableStatus(cell: cell)

        play()

        self.currentCell = cell
        self.currentModel = model
    }
    
    func obserableStatus(cell:VideoCell){
        wp.cancellables.set.removeAll()

        if let item = currentItem{
            item.publisher(for: \.status)
                .combineLatest(
                    item.publisher(for: \.isPlaybackLikelyToKeepUp),
                    item.publisher(for: \.isPlaybackBufferEmpty)
                )
                .receive(on: DispatchQueue.main)
                .sink { status, likelyToKeepUp, isBufferEmpty in
                    if status == .failed || status == .unknown {
                        cell.coverImageView.isHidden = false
                        cell.loadingView.isHidden = true
                        if status == .failed{
                            self.handleLoadFailed(cell: cell)
                        }

                    } else if status == .readyToPlay {
                        // 缓冲不足时仍显示封面
                        if isBufferEmpty || !likelyToKeepUp {
                            cell.coverImageView.isHidden = false
                            cell.loadingView.isHidden = false
                        } else {
                            cell.coverImageView.isHidden = true
                            cell.loadingView.isHidden = true
                        }
                    }
                }
                .store(in: &wp.cancellables.set)
            
            NotificationCenter.default
                .publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    // 循环播放
                    self.player.seek(to: .zero)
                    self.player.play()
                }
                .store(in: &wp.cancellables.set)
        }
    }
    
   

    private func handleLoadFailed(cell:VideoCell) {
        guard retryCount < maxRetry, let url = currentItem?.asset as? AVURLAsset else {
            print("重试次数用完，加载失败")
            cell.coverImageView.isHidden = false // 显示封面
            return
        }

        retryCount += 1
        print("重试第 \(retryCount) 次")

        // 重新创建 AVPlayerItem
        if let url = currentModel?.url{
            let item = AVPlayerItem.init(url: url)
            player.replaceCurrentItem(with: item)
        }
        obserableStatus(cell: cell)
    }
    
    func play(){
        player.play()
    }
    
    func pause(){
        player.pause()
    }
    
    /// 暂停/释放当前播放器
    func releaseCurrentPlayer() {
        pause()
        playerLayer?.removeFromSuperlayer()
        player.replaceCurrentItem(with: nil)
        self.currentCell = nil
    }

}
