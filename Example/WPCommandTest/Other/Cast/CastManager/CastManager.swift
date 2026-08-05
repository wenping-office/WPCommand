//import Foundation
//import Combine
//import WPCommand
//import Base
//
///// 投屏功能对外的统一入口（Facade）
///// UI 层只需：startDiscovery() → connect(device) → loadMedia/play/pause/stop
//class CastManager: ObservableObject {
//    static let shared = CastManager()
//
//    /// 投屏url
//    @Published var url:URL?
//
//    @Published var devices: [CastDevice] = []
//    @Published var state: PlaybackState = PlaybackState()
//    @Published var isScanning: Bool = false
//
//    private var providers: [CastProvider] = []
//    private var activeProvider: CastProvider?
//    @Published // 当前连接设备
//    var activeDevice: CastDevice?
//
//    private let discoveryQueue = DispatchQueue(label: "cast.discovery", qos: .default)
//    private let stateQueue = DispatchQueue(label: "cast.state", qos: .default)
//
//    init() {
//        setupProviders()
//    }
//
//    private func setupProviders() {
//        providers = [
//            DlnAProvider(),
//            AirPlayProvider(),
//            RokuEcpProvider(),
//            GoogleCastProvider()
//        ].filter { $0.isAvailable() }
//    }
//
//    // MARK: - Discovery
//
//    func startDiscovery() {
//        isScanning = true
//        providers.forEach { provider in
//            provider.startDiscovery(listener: self)
//        }
//    }
//
//    func stopDiscovery() {
//        isScanning = false
//        providers.forEach { $0.stopDiscovery() }
//    }
//
//    // MARK: - Connection
//
//    func connect(device: CastDevice, callback: @escaping (Bool, String?) -> Void) {
//        guard let provider = providers.first(where: { $0.type() == device.type }) else {
//            callback(false, "不支持的设备类型: \(device.type.rawValue)")
//            return
//        }
//
//        // 断开之前的连接
//        if let prev = activeProvider, prev !== provider {
//            prev.disconnect()
//            prev.removeStateListener(self)
//        }
//
//        provider.connect(device: device) { [weak self] success, error in
//            guard let self = self else { return }
//            if success {
//                self.activeProvider = provider
//                self.activeDevice = device
//                provider.addStateListener(self)
//            }
//            callback(success, error)
//        }
//    }
//
//    func disconnect() {
//        activeProvider?.removeStateListener(self)
//        activeProvider?.disconnect()
//        activeProvider = nil
//        activeDevice = nil
//        DispatchQueue.main.async {
//            self.state = PlaybackState()
//        }
//    }
//
//    var currentDevice: CastDevice? { activeDevice }
//    var isConnected: Bool { activeProvider?.isConnected() ?? false }
//
//    // MARK: - Media Control
//    func loadMedia(url: String,
//                   title: String,
//                   subItem:NativePlayView.SUBItem?,
//                   mimeType: String = "video/mp4"){
//        activeProvider?.loadMedia(url: url, title: title,subItem: subItem ,mimeType: mimeType)
//    }
//
//    func play() { activeProvider?.play() }
//    func pause() { activeProvider?.pause() }
//    func stop() { activeProvider?.stop() }
//    func seekTo(positionMs: Int64) { activeProvider?.seekTo(positionMs: positionMs) }
//    func setVolume(_ volume: Float) { activeProvider?.setVolume(volume) }
//
//    func distroy() {
//        stopDiscovery()
//        disconnect()
//        providers.forEach { $0.destroy() }
//    }
//}
//
//// MARK: - DeviceDiscoveryListener
//
//extension CastManager: DeviceDiscoveryListener {
//    func onDeviceFound(_ device: CastDevice) {
//        DispatchQueue.main.async {
//            if !self.devices.contains(where: { $0.id == device.id && $0.name == device.name }) {
//                self.devices.append(device)
//            }
//        }
//    }
//
//    func onDeviceLost(_ device: CastDevice) {
//        DispatchQueue.main.async {
//            self.devices.removeAll { $0.id == device.id }
//        }
//    }
//}
//
//// MARK: - PlaybackStateListener
//
//extension CastManager: PlaybackStateListener {
//    func onStateChanged(_ newState: PlaybackState) {
//        DispatchQueue.main.async {
//            self.state = newState
//        }
//    }
//}
//
//extension CastManager{
//    func disconnectUI(complete:(()->Void)? = nil){
//        let alert = UIAlertController(
//            title: "Disconnect".local(),
//            message: "Are you sure you want to disconnect from the current device?".local(),
//            preferredStyle: .alert
//        )
//
//        alert.addAction(UIAlertAction(title: "Cancel".local(), style: .cancel))
//        alert.addAction(UIAlertAction(title: "Disconnect".local(), style: .destructive) { _ in
//            CastManager.shared.disconnect()
//            complete?()
//        })
//        UIViewController.wp.current?.present(alert, animated: true)
//    }
//}
