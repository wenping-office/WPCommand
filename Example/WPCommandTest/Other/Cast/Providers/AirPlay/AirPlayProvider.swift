//import Foundation
//import os.log
//
//private let log = OSLog(subsystem: "com.castdemo.airplay", category: "Provider")
//
//final class AirPlayProvider: NSObject {
//
////    let type: ProviderType = .airplay
//
//    private let discovery = AirPlayDiscovery()
//    private var client: AirPlayClient?
//
//    private var currentDevice: CastDevice?
//    private var currentState = PlaybackState()
//
//    private let queue = DispatchQueue(label: "com.castdemo.airplay.provider", qos: .userInitiated)
//    private var pollingTimer: DispatchSourceTimer?
//    private var isPolling = false
//
//    private var stateListeners: NSHashTable<AnyObject> = NSHashTable.weakObjects()
//
//    deinit {
//        stopPolling()
//    }
//}
//
//// MARK: - CastProvider
//
//extension AirPlayProvider: CastProvider {
//    func type() -> ProviderType {
//        return .airplay
//    }
//
//    func isAvailable() -> Bool {
//        return true
//    }
//
//    // MARK: Discovery
//
//    func startDiscovery(listener: DeviceDiscoveryListener) {
//        discovery.onDeviceFound = { [weak self, weak listener] device in
//            listener?.onDeviceFound(device)
//        }
//        discovery.onDeviceLost = { [weak self, weak listener] device in
//            listener?.onDeviceLost(device)
//        }
//        discovery.start()
//    }
//
//    func stopDiscovery() {
//        discovery.stop()
//    }
//
//    // MARK: Connection
//
//    func connect(device: CastDevice, callback: @escaping (Bool, String?) -> Void) {
//        queue.async { [weak self] in
//            guard let self = self else { return }
//
//            guard let info = device.raw as? AirPlayDeviceInfo else {
//                os_log(.error, log: log, "Invalid device info for AirPlay device: %{public}@", device.name)
//                DispatchQueue.main.async {
//                    callback(false, "无效的设备信息")
//                }
//                return
//            }
//
//            let host = info.ipAddress ?? info.hostname
//            let port = info.port
//
//            let airplayClient = AirPlayClient(host: host, port: port)
//            guard airplayClient.isAvailable else {
//                os_log(.error, log: log, "TCP connection test failed for %{public}@:%d", host, port)
//                DispatchQueue.main.async {
//                    callback(false, "无法连接到 AirPlay 设备")
//                }
//                return
//            }
//
//            self.client = airplayClient
//            self.currentDevice = device
//
//            self.currentState = PlaybackState(isConnected: true)
//            self.notifyStateChanged()
//
//            os_log(.info, log: log, "Connected to AirPlay device: %{public}@ (%{public}@:%d)",
//                   device.name, host, port)
//
//            DispatchQueue.main.async {
//                callback(true, nil)
//            }
//        }
//    }
//
//    func disconnect() {
//        queue.async { [weak self] in
//            guard let self = self else { return }
//            self.stopPolling()
//            self.client = nil
//            self.currentDevice = nil
//            self.currentState = PlaybackState()
//            self.notifyStateChanged()
//            os_log(.info, log: log, "Disconnected from AirPlay device")
//        }
//    }
//
//    func isConnected() -> Bool {
//        return client != nil && currentDevice != nil
//    }
//
//    // MARK: Media Loading
//
//    func loadMedia(url: String,
//                   title: String,
//                   subItem:NativePlayView.SUBItem?,
//                   mimeType: String) {
//        queue.async { [weak self] in
//            guard let self = self, let client = self.client else {
//                os_log(.error, log: log, "loadMedia called but no active AirPlay client")
//                return
//            }
//
//            os_log(.info, log: log, "Loading media: %{public}@, title: %{public}@", url, title)
//
//            client.play(url: url, position: 0.0) { [weak self] success, error in
//                guard let self = self else { return }
//                if success {
//                    os_log(.info, log: log, "Media loaded successfully")
//                    self.currentState.title = title
//                    self.currentState.isPlaying = true
//                    self.notifyStateChanged()
//                    self.startPolling()
//                } else {
//                    os_log(.error, log: log, "Failed to load media: %{public}@", error ?? "unknown")
//                    self.currentState.isPlaying = false
//                    self.notifyStateChanged()
//                }
//            }
//        }
//    }
//
//    // MARK: Playback Control
//
//    func play() {
//        queue.async { [weak self] in
//            guard let self = self, let client = self.client else { return }
//            os_log(.info, log: log, "Play")
//            client.setRate(1.0) { [weak self] success in
//                if success {
//                    self?.currentState.isPlaying = true
//                    self?.notifyStateChanged()
//                    self?.startPolling()
//                }
//            }
//        }
//    }
//
//    func pause() {
//        queue.async { [weak self] in
//            guard let self = self, let client = self.client else { return }
//            os_log(.info, log: log, "Pause")
//            client.setRate(0.0) { [weak self] success in
//                if success {
//                    self?.currentState.isPlaying = false
//                    self?.notifyStateChanged()
//                    self?.stopPolling()
//                }
//            }
//        }
//    }
//
//    func stop() {
//        queue.async { [weak self] in
//            guard let self = self, let client = self.client else { return }
//            os_log(.info, log: log, "Stop")
//            client.stop { [weak self] success in
//                self?.stopPolling()
//                self?.currentState.isPlaying = false
//                self?.currentState.position = 0
//                self?.notifyStateChanged()
//            }
//        }
//    }
//
//    func seekTo(positionMs: Int64) {
//        queue.async { [weak self] in
//            guard let self = self, let client = self.client else { return }
//            let position = Double(positionMs) / 1000.0
//            os_log(.info, log: log, "Seek to %.2f seconds", position)
//            // AirPlay seek via /scrub with POST
//            client.setRate(0.0) { _ in
//                // Use reverse then play to approximate seek
//                client.reverse { [weak self] success in
//                    guard let self = self else { return }
//                    self.currentState.position = position
//                    self.notifyStateChanged()
//                    if self.currentState.isPlaying {
//                        client.setRate(1.0) { _ in }
//                    }
//                }
//            }
//        }
//    }
//
//    func setVolume(_ volume: Float) {
//        queue.async { [weak self] in
//            guard let self = self, let client = self.client else { return }
//            let clampedVolume = max(0.0, min(1.0, volume))
//            os_log(.info, log: log, "Set volume: %.2f", clampedVolume)
//            client.setVolume(clampedVolume) { [weak self] success in
//                if success {
//                    self?.currentState.volume = clampedVolume
//                    self?.notifyStateChanged()
//                }
//            }
//        }
//    }
//
//    // MARK: State Listeners
//
//    func addStateListener(_ listener: PlaybackStateListener) {
//        stateListeners.add(listener)
//    }
//
//    func removeStateListener(_ listener: PlaybackStateListener) {
//        stateListeners.remove(listener)
//    }
//
//    func destroy() {
//        stopDiscovery()
//        disconnect()
//        stateListeners.removeAllObjects()
//        os_log(.info, log: log, "AirPlayProvider released")
//    }
//}
//
//// MARK: - Polling
//
//private extension AirPlayProvider {
//
//    func startPolling() {
//        guard !isPolling else { return }
//        isPolling = true
//
//        let timer = DispatchSource.makeTimerSource(queue: queue)
//        timer.schedule(deadline: .now() + 1.0, repeating: 1.0)
//        timer.setEventHandler { [weak self] in
//            self?.pollPlaybackState()
//        }
//        timer.resume()
//        pollingTimer = timer
//
//        os_log(.debug, log: log, "Polling started (1s interval)")
//    }
//
//    func stopPolling() {
//        guard isPolling else { return }
//        isPolling = false
//        pollingTimer?.cancel()
//        pollingTimer = nil
//        os_log(.debug, log: log, "Polling stopped")
//    }
//
//    func pollPlaybackState() {
//        guard let client = client else {
//            stopPolling()
//            return
//        }
//
//        client.fetchScrub { [weak self] position, duration in
//            guard let self = self else { return }
//
//            var stateChanged = false
//
//            if let position = position {
//                self.currentState.position = position
//                stateChanged = true
//            }
//            if let duration = duration {
//                self.currentState.duration = duration
//                stateChanged = true
//            }
//
//            if stateChanged {
//                self.notifyStateChanged()
//            }
//        }
//    }
//}
//
//// MARK: - State Notification
//
//private extension AirPlayProvider {
//
//    func notifyStateChanged() {
//        let state = currentState
//        let listeners = stateListeners.allObjects.compactMap { $0 as? PlaybackStateListener }
//        for listener in listeners {
//            listener.onStateChanged(state)
//        }
//    }
//}
