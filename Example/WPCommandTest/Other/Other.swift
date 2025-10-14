//
//  Other.swift
//  WPCommand_Example
//
//  Created by 1234 on 2024/12/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit



/// 获取视频第一帧
/*
static func splitVideoFileUrlFps(splitFileUrl: URL, fps: Float, splitCompleteClosure: @escaping (Bool, [UIImage]) -> Void) {

    var splitImages = [UIImage]()
    let optDict = NSDictionary(object: NSNumber(value: false), forKey: AVURLAssetPreferPreciseDurationAndTimingKey as NSCopying)
    let urlAsset = AVURLAsset(url: splitFileUrl, options: optDict as? [String: Any])

    let cmTime = urlAsset.duration
    let durationSeconds: Float64 = CMTimeGetSeconds(cmTime) //视频总秒数

    var times = [NSValue]()
    let totalFrames: Float64 = durationSeconds * Float64(fps) //获取视频的总帧数
    var timeFrame: CMTime

    for i in 0...Int(totalFrames) {
        timeFrame = CMTimeMake(value: Int64(i), timescale: Int32(fps)) //第i帧， 帧率
        let timeValue = NSValue(time: timeFrame)

        times.append(timeValue)
    }

    let imgGenerator = AVAssetImageGenerator(asset: urlAsset)
    imgGenerator.requestedTimeToleranceBefore = CMTime.zero //防止时间出现偏差
    imgGenerator.requestedTimeToleranceAfter = CMTime.zero
    imgGenerator.appliesPreferredTrackTransform = true //不知道是什么属性，不写true视频帧图方向不对

    let timesCount = times.count

    //获取每一帧的图片
    imgGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in

        //times有多少次body就循环多少次。。。

        var isSuccess = false
        switch (result) {
        case AVAssetImageGenerator.Result.cancelled:
            print("cancelled------")

        case AVAssetImageGenerator.Result.failed:
            print("failed++++++")

        case AVAssetImageGenerator.Result.succeeded:
            let framImg = UIImage(cgImage: image!)
            splitImages.append(framImg)

            if (Int(requestedTime.value) == (timesCount - 1)) { //最后一帧时 回调赋值
                isSuccess = true
                splitCompleteClosure(isSuccess, splitImages)
                print("completed")
            }
        }
    }
}*/

/*
 // 计算压缩后的比特率
 static func calculateBitrate(for fileSizeInMB: Double, duration: Double) -> Int {
     let targetSizeInBytes = fileSizeInMB * 1024 * 1024  // 转换为字节
     let bitrate = (targetSizeInBytes * 8) / duration    // 计算比特率
     return Int(bitrate)
 }
 
 // 压缩视频到目标大小（MB）以内
 static func compressVideo(inputURL: URL, outputURL: URL, targetFileSizeInMB: Double, completion: @escaping (URL?, Error?) -> Void) {
     let asset = AVAsset(url: inputURL)
     
     // 获取视频时长
     let duration = asset.duration.seconds
     debugPrint("duration = \(duration)")
     // 计算目标比特率
     let targetBitrate = calculateBitrate(for: targetFileSizeInMB, duration: duration)
     print("目标比特率: \(targetBitrate) bps")
     
     // 使用 AVAssetExportSession
     guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
         completion(nil, NSError(domain: "com.video.compress", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法创建导出会话"]))
         return
     }
     
     exportSession.outputURL = outputURL
     exportSession.outputFileType = .mov
     exportSession.shouldOptimizeForNetworkUse = true
     
     // 自定义视频压缩设置
     let videoTrack = asset.tracks(withMediaType: .video).first!
     let videoSettings: [String: Any] = [
         AVVideoCodecKey: AVVideoCodecType.h264,
         AVVideoWidthKey: videoTrack.naturalSize.width,
         AVVideoHeightKey: videoTrack.naturalSize.height,
         AVVideoCompressionPropertiesKey: [
             AVVideoAverageBitRateKey: targetBitrate,  // 设置目标比特率
             AVVideoProfileLevelKey: AVVideoProfileLevelH264Main41
         ]
     ]
     
     // 自定义导出配置
     let videoComposition = AVMutableVideoComposition(propertiesOf: videoTrack.asset!)
     exportSession.videoComposition = videoComposition
     
     exportSession.exportAsynchronously {
         switch exportSession.status {
         case .completed:
             print("视频压缩成功")
             completion(outputURL, nil)
         case .failed:
             if let error = exportSession.error {
                 print("视频压缩失败: \(error.localizedDescription)")
                 completion(nil, error)
             }
         case .cancelled:
             print("视频压缩已取消")
             completion(nil, NSError(domain: "com.video.compress", code: -2, userInfo: [NSLocalizedDescriptionKey: "视频压缩已取消"]))
         default:
             break
         }
     }
 }
 */
