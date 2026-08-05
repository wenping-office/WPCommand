//
//  CastKTVProxy.swift
//  Factory
//
//  Created by tmb on 2026/8/3.
//



//import Foundation
//import GCDWebServer
//
//
//final class CastMpdKTVProxy {
//    static let shared = CastMpdKTVProxy()
//    private let server = GCDWebServer()
//    
//    private var handlerAdded = false
//    private var started = false
//    private var ktvProxyBase: String = ""
//    private var ktvMPDURL: URL?
//    private var ktvCacheBaseURL: String = ""  // 完整的缓存路径 BaseURL（已编码）
//    private init() {}
//    
//    // MARK: - 启动代理
//    func start(ktvMPDURL: URL) -> URL? {
//        self.ktvMPDURL = ktvMPDURL
//        
//        // 1. 提取 KTVHTTPCache 代理基础地址
//        guard let scheme = ktvMPDURL.scheme,
//              let host = ktvMPDURL.host,
//              let port = ktvMPDURL.port else {
//            print("❌ [CastKTVProxy] 无效的 ktvMPDURL: \(ktvMPDURL)")
//            return nil
//        }
//        ktvProxyBase = "\(scheme)://\(host):\(port)"
//        
//        // 2. ⭐ 从 absoluteString 提取编码后的原始路径前缀
//        let fullString = ktvMPDURL.absoluteString
//        guard let baseRange = fullString.range(of: ktvProxyBase) else {
//            print("❌ 无法在 fullString 中找到 ktvProxyBase")
//            return nil
//        }
//        let afterBase = String(fullString[baseRange.upperBound...])
//        // afterBase 类似 "/https%3A%2F%2Fsacdn...%2Findex_web.mpd/KTVHTTPCachePlaceHolder/..."
//        guard let placeholderRange = afterBase.range(of: "/KTVHTTPCachePlaceHolder/") else {
//            print("❌ 未找到 /KTVHTTPCachePlaceHolder/")
//            return nil
//        }
//        let encodedPathPrefix = String(afterBase[..<placeholderRange.lowerBound])
//        // encodedPathPrefix 类似 "/https%3A%2F%2F...%2Findex_web.mpd"
//        
//        // 3. ⭐ 构建 KTVHTTPCache 缓存路径 BaseURL（编码正确）
//        ktvCacheBaseURL = "\(ktvProxyBase)\(encodedPathPrefix)/KTVHTTPCachePlaceHolder/"
//        
//        print("""
//        ==========================================
//        [CastKTVProxy] 启动配置
//        KTV 代理基础: \(ktvProxyBase)
//        编码路径前缀: \(encodedPathPrefix)
//        KTV 缓存 BaseURL: \(ktvCacheBaseURL)
//        完整 MPD 代理 URL: \(ktvMPDURL.absoluteString)
//        ==========================================
//        """)
//        
//        addHandler()
//        
//        if !started {
//
//            do {
//                try server.start(options: [
//                    GCDWebServerOption_Port: 8899,
//                    GCDWebServerOption_BindToLocalhost: false
//                ])
//
//                started = true
//
//                print("✅ [CastKTVProxy] GCDWebServer 启动成功，端口 8899")
//
//            } catch {
//                print("❌ [CastKTVProxy] 服务器启动失败: \(error)")
//                return nil
//            }
//        }
//        
//        guard let serverURL = server.serverURL else {
//            print("❌ [CastKTVProxy] 无法获取 serverURL")
//            return nil
//        }
//        
//        let result = serverURL.appendingPathComponent("index.mpd")
//        print("✅ [CastKTVProxy] 投屏地址: \(result)")
//        return result
//    }
//    
//    // MARK: - Handler
//    private func addHandler() {
//
//        guard !handlerAdded else {
//                return
//            }
//
//            handlerAdded = true
//
//            server.addHandler(
//                forMethod: "GET",
//                pathRegex: ".*",
//                request: GCDWebServerRequest.self
//            ) { [weak self] request in
//                return self?.handle(request) ?? GCDWebServerResponse(statusCode: 500)
//            }
//    }
//    
//    // MARK: - 处理请求
//    private func handle(_ request: GCDWebServerRequest) -> GCDWebServerResponse {
//        let path = request.path
//        print("\n📥 [CastKTVProxy] 收到请求: \(path)")
//        
//        let isMPD = path.hasSuffix(".mpd") || path.hasSuffix("index.mpd") || path == "/"
//        print("   🔍 判断: \(isMPD ? "MPD 请求" : "分片请求")")
//        
//        let targetURL: URL?
//        if isMPD {
//            targetURL = ktvMPDURL
//            print("   🎯 MPD → KTVHTTPCache 完整代理地址")
//        } else {
//            let fileName = (path as NSString).lastPathComponent
//            guard !fileName.isEmpty else {
//                print("   ❌ 无法提取文件名")
//                return GCDWebServerResponse(statusCode: 400)
//            }
//            let targetString = ktvCacheBaseURL + fileName
//            targetURL = URL(string: targetString)
//            print("   🎯 分片 → KTVHTTPCache 缓存路径")
//            print("   🔗 目标: \(targetString)")
//        }
//        
//        guard let url = targetURL else {
//            print("   ❌ 构造目标 URL 失败")
//            return GCDWebServerResponse(statusCode: 500)
//        }
//        
//        print("   ➡️ 转发到: \(url.absoluteString)")
//        
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        urlRequest.setValue("identity", forHTTPHeaderField: "Accept-Encoding")
//        
//        request.headers.forEach { key, value in
//            if key.lowercased() != "accept-encoding" {
//                urlRequest.setValue(value, forHTTPHeaderField: key)
//            }
//        }
//        
//        let semaphore = DispatchSemaphore(value: 0)
//        var data: Data?
//        var response: HTTPURLResponse?
//        var error: Error?
//        
//        URLSession.shared.dataTask(with: urlRequest) { d, r, e in
//            data = d
//            response = r as? HTTPURLResponse
//            error = e
//            semaphore.signal()
//        }.resume()
//        
//        semaphore.wait()
//        
//        if let error = error {
//            print("   ❌ 转发错误: \(error)")
//            return GCDWebServerResponse(statusCode: 502)
//        }
//        
//        guard let body = data else {
//            print("   ❌ 响应数据为空")
//            return GCDWebServerResponse(statusCode: 502)
//        }
//        
//        print("   📦 响应状态: \(response?.statusCode ?? 0), 大小: \(body.count) bytes")
//        
//        let isMPDResponse = isMPD ||
//            (response?.allHeaderFields["Content-Type"] as? String)?.contains("dash+xml") == true
//        
//        var finalData = body
//        if isMPDResponse, let xml = String(data: body, encoding: .utf8) {
//            finalData = rewriteBaseURL(xml).data(using: .utf8)!
//            print("   ✏️ MPD BaseURL 已重写为 KTV 缓存路径")
//        }
//        
//        let contentType = isMPDResponse ? "application/dash+xml" :
//            (response?.allHeaderFields["Content-Type"] as? String ?? "application/octet-stream")
//        
////        let result = GCDWebServerDataResponse(data: finalData, contentType: contentType)
////        result.statusCode = response?.statusCode ?? 200
//        
//        let result = GCDWebServerDataResponse(
//            data: finalData,
//            contentType: contentType
//        )
//
//        result.statusCode = response?.statusCode ?? 200
//
//        // CORS
//        result.setValue(
//            "*",
//            forAdditionalHeader: "Access-Control-Allow-Origin"
//        )
//
//        result.setValue(
//            "GET, OPTIONS",
//            forAdditionalHeader: "Access-Control-Allow-Methods"
//        )
//
//        result.setValue(
//            "*",
//            forAdditionalHeader: "Access-Control-Allow-Headers"
//        )
//        response?.allHeaderFields.forEach { key, value in
//            if let key = key as? String,
//               !["Content-Type", "Content-Length", "Content-Encoding"].contains(key) {
//                result.setValue(value as! String, forAdditionalHeader: key)
//            }
//        }
//        
//        print("   ✅ 响应返回，状态码: \(result.statusCode)")
//        return result
//    }
//    
//    // MARK: - 重写 BaseURL
//    private func rewriteBaseURL(_ xml: String) -> String {
//        guard let serverURL = server.serverURL else {
//            return xml
//        }
//        
//        let tag = "<BaseURL>\(serverURL.absoluteString)</BaseURL>"
//        
//        var result = xml
//        
//        // 修改 HEVC codec 兼容性
//        result = result.replacingOccurrences(
//            of: "hev1",
//            with: "hvc1"
//        )
//        
//        // static MPD 使用 on-demand profile 更合理
//        result = result.replacingOccurrences(
//            of: "urn:mpeg:dash:profile:isoff-live:2011",
//            with: "urn:mpeg:dash:profile:isoff-on-demand:2011"
//        )
//        
//        // 替换已有 BaseURL
//        if result.contains("<BaseURL>") {
//            result = result.replacingOccurrences(
//                of: "<BaseURL>.*?</BaseURL>",
//                with: tag,
//                options: .regularExpression
//            )
//        } else {
//            // 放在 MPD 根节点下面
//            result = result.replacingOccurrences(
//                of: "<ProgramInformation>",
//                with: "\(tag)\n<ProgramInformation>"
//            )
//        }
//        
//        print("""
//        ====== CastKTVProxy MPD Rewrite ======
//        BaseURL:
//        \(serverURL.absoluteString)
//        
//        HEVC:
//        hev1 -> hvc1
//        
//        Profile:
//        isoff-live -> isoff-on-demand
//        =====================================
//        """)
//        
//        return result
//    }
//    
//    // MARK: - 停止
//    func stop() {
//        guard started else {
//            return
//        }
//
//        started = false
//
//        if server.isRunning {
//            server.stop()
//        }
//
//        print("⏹ [CastKTVProxy] 服务器已停止")
//    }
//}
//
//
//import Foundation
//import GCDWebServer
//
//final class CastSubtitleProxy {
//
//    static let shared = CastSubtitleProxy()
//
//    private let server = GCDWebServer()
//
//    private var handlerAdded = false
//    private var started = false
//
//    private var subtitles: [String: URL] = [:]
//    private let lock = NSLock()
//
//    private init() {}
//
//
//    // MARK: - Start
//
//    func start() -> URL? {
//
//        if started, server.isRunning {
//            print("⚠️ [CastSubtitleProxy] 已启动")
//            return server.serverURL
//        }
//
//        addHandler()
//
//        do {
//
//            try server.start(options: [
//                GCDWebServerOption_Port: 8898,
//                GCDWebServerOption_BindToLocalhost: false
//            ])
//
//            started = true
//
//            print("""
//            ==========================
//            ✅ [CastSubtitleProxy] Started
//
//            URL:
//            \(server.serverURL?.absoluteString ?? "")
//
//            ==========================
//            """)
//
//            return server.serverURL
//
//        } catch {
//
//            started = false
//            handlerAdded = false
//
//            print(
//                "❌ [CastSubtitleProxy] 启动失败:",
//                error
//            )
//
//            return nil
//        }
//    }
//
//
//    // MARK: - Handler
//
//    private func addHandler() {
//
//        guard !handlerAdded else {
//            return
//        }
//
//
//        server.addHandler(
//            forMethod: "GET",
//            pathRegex: "/subtitle/.*\\.vtt",
//            request: GCDWebServerRequest.self
//        ) { [weak self] request in
//
//            guard let self else {
//                return GCDWebServerResponse(
//                    statusCode: 500
//                )
//            }
//
//            return self.handle(request)
//        }
//
//
//        handlerAdded = true
//    }
//
//    // MARK: - Add Subtitle
//    func addSubtitle(srtURL: URL) -> URL? {
//
//        if !started || !server.isRunning {
//            guard start() != nil else {
//                print("❌ [CastSubtitleProxy] 自动启动失败")
//                return nil
//            }
//        }
//
//        guard let serverURL = server.serverURL else {
//            print("❌ [CastSubtitleProxy] 获取serverURL失败")
//            return nil
//        }
//
//        let id = UUID().uuidString
//
//        lock.lock()
//        subtitles[id] = srtURL
//        lock.unlock()
//
//        let url = serverURL.appendingPathComponent(
//            "subtitle/\(id).vtt"
//        )
//
//        print("""
//        📄 Subtitle Added
//
//        SRT:
//        \(srtURL)
//
//        VTT:
//        \(url)
//        """)
//
//        return url
//    }
//
//
//
//    // MARK: - Handle Request
//
//    private func handle(
//        _ request: GCDWebServerRequest
//    ) -> GCDWebServerResponse {
//
//
//        let id =
//        request.path
//            .replacingOccurrences(
//                of: "/subtitle/",
//                with: ""
//            )
//            .replacingOccurrences(
//                of: ".vtt",
//                with: ""
//            )
//
//
//        lock.lock()
//        let srtURL = subtitles[id]
//        lock.unlock()
//
//
//        guard let srtURL else {
//
//            print(
//                "❌ [CastSubtitleProxy] 找不到字幕:",
//                id
//            )
//
//            return GCDWebServerResponse(
//                statusCode: 404
//            )
//        }
//
//
//
//        let semaphore =
//        DispatchSemaphore(value: 0)
//
//
//        var data: Data?
//        var error: Error?
//
//
//        URLSession.shared.dataTask(
//            with: srtURL
//        ) { d, _, e in
//
//            data = d
//            error = e
//
//            semaphore.signal()
//
//        }.resume()
//
//
//
//        if semaphore.wait(
//            timeout: .now() + 15
//        ) == .timedOut {
//
//
//            print(
//                "❌ [CastSubtitleProxy] 下载超时"
//            )
//
//            return GCDWebServerResponse(
//                statusCode: 504
//            )
//        }
//
//
//
//        if let error {
//
//            print(
//                "❌ [CastSubtitleProxy] 下载失败:",
//                error
//            )
//
//            return GCDWebServerResponse(
//                statusCode: 502
//            )
//        }
//
//
//
//        guard let data,
//              let srt =
//                String(
//                    data: data,
//                    encoding: .utf8
//                )
//        else {
//
//            return GCDWebServerResponse(
//                statusCode: 500
//            )
//        }
//
//
//
//        let vtt =
//        convertSRTToVTT(srt)
//
//
//
//        guard let response =
//                GCDWebServerDataResponse(
//                    text: vtt
//                )
//        else {
//
//            return GCDWebServerResponse(
//                statusCode: 500
//            )
//        }
//
//
//
//        response.setValue(
//            "text/vtt",
//            forAdditionalHeader:
//                "Content-Type"
//        )
//
//
//        response.setValue(
//            "*",
//            forAdditionalHeader:
//                "Access-Control-Allow-Origin"
//        )
//
//
//        print(
//            "✅ [CastSubtitleProxy] 返回 VTT:",
//            vtt.count,
//            "bytes"
//        )
//
//
//        return response
//    }
//
//
//
//    // MARK: - SRT -> VTT
//
//    private func convertSRTToVTT(
//        _ srt: String
//    ) -> String {
//
//
//        var result =
//        "WEBVTT\n\n"
//
//
//        let lines =
//        srt.components(
//            separatedBy: .newlines
//        )
//
//
//        for line in lines {
//
//            if line.contains("-->") {
//
//                result +=
//                line.replacingOccurrences(
//                    of: ",",
//                    with: "."
//                )
//
//            } else {
//
//                result += line
//            }
//
//
//            result += "\n"
//        }
//
//
//        return result
//    }
//
//
//
//    // MARK: - Stop
//
//    func stop() {
//
//
//        if server.isRunning {
//
//            server.stop()
//        }
//
//
//        started = false
//        handlerAdded = false
//
//
//        lock.lock()
//        subtitles.removeAll()
//        lock.unlock()
//
//
//        print(
//            "⏹ [CastSubtitleProxy] stopped"
//        )
//    }
//}
