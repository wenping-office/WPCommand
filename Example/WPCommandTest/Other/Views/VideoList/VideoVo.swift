//
//  VideoVo.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import KTVHTTPCache

extension Array:ListStoreSource where Element == VideoVo{
    func pageList() -> [Element] {
        return self
    }
    
    typealias Data = Element
    func lastIdString() -> String {
        return "0"
    }
}

struct VideoVo:Codable,Equatable {
    let id:Int
    let url:URL
    
    var proxyVideoUrl:URL{
        return KTVHTTPCache.proxyURL(withOriginalURL: url)
    }
    
    /// 是否是垂直视频
    func itVerticalMedia()->Bool{
        return true
    }

    init() {
        let array = [
            "https://cdn.pixabay.com/video/2022/07/24/125314-733046618_large.mp4",
            "https://assets.mixkit.co/active_storage/video_items/100016/1718919117/100016-video-720.mp4",
            "https://assets.mixkit.co/videos/52297/52297-720.mp4",
            "https://cdn.pixabay.com/video/2024/05/22/213040_large.mp4",
            "http://www.81.cn/ss_208539/_attachment/2025/11/09/16420853_7c18757ed0de428e10b577a79d911753.mp4"
        ]
        self.id = Int(arc4random())
        self.url = .init(string: array.randomElement()!)!
    }
}
