//import Foundation
//import os.log
//
//private let log = OSLog(subsystem: "com.castdemo.airplay", category: "Client")
//
//final class AirPlayClient {
//
//    private let host: String
//    private let port: Int
//    private let scheme: String
//    private let timeout: TimeInterval
//
//    private lazy var session: URLSession = {
//        let config = URLSessionConfiguration.default
//        config.timeoutIntervalForRequest = timeout
//        config.timeoutIntervalForResource = timeout * 2
//        config.waitsForConnectivity = false
//        return URLSession(configuration: config)
//    }()
//
//    private let baseURL: String
//
//    var isAvailable: Bool {
//        let result = testTCPConnection()
//        os_log(.debug, log: log, "TCP connection test to %{public}@:%d → %{public}@",
//               host, port, result ? "success" : "failed")
//        return result
//    }
//
//    init(host: String, port: Int, timeout: TimeInterval = 10.0) {
//        self.host = host
//        self.port = port
//        self.timeout = timeout
//
//        if port == 443 {
//            self.scheme = "https"
//        } else {
//            self.scheme = "http"
//        }
//
//        self.baseURL = "\(scheme)://\(host):\(port)"
//    }
//
//    // MARK: - TCP Connection Test
//
//    private func testTCPConnection() -> Bool {
//        let sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
//        guard sock >= 0 else { return false }
//        defer { close(sock) }
//
//        var addr = sockaddr_in()
//        addr.sin_family = sa_family_t(AF_INET)
//        addr.sin_port = UInt16(port).bigEndian
//        addr.sin_addr.s_addr = inet_addr(host)
//
//        let result = withUnsafePointer(to: &addr) {
//            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
//                Darwin.connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
//            }
//        }
//
//        return result == 0
//    }
//
//    // MARK: - Play
//
//    func play(url: String, position: Double = 0.0, completion: @escaping (Bool, String?) -> Void) {
//        let endpoint = "\(baseURL)/play"
//        let body = "Content-Location: \(url)\nStart-Position: \(position)\n"
//
//        os_log(.info, log: log, "POST /play → %{public}@, position: %.2f", url, position)
//
//        performRequest(urlString: endpoint, method: "POST", body: body, contentType: "text/parameters") { data, response, error in
//            if let error = error {
//                os_log(.error, log: log, "POST /play failed: %{public}@", error.localizedDescription)
//                completion(false, error.localizedDescription)
//                return
//            }
//            completion(true, nil)
//        }
//    }
//
//    // MARK: - Playback Info
//
//    func fetchPlaybackInfo(completion: @escaping (AirPlayPlaybackInfo?) -> Void) {
//        let endpoint = "\(baseURL)/playback-info"
//
//        performRequest(urlString: endpoint, method: "GET", body: nil, contentType: nil) { data, response, error in
//            guard let data = data, error == nil else {
//                os_log(.error, log: log, "GET /playback-info failed: %{public}@",
//                       error?.localizedDescription ?? "unknown")
//                completion(nil)
//                return
//            }
//
//            let info = AirPlayPlaybackInfoParser.parse(data: data)
//            os_log(.debug, log: log, "GET /playback-info → rate: %.2f, readyToPlay: %d",
//                   info.rate ?? 0, info.readyToPlay ? 1 : 0)
//            completion(info)
//        }
//    }
//
//    // MARK: - Scrub (Position / Duration)
//
//    func fetchScrub(completion: @escaping (Double?, Double?) -> Void) {
//        let endpoint = "\(baseURL)/scrub"
//
//        performRequest(urlString: endpoint, method: "GET", body: nil, contentType: nil) { data, response, error in
//            guard let data = data, error == nil else {
//                os_log(.error, log: log, "GET /scrub failed: %{public}@",
//                       error?.localizedDescription ?? "unknown")
//                completion(nil, nil)
//                return
//            }
//
//            let parsed = AirPlayPlaybackInfoParser.parse(data: data)
//            os_log(.debug, log: log, "GET /scrub → position: %.2f, duration: %.2f",
//                   parsed.position ?? 0, parsed.duration ?? 0)
//            completion(parsed.position, parsed.duration)
//        }
//    }
//
//    // MARK: - Rate (Play / Pause)
//
//    func setRate(_ rate: Double, completion: @escaping (Bool) -> Void) {
//        let endpoint = "\(baseURL)/rate"
//        let body = "value=\(rate)"
//
//        os_log(.info, log: log, "POST /rate → %.2f", rate)
//
//        performRequest(urlString: endpoint, method: "POST", body: body, contentType: "text/parameters") { data, response, error in
//            if let error = error {
//                os_log(.error, log: log, "POST /rate failed: %{public}@", error.localizedDescription)
//                completion(false)
//                return
//            }
//            completion(true)
//        }
//    }
//
//    // MARK: - Stop
//
//    func stop(completion: @escaping (Bool) -> Void) {
//        let endpoint = "\(baseURL)/stop"
//
//        os_log(.info, log: log, "POST /stop")
//
//        performRequest(urlString: endpoint, method: "POST", body: nil, contentType: nil) { data, response, error in
//            if let error = error {
//                os_log(.error, log: log, "POST /stop failed: %{public}@", error.localizedDescription)
//                completion(false)
//                return
//            }
//            completion(true)
//        }
//    }
//
//    // MARK: - Volume
//
//    func setVolume(_ volume: Float, completion: @escaping (Bool) -> Void) {
//        let endpoint = "\(baseURL)/volume"
//        let body = "volume=\(volume)"
//
//        os_log(.info, log: log, "POST /volume → %.2f", volume)
//
//        performRequest(urlString: endpoint, method: "POST", body: body, contentType: "text/parameters") { data, response, error in
//            if let error = error {
//                os_log(.error, log: log, "POST /volume failed: %{public}@", error.localizedDescription)
//                completion(false)
//                return
//            }
//            completion(true)
//        }
//    }
//
//    // MARK: - Reverse
//
//    func reverse(completion: @escaping (Bool) -> Void) {
//        let endpoint = "\(baseURL)/reverse"
//
//        os_log(.info, log: log, "POST /reverse")
//
//        performRequest(urlString: endpoint, method: "POST", body: nil, contentType: nil) { data, response, error in
//            if let error = error {
//                os_log(.error, log: log, "POST /reverse failed: %{public}@", error.localizedDescription)
//                completion(false)
//                return
//            }
//            completion(true)
//        }
//    }
//
//    // MARK: - Request Helper
//
//    private func performRequest(urlString: String,
//                                 method: String,
//                                 body: String?,
//                                 contentType: String?,
//                                 completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
//        guard let url = URL(string: urlString) else {
//            os_log(.error, log: log, "Invalid URL: %{public}@", urlString)
//            completion(nil, nil, NSError(domain: "AirPlayClient", code: -1,
//                                         userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.timeoutInterval = timeout
//
//        if let contentType = contentType {
//            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
//        }
//
//        if let body = body {
//            request.httpBody = body.data(using: .utf8)
//        }
//
//        // Allow arbitrary loads for AirPlay devices (commonly HTTP)
//        let task = session.dataTask(with: request) { data, response, error in
//            let httpResponse = response as? HTTPURLResponse
//            if let statusCode = httpResponse?.statusCode {
//                os_log(.debug, log: log, "%{public}@ %{public}@ → %d",
//                       method, urlString, statusCode)
//            }
//            completion(data, response, error)
//        }
//        task.resume()
//    }
//}
//
//// MARK: - Playback Info
//
//struct AirPlayPlaybackInfo {
//    let duration: Double?
//    let position: Double?
//    let rate: Double?
//    let readyToPlay: Bool
//    let playbackBufferEmpty: Bool
//    let playbackBufferFull: Bool
//    let playbackLikelyToKeepUp: Bool
//    let loadedTimeRanges: [NSRange]
//    let seekableTimeRanges: [NSRange]
//}
//
//// MARK: - Playback Info Parser
//
//private enum AirPlayPlaybackInfoParser {
//
//    static func parse(data: Data) -> AirPlayPlaybackInfo {
//        var duration: Double?
//        var position: Double?
//        var rate: Double?
//        var readyToPlay = false
//        var playbackBufferEmpty = false
//        var playbackBufferFull = false
//        var playbackLikelyToKeepUp = false
//        var loadedTimeRanges: [NSRange] = []
//        var seekableTimeRanges: [NSRange] = []
//
//        let parser = AirPlayPlistParser(data: data)
//        let dict = parser.parse()
//
//        if let v = dict["duration"] as? Double {
//            duration = v
//        }
//        if let v = dict["position"] as? Double {
//            position = v
//        }
//        if let v = dict["rate"] as? Double {
//            rate = v
//        }
//        if let v = dict["readyToPlay"] as? Bool {
//            readyToPlay = v
//        }
//        if let v = dict["playbackBufferEmpty"] as? Bool {
//            playbackBufferEmpty = v
//        }
//        if let v = dict["playbackBufferFull"] as? Bool {
//            playbackBufferFull = v
//        }
//        if let v = dict["playbackLikelyToKeepUp"] as? Bool {
//            playbackLikelyToKeepUp = v
//        }
//        if let ranges = dict["loadedTimeRanges"] as? [[String: Any]] {
//            loadedTimeRanges = ranges.compactMap { parseRange(from: $0) }
//        }
//        if let ranges = dict["seekableTimeRanges"] as? [[String: Any]] {
//            seekableTimeRanges = ranges.compactMap { parseRange(from: $0) }
//        }
//
//        return AirPlayPlaybackInfo(
//            duration: duration,
//            position: position,
//            rate: rate,
//            readyToPlay: readyToPlay,
//            playbackBufferEmpty: playbackBufferEmpty,
//            playbackBufferFull: playbackBufferFull,
//            playbackLikelyToKeepUp: playbackLikelyToKeepUp,
//            loadedTimeRanges: loadedTimeRanges,
//            seekableTimeRanges: seekableTimeRanges
//        )
//    }
//
//    private static func parseRange(from dict: [String: Any]) -> NSRange? {
//        guard let location = (dict["location"] as? NSNumber)?.doubleValue,
//              let length = (dict["length"] as? NSNumber)?.doubleValue else {
//            return nil
//        }
//        return NSRange(location: Int(location), length: Int(length))
//    }
//}
//
//// MARK: - Simple Plist Parser
//
//private final class AirPlayPlistParser {
//
//    private let data: Data
//    private var index: Int = 0
//
//    init(data: Data) {
//        self.data = data
//    }
//
//    func parse() -> [String: Any] {
//        guard let text = String(data: data, encoding: .utf8) else {
//            return [:]
//        }
//        return parseApplePlistBody(text)
//    }
//
//    private func parseApplePlistBody(_ text: String) -> [String: Any] {
//        var result: [String: Any] = [:]
//        let lines = text.components(separatedBy: .newlines)
//
//        var key: String?
//        var isCollectingDict = false
//        var dictKey: String?
//        var dictResult: [String: Any] = [:]
//
//        var isCollectingArray = false
//        var arrayKey: String?
//        var arrayResult: [[String: Any]] = []
//
//        for line in lines {
//            let trimmed = line.trimmingCharacters(in: .whitespaces)
//
//            if trimmed.hasPrefix("</dict>") {
//                if isCollectingDict, let dk = dictKey {
//                    result[dk] = dictResult
//                    isCollectingDict = false
//                    dictKey = nil
//                    dictResult = [:]
//                }
//                continue
//            }
//
//            if trimmed.hasPrefix("</array>") {
//                if isCollectingArray, let ak = arrayKey {
//                    result[ak] = arrayResult
//                    isCollectingArray = false
//                    arrayKey = nil
//                    arrayResult = []
//                }
//                continue
//            }
//
//            if isCollectingDict {
//                if trimmed.hasPrefix("<key>"), let k = extractKey(from: trimmed) {
//                    key = k
//                } else if let k = key, let value = extractSimpleValue(from: trimmed) {
//                    dictResult[k] = value
//                    key = nil
//                } else if let k = key, trimmed.hasPrefix("<dict>") {
//                    isCollectingDict = true
//                    dictKey = k
//                    dictResult = [:]
//                }
//                continue
//            }
//
//            if isCollectingArray {
//                if trimmed.hasPrefix("<dict>") {
//                    // nested dict in array — simplistic skip
//                } else if trimmed.hasPrefix("</dict>") {
//                    // end of nested dict
//                }
//                continue
//            }
//
//            if trimmed.hasPrefix("<key>"), let k = extractKey(from: trimmed) {
//                key = k
//            } else if let k = key, let value = extractSimpleValue(from: trimmed) {
//                result[k] = value
//                key = nil
//            } else if let k = key, trimmed.hasPrefix("<dict>") {
//                isCollectingDict = true
//                dictKey = k
//                dictResult = [:]
//                key = nil
//            } else if let k = key, trimmed.hasPrefix("<array>") {
//                isCollectingArray = true
//                arrayKey = k
//                arrayResult = []
//                key = nil
//            }
//        }
//
//        return result
//    }
//
//    private func extractKey(from line: String) -> String? {
//        guard let start = line.range(of: "<key>"),
//              let end = line.range(of: "</key>") else { return nil }
//        let keyRange = start.upperBound..<end.lowerBound
//        return String(line[keyRange])
//    }
//
//    private func extractSimpleValue(from line: String) -> Any? {
//        if line.hasPrefix("<real>") || line.hasPrefix("<integer>") {
//            let pattern = try? NSRegularExpression(
//                pattern: "<(?:real|integer)>([^<]+)</(?:real|integer)>",
//                options: []
//            )
//            if let match = pattern?.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)),
//               let range = Range(match.range(at: 1), in: line) {
//                let value = String(line[range])
//                return Double(value)
//            }
//        }
//
//        if line.hasPrefix("<string>") {
//            let pattern = try? NSRegularExpression(
//                pattern: "<string>([^<]*)</string>",
//                options: []
//            )
//            if let match = pattern?.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)),
//               let range = Range(match.range(at: 1), in: line) {
//                return String(line[range])
//            }
//        }
//
//        if line.hasPrefix("<true/>") {
//            return true
//        }
//        if line.hasPrefix("<false/>") {
//            return false
//        }
//
//        return nil
//    }
//}
