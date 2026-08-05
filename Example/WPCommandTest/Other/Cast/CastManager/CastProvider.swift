//import Foundation
//
///// 设备发现监听器
//protocol DeviceDiscoveryListener: AnyObject {
//    func onDeviceFound(_ device: CastDevice)
//    func onDeviceLost(_ device: CastDevice)
//}
//
///// 播放状态监听器
//protocol PlaybackStateListener: AnyObject {
//    func onStateChanged(_ newState: PlaybackState)
//}
//
///// 所有投屏方案的统一契约
//protocol CastProvider: AnyObject {
//    func type() -> ProviderType
//
//    /// 该方案在当前设备/环境下是否可用
//    func isAvailable() -> Bool
//
//    /// 设备发现
//    func startDiscovery(listener: DeviceDiscoveryListener)
//    func stopDiscovery()
//
//    /// 连接与断开
//    func connect(device: CastDevice, callback: @escaping (Bool, String?) -> Void)
//    func disconnect()
//    func isConnected() -> Bool
//
//    /// 加载并播放媒体
//    func loadMedia(url: String,
//                   title: String,
//                   subItem:NativePlayView.SUBItem?,
//                   mimeType: String)
//
//    /// 播放控制
//    func play()
//    func pause()
//    func stop()
//    func seekTo(positionMs: Int64)
//    func setVolume(_ volume: Float)
//
//    /// 状态监听
//    func addStateListener(_ listener: PlaybackStateListener)
//    func removeStateListener(_ listener: PlaybackStateListener)
//
//    /// 释放资源
//    func destroy()
//    
//    func captions(sub:NativePlayView.SUBItem?,complete: @escaping((Any?)->Void))
//}
//
//extension CastProvider{
//    func captions(sub:NativePlayView.SUBItem?,complete:@escaping((Any?)->Void)){}
//}
