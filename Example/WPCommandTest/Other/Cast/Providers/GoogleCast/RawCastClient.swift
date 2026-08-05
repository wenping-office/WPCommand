//import Foundation
//import Network
//import Security
//import os.log
//
//// MARK: - Raw Google Cast V2 Protocol Client
//
///// 原生 Google Cast V2 协议客户端，使用 Protobuf 编码，不依赖任何第三方库。
///// 通过 TCP + TLS 连接到 Chromecast 设备的 8009 端口。
//final class RawCastClient {
//
//    // MARK: - Protobuf Field Tags
//
//    fileprivate enum FieldTag: UInt8 {
//        case protocolVersion = 0x08
//        case sourceId        = 0x12
//        case destinationId   = 0x1a
//        case namespace       = 0x22
//        case payloadType     = 0x28
//        case payloadUtf8     = 0x32
//    }
//
//    fileprivate enum PayloadType: Int {
//        case string = 0
//    }
//
//    // MARK: - Constants
//
//    fileprivate static let defaultPort: UInt16 = 8009
//    fileprivate static let heartbeatInterval: TimeInterval = 5.0
//    fileprivate static let receiverNamespace = "urn:x-cast:com.google.cast.receiver"
//    fileprivate static let mediaNamespace    = "urn:x-cast:com.google.cast.media"
//    fileprivate static let heartbeatNamespace = "urn:x-cast:com.google.cast.tp.heartbeat"
//    fileprivate static let connectionNamespace = "urn:x-cast:com.google.cast.tp.connection"
//
//    private let appIds: [String] = ["CC1AD845", "048EF37A4"]
//
//    // MARK: - Logging
//
//    private let log = OSLog(subsystem: "com.castdemo.rawcast", category: "RawCastClient")
//
//    // MARK: - State
//
//    private var connection: NWConnection?
//    private let queue = DispatchQueue(label: "com.castdemo.rawcast.connection", qos: .userInitiated)
//    private var heartbeatTimer: DispatchSourceTimer?
//    private var requestId: Int32 = 0
//    private var isConnected: Bool = false
//    private var currentSessionId: String?
//    private var mediaSessionId: Int = 1
//
//    private var host: String = ""
//    private var port: UInt16 = RawCastClient.defaultPort
//
//    // MARK: - Callbacks
//
//    var onConnected: (() -> Void)?
//    var onDisconnected: ((Error?) -> Void)?
//    var onStatusReceived: (([String: Any]) -> Void)?
//    var onMediaStatusReceived: (([String: Any]) -> Void)?
//    var onConnectionError: ((Error) -> Void)?
//
//    // MARK: - Public API
//
//    func connect(host: String, port: UInt16 = defaultPort) {
//        self.host = host
//        self.port = port
//        os_log(.info, log: log, "RawCastClient connecting to %{public}@:%{public}d", host, port)
//
//        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host), port: NWEndpoint.Port(integerLiteral: port))
//        let parameters = NWParameters(tls: createTLSOptions(), tcp: .init())
//        parameters.allowLocalEndpointReuse = true
//        parameters.includePeerToPeer = true
//
//        let conn = NWConnection(to: endpoint, using: parameters)
//        self.connection = conn
//
//        conn.stateUpdateHandler = { [weak self] state in
//            self?.handleStateChange(state)
//        }
//
//        conn.start(queue: queue)
//    }
//
//    func disconnect() {
//        os_log(.info, log: log, "RawCastClient disconnecting")
//        stopHeartbeat()
//        connection?.forceCancel()
//        connection = nil
//        isConnected = false
//    }
//
//    func isCurrentlyConnected() -> Bool {
//        return isConnected
//    }
//
//    func getSessionId() -> String? {
//        return currentSessionId
//    }
//
//    /// 发送 CONNECT 消息，尝试多个 appId
//    func sendConnect(completion: @escaping (Bool) -> Void) {
//        tryAppId(index: 0, completion: completion)
//    }
//
//    private func tryAppId(index: Int, completion: @escaping (Bool) -> Void) {
//        guard index < appIds.count else {
//            os_log(.error, log: log, "All appIds failed")
//            completion(false)
//            return
//        }
//        let appId = appIds[index]
//        os_log(.info, log: log, "Trying CONNECT with appId: %{public}@", appId)
//
//        let payload = #"{"type":"CONNECT","origin":{},"userAgent":"CastDemo","senderInfo":{"sdkType":2,"version":"0","browserVersion":"0","platform":4,"systemVersion":"0","connectionType":1}}"#
//        sendCastMessage(
//            namespace: RawCastClient.connectionNamespace,
//            sourceId: "sender-0",
//            destinationId: "receiver-0",
//            payload: payload
//        )
//
//        DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) { [weak self] in
//            guard let self = self else { return }
//            if !self.isConnected {
//                self.tryAppId(index: index + 1, completion: completion)
//            }
//        }
//    }
//
//    /// GET_STATUS
//    func getStatus() {
//        let payload = #"{"type":"GET_STATUS","requestId":\#(nextRequestId())}"#
//        sendCastMessage(
//            namespace: RawCastClient.receiverNamespace,
//            sourceId: "sender-0",
//            destinationId: "receiver-0",
//            payload: payload
//        )
//    }
//
//    /// LAUNCH 应用
//    func launchApp(appId: String) {
//        let payload = #"{"type":"LAUNCH","requestId":\#(nextRequestId()),"appId":"\#(appId)"}"#
//        sendCastMessage(
//            namespace: RawCastClient.receiverNamespace,
//            sourceId: "sender-0",
//            destinationId: "receiver-0",
//            payload: payload
//        )
//    }
//
//    /// LOAD 媒体
//    func loadMedia(url: String, title: String, mimeType: String, sessionId: String) {
//        let escapedTitle = title.replacingOccurrences(of: "\\", with: "\\\\")
//            .replacingOccurrences(of: "\"", with: "\\\"")
//        let payload = """
//        {"type":"LOAD","requestId":\(nextRequestId()),"sessionId":"\(sessionId)","media":{"contentId":"\(url)","streamType":"BUFFERED","contentType":"\(mimeType)","metadata":{"type":0,"metadataType":0,"title":"\(escapedTitle)"}},"autoplay":true,"currentTime":0}
//        """
//        sendCastMessage(
//            namespace: RawCastClient.mediaNamespace,
//            sourceId: "sender-0",
//            destinationId: "receiver-0",
//            payload: payload
//        )
//    }
//
//    /// PLAY
//    func play() {
//        let payload = #"{"type":"PLAY","requestId":\#(nextRequestId()),"mediaSessionId":\#(mediaSessionId)}"#
//        sendCastMessage(
//            namespace: RawCastClient.mediaNamespace,
//            sourceId: "sender-0",
//            destinationId: "receiver-0",
//            payload: payload
//        )
//    }
//
//    /// PAUSE
//    func pause() {
//        let payload = #"{"type":"PAUSE","requestId":\#(nextRequestId()),"mediaSessionId":\#(mediaSessionId)}"#
//        sendCastMessage(
//            namespace: RawCastClient.mediaNamespace,
//            sourceId: "sender-0",
//            destinationId: "receiver-0",
//            payload: payload
//        )
//    }
//
//    /// STOP
//    func stop() {
//        let payload = #"{"type":"STOP","requestId":\#(nextRequestId()),"mediaSessionId":\#(mediaSessionId)}"#
//        sendCastMessage(
//            namespace: RawCastClient.mediaNamespace,
//            sourceId: "sender-0",
//            destinationId: "receiver-0",
//            payload: payload
//        )
//    }
//
//    /// SEEK
//    func seek(to positionMs: Int64) {
//        let seconds = Double(positionMs) / 1000.0
//        let payload = #"{"type":"SEEK","requestId":\#(nextRequestId()),"mediaSessionId":\#(mediaSessionId),"currentTime":\#(seconds)}"#
//        sendCastMessage(
//            namespace: RawCastClient.mediaNamespace,
//            sourceId: "sender-0",
//            destinationId: "receiver-0",
//            payload: payload
//        )
//    }
//
//    /// SET_VOLUME
//    func setVolume(_ volume: Float) {
//        let clamped = max(0, min(1, volume))
//        let rounded = (clamped * 100).rounded() / 100
//        let payload = #"{"type":"SET_VOLUME","requestId":\#(nextRequestId()),"volume":{"level":\#(rounded)}}"#
//        sendCastMessage(
//            namespace: RawCastClient.receiverNamespace,
//            sourceId: "sender-0",
//            destinationId: "receiver-0",
//            payload: payload
//        )
//    }
//
//    // MARK: - Heartbeat
//
//    private func startHeartbeat() {
//        stopHeartbeat()
//        let timer = DispatchSource.makeTimerSource(queue: queue)
//        timer.schedule(deadline: .now(), repeating: RawCastClient.heartbeatInterval)
//        timer.setEventHandler { [weak self] in
//            self?.sendPing()
//        }
//        timer.resume()
//        heartbeatTimer = timer
//        os_log(.debug, log: log, "Heartbeat started")
//    }
//
//    private func stopHeartbeat() {
//        heartbeatTimer?.cancel()
//        heartbeatTimer = nil
//        os_log(.debug, log: log, "Heartbeat stopped")
//    }
//
//    private func sendPing() {
//        let payload = #"{"type":"PING"}"#
//        sendCastMessage(
//            namespace: RawCastClient.heartbeatNamespace,
//            sourceId: "sender-0",
//            destinationId: "receiver-0",
//            payload: payload
//        )
//    }
//
//    // MARK: - Send Message
//
//    private func sendCastMessage(namespace: String, sourceId: String, destinationId: String, payload: String) {
//        do {
//            let data = try encodeCastMessage(
//                namespace: namespace,
//                sourceId: sourceId,
//                destinationId: destinationId,
//                payloadType: .string,
//                payloadUtf8: payload
//            )
//            sendFrame(data: data)
//        } catch {
//            os_log(.error, log: log, "Failed to encode CastMessage: %{public}@", error.localizedDescription)
//        }
//    }
//
//    private func sendFrame(data: Data) {
//        guard let conn = connection else {
//            os_log(.error, log: log, "No connection to send frame")
//            return
//        }
//        var frame = Data()
//        let length = UInt32(data.count)
//        frame.append(length.bigEndianBytes)
//        frame.append(data)
//
//        conn.send(content: frame, completion: .contentProcessed { [weak self] error in
//            guard let self = self else { return }
//            if let error = error {
//                os_log(.error, log: log, "Send error: %{public}@", error.localizedDescription)
//                self.onConnectionError?(error)
//            }
//        })
//    }
//
//    // MARK: - Receive
//
//    private func startReceiving() {
//        receiveFrameHeader()
//    }
//
//    private func receiveFrameHeader() {
//        guard let conn = connection else { return }
//        let headerSize = 4
//        conn.receive(minimumIncompleteLength: headerSize, maximumLength: headerSize) { [weak self] data, _, _, error in
//            guard let self = self else { return }
//            if let error = error {
//                os_log(.error, log: self.log, "Receive header error: %{public}@", error.localizedDescription)
//                self.handleDisconnect(error: error)
//                return
//            }
//            guard let data = data, data.count == headerSize else {
//                os_log(.error, log: self.log, "Invalid header received")
//                self.handleDisconnect(error: nil)
//                return
//            }
//            let length = UInt32(bigEndianData: data)
//            self.receiveFrameBody(length: Int(length))
//        }
//    }
//
//    private func receiveFrameBody(length: Int) {
//        guard let conn = connection, length > 0 else {
//            receiveFrameHeader()
//            return
//        }
//        conn.receive(minimumIncompleteLength: length, maximumLength: length) { [weak self] data, _, _, error in
//            guard let self = self else { return }
//            if let error = error {
//                os_log(.error, log: self.log, "Receive body error: %{public}@", error.localizedDescription)
//                self.handleDisconnect(error: error)
//                return
//            }
//            guard let data = data else {
//                self.receiveFrameHeader()
//                return
//            }
//            self.handleCastMessage(data: data)
//            self.receiveFrameHeader()
//        }
//    }
//
//    // MARK: - Message Handling
//
//    private func handleCastMessage(data: Data) {
//        do {
//            let message = try decodeCastMessage(data: data)
//            guard let payload = message.payloadUtf8, let payloadData = payload.data(using: .utf8) else {
//                os_log(.debug, log: log, "No UTF-8 payload in message")
//                return
//            }
//
//            if let json = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
//                handleJSONMessage(json: json, namespace: message.namespace)
//            }
//        } catch {
//            os_log(.error, log: log, "Failed to decode message: %{public}@", error.localizedDescription)
//        }
//    }
//
//    private func handleJSONMessage(json: [String: Any], namespace: String) {
//        let type = json["type"] as? String ?? ""
//
//        os_log(.debug, log: log, "Received message type=%{public}@ namespace=%{public}@", type, namespace)
//
//        if namespace == RawCastClient.connectionNamespace {
//            if type == "CLOSE" {
//                handleConnectResponse(json: json)
//            }
//        } else if namespace == RawCastClient.receiverNamespace {
//            if type == "RECEIVER_STATUS" {
//                if let status = json["status"] as? [String: Any],
//                   let apps = status["applications"] as? [[String: Any]] {
//                    if let runningApp = apps.first {
//                        currentSessionId = runningApp["sessionId"] as? String
//                        if let transportId = runningApp["transportId"] as? String {
//                            // Use transportId as destination for media commands
//                        }
//                        isConnected = true
//                        startHeartbeat()
//                        os_log(.info, log: log, "Connected with sessionId: %{public}@", currentSessionId ?? "unknown")
//                        DispatchQueue.main.async { [weak self] in
//                            self?.onConnected?()
//                        }
//                    }
//                }
//                onStatusReceived?(json)
//            } else if type == "MEDIA_STATUS" {
//                // Update mediaSessionId from status
//                if let statusArray = json["status"] as? [[String: Any]],
//                   let firstStatus = statusArray.first,
//                   let msId = firstStatus["mediaSessionId"] as? Int {
//                    mediaSessionId = msId
//                }
//                onStatusReceived?(json)
//            }
//        } else if namespace == RawCastClient.mediaNamespace {
//            if type == "MEDIA_STATUS" {
//                if let statusArray = json["status"] as? [[String: Any]],
//                   let firstStatus = statusArray.first,
//                   let msId = firstStatus["mediaSessionId"] as? Int {
//                    mediaSessionId = msId
//                }
//            }
//            onMediaStatusReceived?(json)
//        } else if namespace == RawCastClient.heartbeatNamespace {
//            if type == "PONG" {
//                os_log(.debug, log: log, "PONG received")
//            }
//        }
//    }
//
//    private func handleConnectResponse(json: [String: Any]) {
//        os_log(.info, log: log, "CLOSE received, connection established")
//        getStatus()
//    }
//
//    // MARK: - State Handling
//
//    private func handleStateChange(_ state: NWConnection.State) {
//        switch state {
//        case .ready:
//            os_log(.info, log: log, "Connection ready")
//            startReceiving()
//            sendConnect { [weak self] success in
//                guard let self = self else { return }
//                if success {
//                    os_log(.info, log: log, "CONNECT handshake succeeded")
//                } else {
//                    os_log(.error, log: log, "CONNECT handshake failed")
//                    self.handleDisconnect(error: nil)
//                }
//            }
//        case .failed(let error):
//            os_log(.error, log: log, "Connection failed: %{public}@", error.localizedDescription)
//            handleDisconnect(error: error)
//        case .cancelled:
//            os_log(.info, log: log, "Connection cancelled")
//            handleDisconnect(error: nil)
//        case .preparing:
//            os_log(.debug, log: log, "Connection preparing...")
//        case .setup:
//            os_log(.debug, log: log, "Connection setup")
//        @unknown default:
//            os_log(.debug, log: log, "Unknown connection state")
//        }
//    }
//
//    private func handleDisconnect(error: Error?) {
//        isConnected = false
//        stopHeartbeat()
//        connection?.forceCancel()
//        connection = nil
//        DispatchQueue.main.async { [weak self] in
//            self?.onDisconnected?(error)
//        }
//    }
//
//    // MARK: - TLS
//
//    private func createTLSOptions() -> NWProtocolTLS.Options {
//        let options = NWProtocolTLS.Options()
//        let secProtocolOptions = nw_tls_copy_sec_protocol_options(
//            unsafeBitCast(options, to: nw_protocol_options_t.self)
//        )
//        sec_protocol_options_set_verify_block(
//            secProtocolOptions,
//            { _, _, completionHandler in
//                completionHandler(true)
//            },
//            queue
//        )
//        return options
//    }
//
//    // MARK: - Request ID
//
//    private func nextRequestId() -> Int32 {
//        requestId += 1
//        return requestId
//    }
//
//    // MARK: - Protobuf Encoding
//
//    /// 编码 CastMessage 为 Protobuf 二进制格式
//    private func encodeCastMessage(
//        namespace: String,
//        sourceId: String,
//        destinationId: String,
//        payloadType: PayloadType,
//        payloadUtf8: String
//    ) throws -> Data {
//        var data = Data()
//
//        // Field 1: protocol_version (varint, default 0 — skip)
//
//        // Field 2: source_id (length-delimited)
//        data.append(encodeVarint(UInt64(FieldTag.sourceId.rawValue)))
//        data.append(encodeLengthDelimited(sourceId))
//
//        // Field 3: destination_id (length-delimited)
//        data.append(encodeVarint(UInt64(FieldTag.destinationId.rawValue)))
//        data.append(encodeLengthDelimited(destinationId))
//
//        // Field 4: namespace (length-delimited)
//        data.append(encodeVarint(UInt64(FieldTag.namespace.rawValue)))
//        data.append(encodeLengthDelimited(namespace))
//
//        // Field 5: payload_type (varint, 0 = STRING)
//        data.append(encodeVarint(UInt64(FieldTag.payloadType.rawValue)))
//        data.append(encodeVarint(UInt64(payloadType.rawValue)))
//
//        // Field 6: payload_utf8 (length-delimited)
//        data.append(encodeVarint(UInt64(FieldTag.payloadUtf8.rawValue)))
//        data.append(encodeLengthDelimited(payloadUtf8))
//
//        return data
//    }
//
//    /// 编码 varint：while value > 0x7F, write (value & 0x7F) | 0x80, value >>= 7; write value & 0x7F
//    private func encodeVarint(_ value: UInt64) -> Data {
//        var result = Data()
//        var v = value
//        while v > 0x7F {
//            result.append(UInt8((v & 0x7F) | 0x80))
//            v >>= 7
//        }
//        result.append(UInt8(v & 0x7F))
//        return result
//    }
//
//    /// 编码 length-delimited 字段
//    private func encodeLengthDelimited(_ string: String) -> Data {
//        guard let utf8Data = string.data(using: .utf8) else { return Data() }
//        var result = encodeVarint(UInt64(utf8Data.count))
//        result.append(utf8Data)
//        return result
//    }
//
//    /// 编码 length-delimited 字段（原始数据）
//    private func encodeLengthDelimited(_ data: Data) -> Data {
//        var result = encodeVarint(UInt64(data.count))
//        result.append(data)
//        return result
//    }
//
//    // MARK: - Protobuf Decoding
//
//    /// 解码 CastMessage
//    private func decodeCastMessage(data: Data) throws -> CastMessage {
//        var protoVersion: Int = 0
//        var sourceId: String = ""
//        var destinationId: String = ""
//        var namespace: String = ""
//        var payloadType: PayloadType = .string
//        var payloadUtf8: String?
//
//        var index = data.startIndex
//        while index < data.endIndex {
//            let (tag, newIndex) = try decodeVarint(data, startIndex: index)
//            index = newIndex
//
//            let fieldNumber = Int(tag >> 3)
//            let wireType = Int(tag & 0x07)
//
//            switch fieldNumber {
//            case 1: // protocol_version
//                let (value, ni) = try decodeVarint(data, startIndex: index)
//                protoVersion = Int(value)
//                index = ni
//            case 2: // source_id
//                let (str, ni) = try decodeLengthDelimitedString(data, startIndex: index)
//                sourceId = str
//                index = ni
//            case 3: // destination_id
//                let (str, ni) = try decodeLengthDelimitedString(data, startIndex: index)
//                destinationId = str
//                index = ni
//            case 4: // namespace
//                let (str, ni) = try decodeLengthDelimitedString(data, startIndex: index)
//                namespace = str
//                index = ni
//            case 5: // payload_type
//                let (value, ni) = try decodeVarint(data, startIndex: index)
//                payloadType = PayloadType(rawValue: Int(value)) ?? .string
//                index = ni
//            case 6: // payload_utf8
//                let (str, ni) = try decodeLengthDelimitedString(data, startIndex: index)
//                payloadUtf8 = str
//                index = ni
//            default:
//                if wireType == 0 { // varint
//                    let (_, ni) = try decodeVarint(data, startIndex: index)
//                    index = ni
//                } else if wireType == 2 { // length-delimited
//                    let (length, ni) = try decodeVarint(data, startIndex: index)
//                    index = ni
//                    let skipEnd = data.index(index, offsetBy: Int(length), limitedBy: data.endIndex) ?? data.endIndex
//                    index = skipEnd
//                } else {
//                    os_log(.debug, log: log, "Unknown wire type: %d", wireType)
//                    break
//                }
//            }
//        }
//
//        return CastMessage(
//            protocolVersion: protoVersion,
//            sourceId: sourceId,
//            destinationId: destinationId,
//            namespace: namespace,
//            payloadType: payloadType,
//            payloadUtf8: payloadUtf8
//        )
//    }
//
//    /// 解码 varint
//    private func decodeVarint(_ data: Data, startIndex: Data.Index) throws -> (UInt64, Data.Index) {
//        var value: UInt64 = 0
//        var shift: UInt = 0
//        var index = startIndex
//        while index < data.endIndex {
//            let byte = data[index]
//            index = data.index(after: index)
//            value |= UInt64(byte & 0x7F) << shift
//            if (byte & 0x80) == 0 {
//                return (value, index)
//            }
//            shift += 7
//            if shift >= 64 {
//                throw RawCastError.invalidVarint
//            }
//        }
//        throw RawCastError.truncatedVarint
//    }
//
//    /// 解码 length-delimited 字符串
//    private func decodeLengthDelimitedString(_ data: Data, startIndex: Data.Index) throws -> (String, Data.Index) {
//        let (length, index) = try decodeVarint(data, startIndex: startIndex)
//        let endIndex = data.index(index, offsetBy: Int(length), limitedBy: data.endIndex) ?? data.endIndex
//        let subData = data[index..<endIndex]
//        let str = String(data: subData, encoding: .utf8) ?? ""
//        return (str, endIndex)
//    }
//}
//
//// MARK: - CastMessage (Internal Model)
//
//private struct CastMessage {
//    let protocolVersion: Int
//    let sourceId: String
//    let destinationId: String
//    let namespace: String
//    let payloadType: RawCastClient.PayloadType
//    let payloadUtf8: String?
//}
//
//// MARK: - Errors
//
//enum RawCastError: Error {
//    case invalidVarint
//    case truncatedVarint
//    case connectionFailed
//    case tlsFailed
//}
//
//// MARK: - UInt32 Big-Endian Extensions
//
//private extension UInt32 {
//    var bigEndianBytes: Data {
//        var value = self.bigEndian
//        return Data(bytes: &value, count: MemoryLayout<UInt32>.size)
//    }
//
//    init(bigEndianData data: Data) {
//        var value: UInt32 = 0
//        _ = withUnsafeMutableBytes(of: &value) { ptr in
//            data.copyBytes(to: ptr, count: Swift.min(data.count, MemoryLayout<UInt32>.size))
//        }
//        self = UInt32(bigEndian: value)
//    }
//}
