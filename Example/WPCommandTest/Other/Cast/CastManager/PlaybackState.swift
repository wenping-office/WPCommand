//import Foundation
//
///// 播放状态
//struct PlaybackState {
//    enum Status {
//      case playing
//      case paused
//      case noramal
//      case stopped
//      case error
//    }
//    
//    var status:Status = .noramal
//    var isPlaying: Bool = false
//    var positionMs: Int64 = 0
//    var durationMs: Int64 = 0
//    var isConnected:Bool = false
//    var position:Double = 0
//    var duration:Double = 0
//    var volume: Float = 1.0
//    var title: String?
//    var mediaUrl: String?
//    var isMuted:Bool = false
//    var idleReason:String = ""
//    var errorMessage:String?
//    
//   
//}
//
/////// 设备发现监听器
////protocol DeviceDiscoveryListener: AnyObject {
////    func onDeviceFound(_ device: CastDevice)
////    func onDeviceLost(_ device: CastDevice)
////}
////
/////// 播放状态监听器
////protocol PlaybackStateListener: AnyObject {
////    func onStateChanged(_ newState: PlaybackState)
////}
