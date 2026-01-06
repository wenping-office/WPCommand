//
//  VideoCell.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class VideoCell: WPBaseCollectionViewCell {
    lazy var videoView = UIView()
    lazy var coverImageView = UIImageView()
    var loadingView = UIActivityIndicatorView()
    
    var videoVo:VideoVo!
    
    override func initSubView() {

        coverImageView.backgroundColor = .blue

        contentView.addSubview(videoView)
        contentView.addSubview(coverImageView)
        contentView.addSubview(loadingView)

    }
    
    override func initSubViewLayout() {
        super.initSubViewLayout()
        
        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.center.equalToSuperview()
        }
    }
    
    func willDisplay() {
        coverImageView.isHidden = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 测试代码
//        if VideoPlayerManager.shared.cell === self {
//            print("释放上一个资源")
//            VideoPlayerManager.shared.releaseLayer()
//        }
        coverImageView.isHidden = false
        loadingView.isHidden = false
        wp.cancellables.set.removeAll()

        loadingView.startAnimating()
    }
}
