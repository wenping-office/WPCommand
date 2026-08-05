//import Foundation
//import Network
//import os.log
//
//final class RokuEcpProvider: NSObject {
//
//    
//    private let logger = OSLog(subsystem: "com.ioscastdemo.roku", category: "Provider")
//
//    private weak var discoveryListener: DeviceDiscoveryListener?
//    private var discoveryTimer: DispatchSourceTimer?
//    private var ecpClient: RokuEcpClient?
//    private var isDiscovering = false
//    private let discoveryQueue = DispatchQueue(label: "com.ioscastdemo.roku.discovery", qos: .default)
//    private var discoveredDevices: [String: CastDevice] = [:]
//
//    private var connectedDevice: CastDevice?
//    private var connected = false
//    private let connectionQueue = DispatchQueue(label: "com.ioscastdemo.roku.connection", qos: .default)
//
//    private var stateListeners: [PlaybackStateListener] = []
//    private let stateQueue = DispatchQueue(label: "com.ioscastdemo.roku.state", qos: .default)
//    private var currentState = PlaybackState()
//
//    private var positionTimer: DispatchSourceTimer?
//    private var playbackStartTime: Date?
//    private var playbackStartPosition: Int64 = 0
//    private var isPlaying = false
//    private var mediaDurationMs: Int64 = 0
//
//    private let volumeStepCount = 5
//    private var currentVolume: Float = 0.5
//    private var targetVolume: Float = 0.5
//    private var volumeAdjustInProgress = false
//
//    private var discoveryConnection: NWConnection?
//    private let ssdpMulticastGroup = NWEndpoint.hostPort(
//        host: NWEndpoint.Host("239.255.255.250"),
//        port: NWEndpoint.Port(integerLiteral: 1900)
//    )
//    private let ssdpMX: UInt32 = 3
//    private let discoveryInterval: TimeInterval = 15.0
//
//    deinit {
//        stopDiscovery()
//        stopPositionTimer()
//        destroy()
//    }
//}
//
//extension RokuEcpProvider: CastProvider {
//    func type() -> ProviderType {
//        return .roku
//    }
//    
//
//    func isAvailable() -> Bool { return true }
//
//    func startDiscovery(listener: DeviceDiscoveryListener) {
//        discoveryListener = listener
//        guard !isDiscovering else { return }
//        isDiscovering = true
//        os_log(.info, log: logger, "Roku SSDP discovery started")
//        performSSDPDiscovery()
//        let timer = DispatchSource.makeTimerSource(queue: discoveryQueue)
//        timer.schedule(deadline: .now() + discoveryInterval, repeating: discoveryInterval)
//        timer.setEventHandler { [weak self] in self?.performSSDPDiscovery() }
//        timer.resume()
//        discoveryTimer = timer
//    }
//
//    func stopDiscovery() {
//        isDiscovering = false
//        discoveryTimer?.cancel()
//        discoveryTimer = nil
//        discoveryConnection?.cancel()
//        discoveryConnection = nil
//        discoveredDevices.removeAll()
//        os_log(.info, log: logger, "Roku SSDP discovery stopped")
//    }
//
//    func connect(device: CastDevice, callback: @escaping (Bool, String?) -> Void) {
//        guard device.type == .roku, let address = device.address else {
//            callback(false, "Incomplete device info")
//            return
//        }
//        let client = RokuEcpClient(ipAddress: address)
//        client.queryDeviceInfo { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success:
//                self.connectionQueue.async {
//                    self.ecpClient = client
//                    self.connectedDevice = device
//                    self.connected = true
//                    self.currentState = PlaybackState()
//                    os_log(.info, log: self.logger, "Connected to Roku: %{public}@", device.name)
//                    callback(true, nil)
//                }
//            case .failure(let error):
//                os_log(.error, log: self.logger, "Roku connect failed: %{public}@", error.localizedDescription)
//                callback(false, "Cannot connect: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    func disconnect() {
//        connectionQueue.async { [weak self] in
//            guard let self = self else { return }
//            self.stopPositionTimer()
//            self.ecpClient = nil
//            self.connectedDevice = nil
//            self.connected = false
//            self.isPlaying = false
//            self.currentState = PlaybackState()
//            os_log(.info, log: self.logger, "Disconnected from Roku")
//        }
//    }
//
//    func isConnected() -> Bool {
//        return connectionQueue.sync { connected }
//    }
//
//    func loadMedia(url: String,
//                   title: String,
//                   subItem:NativePlayView.SUBItem?,
//                   mimeType: String) {
//        guard let client = connectionQueue.sync(execute: { ecpClient }) else {
//            os_log(.error, log: logger, "loadMedia failed: not connected")
//            return
//        }
//        let format = formatFromMimeType(mimeType)
//        os_log(.info, log: logger, "Loading media: %{public}@", title)
//        client.playVideoUrl(url: url, title: title, format: format) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success:
//                self.playbackStartTime = Date()
//                self.playbackStartPosition = 0
//                self.isPlaying = true
//                self.mediaDurationMs = 0
//                self.updateState { state in
//                    state.status = .playing
//                    state.title = title
//                    state.positionMs = 0
//                }
//                self.startPositionTimer()
//                os_log(.info, log: self.logger, "Media loaded: %{public}@", title)
//            case .failure(let error):
//                os_log(.error, log: self.logger, "Media load failed: %{public}@", error.localizedDescription)
//                self.updateState { state in
//                    state.status = .error
//                    state.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
//
//    func play() {
//        guard let client = connectionQueue.sync(execute: { ecpClient }) else {
//            os_log(.error, log: logger, "play failed: not connected")
//            return
//        }
//        if !isPlaying {
//            client.playPauseToggle { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case .success:
//                    self.playbackStartTime = Date()
//                    self.isPlaying = true
//                    self.updateState { $0.status = .playing }
//                    self.startPositionTimer()
//                    os_log(.info, log: self.logger, "Playback resumed")
//                case .failure(let error):
//                    os_log(.error, log: self.logger, "Play failed: %{public}@", error.localizedDescription)
//                }
//            }
//        }
//    }
//
//    func pause() {
//        guard let client = connectionQueue.sync(execute: { ecpClient }) else {
//            os_log(.error, log: logger, "pause failed: not connected")
//            return
//        }
//        if isPlaying {
//            client.playPauseToggle { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case .success:
//                    if let start = self.playbackStartTime {
//                        self.playbackStartPosition += Int64(Date().timeIntervalSince(start) * 1000)
//                    }
//                    self.playbackStartTime = nil
//                    self.isPlaying = false
//                    self.stopPositionTimer()
//                    self.updateState { $0.status = .paused }
//                    os_log(.info, log: self.logger, "Paused at %lld ms", self.playbackStartPosition)
//                case .failure(let error):
//                    os_log(.error, log: self.logger, "Pause failed: %{public}@", error.localizedDescription)
//                }
//            }
//        }
//    }
//
//    func stop() {
//        guard let client = connectionQueue.sync(execute: { ecpClient }) else {
//            os_log(.error, log: logger, "stop failed: not connected")
//            return
//        }
//        client.home { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success:
//                self.stopPositionTimer()
//                self.playbackStartTime = nil
//                self.playbackStartPosition = 0
//                self.isPlaying = false
//                self.mediaDurationMs = 0
//                self.updateState { state in
//                    state.status = .stopped
//                    state.positionMs = 0
//                }
//                os_log(.info, log: self.logger, "Stopped, returned to home")
//            case .failure(let error):
//                os_log(.error, log: self.logger, "Stop failed: %{public}@", error.localizedDescription)
//            }
//        }
//    }
//
//    func seekTo(positionMs: Int64) {
//        playbackStartPosition = positionMs
//        playbackStartTime = isPlaying ? Date() : nil
//        updateState { $0.positionMs = positionMs }
//        os_log(.info, log: logger, "Seek to %lld ms (approximate)", positionMs)
//    }
//
//    func setVolume(_ volume: Float) {
//        let clampedVolume = max(0.0, min(1.0, volume))
//        guard !volumeAdjustInProgress else {
//            targetVolume = clampedVolume
//            return
//        }
//        targetVolume = clampedVolume
//        performVolumeAdjustment()
//    }
//
//    func addStateListener(_ listener: PlaybackStateListener) {
//        stateQueue.async { [weak self] in
//            guard let self = self else { return }
//            self.stateListeners.append(listener)
//            listener.onStateChanged(self.currentState)
//        }
//    }
//
//    func removeStateListener(_ listener: PlaybackStateListener) {
//        stateQueue.async { [weak self] in
//            self?.stateListeners.removeAll { $0 === listener }
//        }
//    }
//
//    func destroy() {
//        stopDiscovery()
//        stopPositionTimer()
//        connectionQueue.async { [weak self] in
//            guard let self = self else { return }
//
//            self.ecpClient = nil
//            self.connectedDevice = nil
//            self.connected = false
//        }
//        stateQueue.async { [weak self] in
//            guard let self = self else { return }
//            self.stateListeners.removeAll()
//        }
//        os_log(.info, log: logger, "RokuEcpProvider released")
//    }
//}
//
//// MARK: - SSDP Discovery
//
//private extension RokuEcpProvider {
//
//    func performSSDPDiscovery() {
//        guard isDiscovering else { return }
//        discoveryConnection?.cancel()
//        let connection = NWConnection(to: ssdpMulticastGroup, using: .udp)
//        connection.stateUpdateHandler = { [weak self] state in
//            guard let self = self else { return }
//            switch state {
//            case .ready:
//                os_log(.debug, log: self.logger, "SSDP ready, sending M-SEARCH")
//                self.sendMsearch(on: connection)
//                self.receiveSSDPResponse(on: connection)
//            case .failed(let error):
//                os_log(.error, log: self.logger, "SSDP connection failed: %{public}@", error.localizedDescription)
//                connection.cancel()
//            case .cancelled:
//                os_log(.debug, log: self.logger, "SSDP connection cancelled")
//            default:
//                break
//            }
//        }
//        connection.start(queue: discoveryQueue)
//        discoveryConnection = connection
//        discoveryQueue.asyncAfter(deadline: .now() + .seconds(Int(ssdpMX) + 1)) { [weak self] in
//            self?.discoveryConnection?.cancel()
//        }
//    }
//
//    func sendMsearch(on connection: NWConnection) {
//        let msearchMessage = "M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: \(ssdpMX)\r\nST: roku:ecp\r\n\r\n"
//        guard let data = msearchMessage.data(using: .utf8) else { return }
//        connection.send(content: data, completion: .contentProcessed { error in
//            if let error = error {
//                os_log(.error, log: self.logger, "SSDP M-SEARCH send failed: %{public}@", error.localizedDescription)
//            } else {
//                os_log(.debug, log: self.logger, "SSDP M-SEARCH sent")
//            }
//        })
//    }
//
//    func receiveSSDPResponse(on connection: NWConnection) {
//
//        connection.receiveMessage { [weak self] data, _, _, error in
//
//            guard let self = self else { return }
//
//
//            if let error = error {
//
//                os_log(
//                    .error,
//                    log: self.logger,
//                    "SSDP receive error: %{public}@",
//                    error.localizedDescription
//                )
//
//                return
//            }
//
//
//            guard
//                let data = data,
//                let response = String(
//                    data: data,
//                    encoding: .utf8
//                )
//            else {
//
//                self.receiveSSDPResponse(
//                    on: connection
//                )
//
//                return
//            }
//
//
//            os_log(
//                .debug,
//                log: self.logger,
//                "SSDP response received"
//            )
//
//
//            self.handleSSDPResponse(
//                response
//            )
//
//
//            self.receiveSSDPResponse(
//                on: connection
//            )
//        }
//    }
//
//    func handleSSDPResponse(_ response: String) {
//        guard let locationLine = response.components(separatedBy: "\r\n")
//                .first(where: { $0.lowercased().hasPrefix("location:") }) else { return }
//        let locationValue = locationLine
//            .replacingOccurrences(of: "Location:", with: "", options: .caseInsensitive)
//            .trimmingCharacters(in: .whitespaces)
//        guard let locationURL = URL(string: locationValue),
//              let deviceIP = locationURL.host else {
//            os_log(.error, log: logger, "Cannot parse SSDP LOCATION: %{public}@", locationValue)
//            return
//        }
//        os_log(.info, log: logger, "Roku device found: %{public}@", deviceIP)
//        guard discoveredDevices[deviceIP] == nil else { return }
//        let client = RokuEcpClient(ipAddress: deviceIP)
//        client.fetchFriendlyName { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let friendlyName):
//                let device = CastDevice(
//                    id: "roku:\(deviceIP)",
//                    name: friendlyName,
//                    type: .roku,
//                    address: deviceIP,
//                    raw: nil
//                )
//                self.discoveredDevices[deviceIP] = device
//                os_log(.info, log: self.logger, "Roku discovered: %{public}@ (%{public}@)", friendlyName, deviceIP)
//                self.discoveryListener?.onDeviceFound(device)
//            case .failure:
//                let device = CastDevice(
//                    id: "roku:\(deviceIP)",
//                    name: "Roku (\(deviceIP))",
//                    type: .roku,
//                    address: deviceIP,
//                    raw: nil
//                )
//                self.discoveredDevices[deviceIP] = device
//                os_log(.info, log: self.logger, "Roku discovered (no name): %{public}@", deviceIP)
//                self.discoveryListener?.onDeviceFound(device)
//            }
//        }
//    }
//}
//
//// MARK: - Position Polling
//
//private extension RokuEcpProvider {
//
//    func startPositionTimer() {
//        stopPositionTimer()
//        let timer = DispatchSource.makeTimerSource(queue: connectionQueue)
//        timer.schedule(deadline: .now(), repeating: .seconds(1))
//        timer.setEventHandler { [weak self] in self?.updatePosition() }
//        timer.resume()
//        positionTimer = timer
//    }
//
//    func stopPositionTimer() {
//        positionTimer?.cancel()
//        positionTimer = nil
//    }
//
//    func updatePosition() {
//        guard isPlaying, let start = playbackStartTime else { return }
//        let elapsed = Int64(Date().timeIntervalSince(start) * 1000)
//        let currentPosition = playbackStartPosition + elapsed
//        updateState { state in
//            state.positionMs = currentPosition
//            if self.mediaDurationMs > 0 {
//                state.durationMs = self.mediaDurationMs
//            }
//        }
//    }
//}
//
//// MARK: - Volume Control
//
//private extension RokuEcpProvider {
//
//    func performVolumeAdjustment() {
//        guard let client = connectionQueue.sync(execute: { ecpClient }) else {
//            os_log(.error, log: logger, "Volume adjust failed: not connected")
//            return
//        }
//        let target = targetVolume
//        let current = currentVolume
//        let steps = Int(round(abs(target - current) * Float(volumeStepCount)))
//        guard steps > 0 else {
//            volumeAdjustInProgress = false
//            return
//        }
//        volumeAdjustInProgress = true
//        let isUp = target > current
//        os_log(.debug, log: logger, "Volume: %.2f -> %.2f, steps: %d, up: %@",
//               current, target, steps, isUp ? "yes" : "no")
//        sendVolumeSteps(client: client, steps: steps, isUp: isUp, currentStep: 0) { [weak self] in
//            guard let self = self else { return }
//            self.currentVolume = target
//            self.volumeAdjustInProgress = false
//            self.updateState { $0.volume = target }
//            if abs(self.targetVolume - self.currentVolume) > 0.01 {
//                self.performVolumeAdjustment()
//            }
//        }
//    }
//
//    private func sendVolumeSteps(
//        client: RokuEcpClient,
//        steps: Int,
//        isUp: Bool,
//        currentStep: Int,
//        completion: @escaping () -> Void
//    ) {
//        guard currentStep < steps else {
//            completion()
//            return
//        }
//        let sendStep: (@escaping (Result<Void, Error>) -> Void) -> Void = { completion in
//
//            if isUp {
//                client.volumeUp(completion: completion)
//            } else {
//                client.volumeDown(completion: completion)
//            }
//        }
//        sendStep { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success:
//                self.connectionQueue.asyncAfter(deadline: .now() + .milliseconds(200)) {
//                    self.sendVolumeSteps(
//                        client: client,
//                        steps: steps,
//                        isUp: isUp,
//                        currentStep: currentStep + 1,
//                        completion: completion
//                    )
//                }
//            case .failure(let error):
//                os_log(.error, log: self.logger, "Volume keypress failed: %{public}@", error.localizedDescription)
//                completion()
//            }
//        }
//    }
//}
//
//// MARK: - State Helpers
//
//private extension RokuEcpProvider {
//
//    func updateState(_ block: @escaping (inout PlaybackState) -> Void) {
//        stateQueue.async { [weak self] in
//            guard let self = self else { return }
//            block(&self.currentState)
//            let state = self.currentState
//            for listener in self.stateListeners {
//                listener.onStateChanged(state)
//            }
//        }
//    }
//
//    func formatFromMimeType(_ mimeType: String) -> String {
//        switch mimeType.lowercased() {
//        case "video/mp4", "mp4":
//            return "mp4"
//        case "application/x-mpegurl", "vnd.apple.mpegurl", "m3u8", "hls":
//            return "m3u8"
//        case "video/webm", "webm":
//            return "webm"
//        case "video/x-matroska", "mkv":
//            return "mkv"
//        default:
//            return "mp4"
//        }
//    }
//}
