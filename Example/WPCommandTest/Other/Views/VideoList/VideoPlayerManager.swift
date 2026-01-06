//
//  VideoPlayerManager.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
import WPCommand
import Combine

class VideoPlayerManager:NSObject {
    static let shared = VideoPlayerManager()
    private var avPlayer = AVPlayer()
    private var avPlayerLayer: AVPlayerLayer?
    private var avItem: AVPlayerItem?
    private var retryCount = 0
    private let maxRetry = 3
    var cell: VideoCell?
    private var playerTimeObserver: Any?
    
    private override init() { }
    
    /// 播放指定 cell 的视频
    func play(to cell: VideoCell) {
        // 如果当前在同一个 cell，不重复创建
        if cell === self.cell {
//            play()
            return
        }
        cell.loadingView.isHidden = false
        cell.loadingView.startAnimating()
        
        // 释放上一个
        releaseLayer()

        // 创建播放器
        if avPlayerLayer == nil {
            avPlayerLayer = .init(player: avPlayer)
            avPlayerLayer?.videoGravity = .resizeAspectFill
        }
        
        let item = AVPlayerItem.init(url: cell.videoVo.proxyVideoUrl)
        self.avItem = item
        avPlayer.replaceCurrentItem(with: item)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if cell.videoVo.itVerticalMedia(){
            avPlayerLayer?.videoGravity = .resizeAspectFill
        }else{
            avPlayerLayer?.videoGravity = .resizeAspect
        }
        avPlayerLayer?.frame = cell.videoView.bounds
        CATransaction.commit()
        cell.videoView.layer.addSublayer(avPlayerLayer!)
        observePlayerState(cell: cell)
        play()
        self.cell = cell
    }
    
    func observePlayerState(cell:VideoCell){
        wp.cancellables.set.removeAll()
        if let item = avItem{
            item.publisher(for: \.status)
                .combineLatest(
                    item.publisher(for: \.isPlaybackLikelyToKeepUp),
                    item.publisher(for: \.isPlaybackBufferEmpty)
                )
                .receive(on: DispatchQueue.main)
                .sink { status, likelyToKeepUp, isBufferEmpty in
                    if status == .failed || status == .unknown {
                        cell.coverImageView.isHidden = false
//                        cell.loadingView.isHidden = true
                        if status == .failed{
                            self.handleLoadFailed(cell: cell)
                        }

                    } else if status == .readyToPlay {
                        // 缓冲不足时仍显示封面
                        if isBufferEmpty || !likelyToKeepUp {
                            cell.coverImageView.isHidden = false
                            cell.loadingView.isHidden = false
                            cell.loadingView.startAnimating()
                        } else {
                            cell.coverImageView.isHidden = true
                            cell.loadingView.isHidden = true
                            cell.loadingView.stopAnimating()
                        }
                    }
                }
                .store(in: &wp.cancellables.set)
            
            NotificationCenter.default
                .publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    // 循环播放
                    self.avPlayer.seek(to: .zero)
                    self.avPlayer.play()
                }
                .store(in: &wp.cancellables.set)
            
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink(receiveValue: {[weak self] _ in
                if UIViewController.wp.current is VideoVC{
                    self?.play()
                }
            }).store(in: &wp.cancellables.set)
            
            playerTimeObserver = avPlayer.addPeriodicTimeObserver(
                forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                queue: .main
            ) {[weak self] time in
                guard let self else { return }
                let current = CMTimeGetSeconds(time)
                let total = CMTimeGetSeconds(self.avPlayer.currentItem?.duration ?? .zero)
//                self.cell?.template.videoStatus.total = total
//                self.cell?.template?.videoStatus.currentPlayProgress = current
//                self.cell?.progressView.progress = self.cell!.template.videoStatus.progress()
            }
        }
    }

    private func handleLoadFailed(cell:VideoCell) {
        guard retryCount < maxRetry, let _ = avItem?.asset as? AVURLAsset else {
            cell.coverImageView.isHidden = false // 显示封面
            return
        }

        retryCount += 1
        let item = AVPlayerItem.init(url: cell.videoVo.proxyVideoUrl)
        avPlayer.replaceCurrentItem(with: item)
        observePlayerState(cell: cell)
    }
    
    func play(){
        avPlayer.play()
    }
    
    func pause(){
        avPlayer.pause()
    }
    
    func releaseLayer() {
        pause()
        removePlayerObserver()
        cell?.coverImageView.isHidden = false
        avPlayerLayer?.removeFromSuperlayer()
        avPlayer.replaceCurrentItem(with: nil)
        wp.cancellables.set.removeAll()
        self.cell = nil
    }

    func removePlayerObserver() {
        if let observer = playerTimeObserver {
            avPlayer.removeTimeObserver(observer)
            playerTimeObserver = nil
        }
    }
}

