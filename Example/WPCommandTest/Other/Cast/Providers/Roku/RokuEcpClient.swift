//import Foundation
//import os.log
//
///// Roku ECP (External Control Protocol) HTTP 客户端
///// 通过 HTTP 请求控制 Roku 设备，包括查询设备信息、播放媒体、按键控制等
//final class RokuEcpClient {
//
//    private let ipAddress: String
//    private let session: URLSession
//    private let logger = OSLog(subsystem: "com.ioscastdemo.roku", category: "ECP")
//
//    /// 请求超时时间
//    var timeoutInterval: TimeInterval = 10.0
//
//    init(ipAddress: String) {
//        self.ipAddress = ipAddress
//        let config = URLSessionConfiguration.default
//        config.timeoutIntervalForRequest = timeoutInterval
//        config.timeoutIntervalForResource = timeoutInterval
//        config.waitsForConnectivity = false
//        self.session = URLSession(configuration: config)
//    }
//
//    // MARK: - Device Info
//
//    /// 查询设备信息，返回设备 XML 原始数据
//    func queryDeviceInfo(completion: @escaping (Result<Data, Error>) -> Void) {
//        guard let url = buildURL(path: "/query/device-info") else {
//            completion(.failure(RokuEcpError.invalidURL))
//            return
//        }
//
//        performRequest(url: url, method: "GET", body: nil, completion: completion)
//    }
//
//    /// 解析设备信息 XML，提取 friendly-device-name
//    func fetchFriendlyName(completion: @escaping (Result<String, Error>) -> Void) {
//        queryDeviceInfo { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let data):
//                if let name = self.parseFriendlyName(from: data) {
//                    completion(.success(name))
//                } else {
//                    completion(.failure(RokuEcpError.parseError("无法解析 friendly-device-name")))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    // MARK: - Media Playback
//
//    /// 通过 ECP 播放视频
//    /// - Parameters:
//    ///   - url: 视频 URL
//    ///   - title: 视频标题
//    ///   - format: 视频格式 (如 "mp4", "m3u8" 等)
//    func playVideoUrl(url videoUrl: String, title: String, format: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        guard let requestURL = buildURL(path: "/input/15985") else {
//            completion(.failure(RokuEcpError.invalidURL))
//            return
//        }
//
//        let bodyString: String
//        if format == "m3u8" || format == "application/x-mpegURL" || format == "hls" {
//            bodyString = videoUrl
//        } else {
//            bodyString = videoUrl
//        }
//
//        performVoidRequest(url: requestURL, method: "POST", body: bodyString, completion: completion)
//    }
//
//    // MARK: - Keypress Commands
//
//    /// 播放/暂停切换
//    func playPauseToggle(completion: @escaping (Result<Void, Error>) -> Void) {
//        sendKeypress("Play", completion: completion)
//    }
//
//    /// 返回主屏幕
//    func home(completion: @escaping (Result<Void, Error>) -> Void) {
//        sendKeypress("Home", completion: completion)
//    }
//
//    /// 音量+
//    func volumeUp(completion: @escaping (Result<Void, Error>) -> Void) {
//        sendKeypress("VolumeUp", completion: completion)
//    }
//
//    /// 音量-
//    func volumeDown(completion: @escaping (Result<Void, Error>) -> Void) {
//        sendKeypress("VolumeDown", completion: completion)
//    }
//
//    // MARK: - Private Helpers
//
//    private func buildURL(path: String) -> URL? {
//        var components = URLComponents()
//        components.scheme = "http"
//        components.host = ipAddress
//        components.port = 8060
//        components.path = path
//        return components.url
//    }
//
//    private func sendKeypress(_ key: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        guard let url = buildURL(path: "/keypress/\(key)") else {
//            completion(.failure(RokuEcpError.invalidURL))
//            return
//        }
//
//        performVoidRequest(url: url, method: "POST", body: nil, completion: completion)
//    }
//
//    private func performRequest(
//        url: URL,
//        method: String,
//        body: String?,
//        completion: @escaping (Result<Data, Error>) -> Void
//    ) {
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.timeoutInterval = timeoutInterval
//
//        if let body = body {
//            request.httpBody = body.data(using: .utf8)
//            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        }
//
//        os_log(.debug, log: logger, "ECP 请求: %{public}@ %{public}@", method, url.absoluteString)
//
//        let task = session.dataTask(with: request) { [weak self] data, response, error in
//            if let error = error {
//                let nsError = error as NSError
//                if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut {
//                    os_log(.error, log: self?.logger ?? .default, "ECP 请求超时: %{public}@", url.absoluteString)
//                    completion(.failure(RokuEcpError.timeout))
//                } else {
//                    os_log(.error, log: self?.logger ?? .default, "ECP 请求失败: %{public}@", error.localizedDescription)
//                    completion(.failure(RokuEcpError.networkError(error)))
//                }
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                completion(.failure(RokuEcpError.invalidResponse))
//                return
//            }
//
//            guard (200...299).contains(httpResponse.statusCode) else {
//                os_log(.error, log: self?.logger ?? .default, "ECP 响应异常: HTTP %d", httpResponse.statusCode)
//                completion(.failure(RokuEcpError.httpError(httpResponse.statusCode)))
//                return
//            }
//
//            let responseData = data ?? Data()
//            completion(.success(responseData))
//        }
//
//        task.resume()
//    }
//
//    private func performVoidRequest(
//        url: URL,
//        method: String,
//        body: String?,
//        completion: @escaping (Result<Void, Error>) -> Void
//    ) {
//        performRequest(url: url, method: method, body: body) { result in
//            switch result {
//            case .success:
//                completion(.success(()))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    /// 解析设备信息 XML，提取 <friendly-device-name> 标签内容
//    private func parseFriendlyName(from data: Data) -> String? {
//        class SimpleXMLParser: NSObject, XMLParserDelegate {
//            var friendlyName: String?
//            private var currentElement = ""
//
//            func parser(
//                _ parser: XMLParser,
//                didStartElement elementName: String,
//                namespaceURI: String?,
//                qualifiedName qName: String?,
//                attributes attributeDict: [String: String] = [:]
//            ) {
//                currentElement = elementName
//            }
//
//            func parser(_ parser: XMLParser, foundCharacters string: String) {
//                if currentElement == "friendly-device-name" {
//                    friendlyName = (friendlyName ?? "") + string.trimmingCharacters(in: .whitespacesAndNewlines)
//                }
//            }
//        }
//
//        let parser = XMLParser(data: data)
//        let delegate = SimpleXMLParser()
//        parser.delegate = delegate
//        guard parser.parse() else { return nil }
//        return delegate.friendlyName
//    }
//}
//
//// MARK: - Errors
//
//enum RokuEcpError: Error, LocalizedError {
//    case invalidURL
//    case timeout
//    case invalidResponse
//    case httpError(Int)
//    case networkError(Error)
//    case parseError(String)
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "无效的 Roku ECP URL"
//        case .timeout:
//            return "Roku ECP 请求超时"
//        case .invalidResponse:
//            return "Roku ECP 响应无效"
//        case .httpError(let code):
//            return "Roku ECP HTTP 错误: \(code)"
//        case .networkError(let error):
//            return "Roku ECP 网络错误: \(error.localizedDescription)"
//        case .parseError(let message):
//            return "Roku ECP 解析错误: \(message)"
//        }
//    }
//}
