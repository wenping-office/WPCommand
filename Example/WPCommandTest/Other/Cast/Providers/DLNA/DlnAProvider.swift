//import Foundation
//import os.log
//
///// DLNA 投屏方案实现，遵循 CastProvider 协议
//final class DlnAProvider: CastProvider {
//    func type() -> ProviderType {
//        return .dlna
//    }
//
//    private let log = OSLog(subsystem: "com.ioscastdemo.dlna", category: "DlnAProvider")
//
//    private let ssdpDiscovery = SSDPDiscovery()
//    private let soapControl = SOAPControl()
//
//    // MARK: - 发现状态
//
//    private var discoveryListener: DeviceDiscoveryListener?
//    private var discoveryTimer: DispatchSourceTimer?
//    private let discoveryQueue = DispatchQueue(label: "com.ioscastdemo.dlna.discovery", qos: .default)
//    private var isDiscovering = false
//
//    /// 已发现设备: key = locationUrl
//    private var discoveredDevices: [String: CastDevice] = [:]
//    /// 设备元数据缓存: key = locationUrl
//    private var deviceMetadata: [String: DeviceMetadata] = [:]
//
//    // MARK: - 连接状态
//
//    private var connectedDevice: CastDevice?
//    private var connectedMetadata: DeviceMetadata?
//    private var isDeviceConnected = false
//
//    // MARK: - 播放状态
//
//    private var currentState = PlaybackState()
//    private let stateQueue = DispatchQueue(label: "com.ioscastdemo.dlna.state", qos: .default)
//
//    // MARK: - 监听器
//
//    private let listenerLock = NSLock()
//    private var stateListeners = NSHashTable<AnyObject>.weakObjects()
//
//    // MARK: - 内部类型
//
//    private struct DeviceMetadata {
//        let ip: String
//        let locationUrl: String
//        let deviceInfo: DLNADeviceInfo
//    }
//
//    // MARK: - CastProvider: 可用性
//
//    func isAvailable() -> Bool {
//        // DLNA 在 iOS 上始终可用（纯网络协议）
//        return true
//    }
//
//    // MARK: - CastProvider: 设备发现
//
//    func startDiscovery(listener: DeviceDiscoveryListener) {
//        discoveryListener = listener
//        isDiscovering = true
//
//        // 立即执行一次发现
//        runDiscoveryCycle()
//
//        // 启动定时器，每 15 秒扫描一次
//        let timer = DispatchSource.makeTimerSource(queue: discoveryQueue)
//        timer.schedule(deadline: .now() + 15, repeating: 15)
//        timer.setEventHandler { [weak self] in
//            self?.runDiscoveryCycle()
//        }
//        timer.resume()
//        discoveryTimer = timer
//
//        os_log(.info, log: log, "DLNA: 开始设备发现（15 秒间隔）")
//    }
//
//    func stopDiscovery() {
//        isDiscovering = false
//        discoveryTimer?.cancel()
//        discoveryTimer = nil
//        discoveryListener = nil
//
//        os_log(.info, log: log, "DLNA: 停止设备发现")
//    }
//
//    private func runDiscoveryCycle() {
//        guard isDiscovering else { return }
//
//        ssdpDiscovery.discoverMediaRenderers(timeout: 3.0) { [weak self] ip, locationUrl in
//            guard let self = self, self.isDiscovering else { return }
//
//            // 如果已存在，跳过
//            if self.discoveredDevices[locationUrl] != nil {
//                return
//            }
//
//            // 先以临时名称创建设备，然后异步获取真实名称
//            let tempDevice = CastDevice(
//                id: "dlna:\(ip)",
//                name: "DLNA Device",
//                type: .dlna,
//                address: ip,
//                raw: locationUrl
//            )
//            self.discoveredDevices[locationUrl] = tempDevice
//
//            // 通知 UI 发现设备
//            if let listener = self.discoveryListener {
//                DispatchQueue.main.async {
//                    listener.onDeviceFound(tempDevice)
//                }
//            }
//
//            // 异步获取设备名称
//            self.soapControl.fetchDeviceInfo(locationUrl: locationUrl) { [weak self] info in
//                guard let self = self, let info = info else { return }
//
//                self.deviceMetadata[locationUrl] = DeviceMetadata(
//                    ip: ip,
//                    locationUrl: locationUrl,
//                    deviceInfo: info
//                )
//
//                // 更新设备名称
//                let updatedDevice = CastDevice(
//                    id: "dlna:\(ip)",
//                    name: info.friendlyName,
//                    type: .dlna,
//                    address: ip,
//                    raw: locationUrl
//                )
//                self.discoveredDevices[locationUrl] = updatedDevice
//
//                // 通知 UI 设备名称已更新
//                if let listener = self.discoveryListener {
//                    DispatchQueue.main.async {
//                        listener.onDeviceFound(updatedDevice)
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - CastProvider: 连接与断开
//
//    func connect(device: CastDevice, callback: @escaping (Bool, String?) -> Void) {
//        guard let locationUrl = device.raw as? String else {
//            callback(false, "设备缺少 location URL")
//            return
//        }
//
//        // 如果已有缓存的设备元数据，直接使用
//        if let metadata = deviceMetadata[locationUrl] {
//            self.connectedDevice = device
//            self.connectedMetadata = metadata
//            self.isDeviceConnected = true
//            os_log(.info, log: log, "DLNA: 已连接设备 %{public}@ (使用缓存)", metadata.deviceInfo.friendlyName)
//            callback(true, nil)
//            return
//        }
//
//        // 否则获取设备描述 XML
//        soapControl.fetchDeviceInfo(locationUrl: locationUrl) { [weak self] info in
//            guard let self = self else {
//                callback(false, "Provider 已释放")
//                return
//            }
//
//            guard let info = info else {
//                callback(false, "无法获取设备信息")
//                return
//            }
//
//            guard info.avTransportControlURL != nil else {
//                callback(false, "设备不支持 AVTransport 服务")
//                return
//            }
//
//            let metadata = DeviceMetadata(
//                ip: device.address ?? "",
//                locationUrl: locationUrl,
//                deviceInfo: info
//            )
//
//            self.connectedDevice = device
//            self.connectedMetadata = metadata
//            self.isDeviceConnected = true
//            self.deviceMetadata[locationUrl] = metadata
//
//            os_log(.info, log: self.log, "DLNA: 已连接设备 %{public}@", info.friendlyName)
//            callback(true, nil)
//        }
//    }
//
//    func disconnect() {
//        if let device = connectedDevice, let locationUrl = device.raw as? String {
//            if let metadata = connectedMetadata,
//               let controlUrl = metadata.deviceInfo.avTransportControlURL {
//                soapControl.stop(controlUrl: controlUrl) { _ in }
//            }
//        }
//
//        connectedDevice = nil
//        connectedMetadata = nil
//        isDeviceConnected = false
//        currentState = PlaybackState()
//
//        os_log(.info, log: log, "DLNA: 已断开连接")
//    }
//
//    func isConnected() -> Bool {
//        return isDeviceConnected
//    }
//
//    // MARK: - CastProvider: 媒体加载与播放
//
//    func loadMedia(url: String,
//                   title: String,
//                   subItem:NativePlayView.SUBItem?,
//                   mimeType: String) {
//        guard let metadata = connectedMetadata,
//              let controlUrl = metadata.deviceInfo.avTransportControlURL else {
//            os_log(.error, log: log, "DLNA: 无法加载媒体 - 未连接或无 AVTransport URL")
//            return
//        }
//
//        soapControl.setAVTransportURI(controlUrl: controlUrl,
//                                       mediaUrl: url,
//                                       title: title,
//                                       mimeType: mimeType) { [weak self] success in
//            guard let self = self else { return }
//            if success {
//                self.updateState { state in
//                    state.title = title
//                    state.mediaUrl = url
//                    state.isPlaying = false
//                }
//                os_log(.info, log: self.log, "DLNA: 媒体已加载: %{public}@", title)
//            } else {
//                os_log(.error, log: self.log, "DLNA: 加载媒体失败")
//            }
//        }
//    }
//
//    func play() {
//        guard let metadata = connectedMetadata,
//              let controlUrl = metadata.deviceInfo.avTransportControlURL else {
//            os_log(.error, log: log, "DLNA: 无法播放 - 未连接")
//            return
//        }
//
//        soapControl.play(controlUrl: controlUrl) { [weak self] success in
//            guard let self = self else { return }
//            if success {
//                self.updateState { state in
//                    state.isPlaying = true
//                }
//                self.notifyStateListeners()
//                os_log(.info, log: self.log, "DLNA: 播放")
//            }
//        }
//    }
//
//    func pause() {
//        guard let metadata = connectedMetadata,
//              let controlUrl = metadata.deviceInfo.avTransportControlURL else {
//            os_log(.error, log: log, "DLNA: 无法暂停 - 未连接")
//            return
//        }
//
//        soapControl.pause(controlUrl: controlUrl) { [weak self] success in
//            guard let self = self else { return }
//            if success {
//                self.updateState { state in
//                    state.isPlaying = false
//                }
//                self.notifyStateListeners()
//                os_log(.info, log: self.log, "DLNA: 暂停")
//            }
//        }
//    }
//
//    func stop() {
//        guard let metadata = connectedMetadata,
//              let controlUrl = metadata.deviceInfo.avTransportControlURL else {
//            os_log(.error, log: log, "DLNA: 无法停止 - 未连接")
//            return
//        }
//
//        soapControl.stop(controlUrl: controlUrl) { [weak self] success in
//            guard let self = self else { return }
//            if success {
//                self.updateState { state in
//                    state.isPlaying = false
//                    state.positionMs = 0
//                }
//                self.notifyStateListeners()
//                os_log(.info, log: self.log, "DLNA: 停止")
//            }
//        }
//    }
//
//    func seekTo(positionMs: Int64) {
//        guard let metadata = connectedMetadata,
//              let controlUrl = metadata.deviceInfo.avTransportControlURL else {
//            os_log(.error, log: log, "DLNA: 无法 seek - 未连接")
//            return
//        }
//
//        let seekTarget = formatSeekTarget(positionMs: positionMs)
//        let bodyXML = """
//        <u:Seek xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
//            <InstanceID>0</InstanceID>
//            <Unit>REL_TIME</Unit>
//            <Target>\(seekTarget)</Target>
//        </u:Seek>
//        """
//
//        sendCustomSOAP(controlUrl: controlUrl,
//                       serviceType: "urn:schemas-upnp-org:service:AVTransport:1",
//                       action: "Seek",
//                       bodyXML: bodyXML) { [weak self] success in
//            guard let self = self else { return }
//            if success {
//                self.updateState { state in
//                    state.positionMs = positionMs
//                }
//                self.notifyStateListeners()
//                os_log(.info, log: self.log, "DLNA: seek 到 %{public}lld ms", positionMs)
//            }
//        }
//    }
//
//    func setVolume(_ volume: Float) {
//        guard let metadata = connectedMetadata,
//              let controlUrl = metadata.deviceInfo.renderingControlControlURL else {
//            os_log(.error, log: log, "DLNA: 无法设置音量 - 未连接或无 RenderingControl URL")
//            return
//        }
//
//        soapControl.setVolume(controlUrl: controlUrl, volume: volume) { [weak self] success in
//            guard let self = self else { return }
//            if success {
//                self.updateState { state in
//                    state.volume = volume
//                }
//                self.notifyStateListeners()
//                os_log(.info, log: self.log, "DLNA: 音量设置为 %.2f", volume)
//            }
//        }
//    }
//
//    // MARK: - CastProvider: 状态监听
//
//    func addStateListener(_ listener: PlaybackStateListener) {
//        listenerLock.lock()
//        stateListeners.add(listener as AnyObject)
//        listenerLock.unlock()
//    }
//
//    func removeStateListener(_ listener: PlaybackStateListener) {
//        listenerLock.lock()
//        stateListeners.remove(listener as AnyObject)
//        listenerLock.unlock()
//    }
//
//    // MARK: - CastProvider: 释放资源
//
//    func destroy() {
//        stopDiscovery()
//        disconnect()
//        stateListeners.removeAllObjects()
//        discoveredDevices.removeAll()
//        deviceMetadata.removeAll()
//
//        os_log(.info, log: log, "DLNA: 资源已释放")
//    }
//
//    // MARK: - Private: 状态管理
//
//    private func updateState(_ block: (inout PlaybackState) -> Void) {
//        stateQueue.sync {
//            block(&currentState)
//        }
//    }
//
//    private func notifyStateListeners() {
//        listenerLock.lock()
//        let listeners = stateListeners.allObjects.compactMap { $0 as? PlaybackStateListener }
//        listenerLock.unlock()
//
//        let state = currentState
//        for listener in listeners {
//            DispatchQueue.main.async {
//                listener.onStateChanged(state)
//            }
//        }
//    }
//
//    // MARK: - Private: SOAP 辅助
//
//    private func sendCustomSOAP(controlUrl: String,
//                                serviceType: String,
//                                action: String,
//                                bodyXML: String,
//                                completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: controlUrl) else {
//            completion(false)
//            return
//        }
//
//        let soapEnvelope = """
//        <?xml version="1.0"?>
//        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
//            <s:Body>
//                \(bodyXML)
//            </s:Body>
//        </s:Envelope>
//        """
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("text/xml; charset=\"utf-8\"", forHTTPHeaderField: "Content-Type")
//        request.setValue("\"\(serviceType)#\(action)\"", forHTTPHeaderField: "SOAPAction")
//        request.httpBody = soapEnvelope.data(using: .utf8)
//
//        let task = URLSession.shared.dataTask(with: request) { _, response, error in
//            if let error = error {
//                os_log(.error, log: self.log, "DLNA: %{public}@ 失败: %{public}@", action, error.localizedDescription)
//                completion(false)
//                return
//            }
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }
//        task.resume()
//    }
//
//    /// 将毫秒转换为 DLNA 的 REL_TIME 格式 (HH:MM:SS)
//    private func formatSeekTarget(positionMs: Int64) -> String {
//        let totalSeconds = positionMs / 1000
//        let hours = totalSeconds / 3600
//        let minutes = (totalSeconds % 3600) / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%02lld:%02lld:%02lld", hours, minutes, seconds)
//    }
//}
