//import Foundation
//import os.log
//
///// 设备描述 XML 解析结果
//struct DLNADeviceInfo {
//    let friendlyName: String
//    let avTransportControlURL: String?
//    let renderingControlControlURL: String?
//}
//
///// DLNA SOAP 控制层：设备信息获取、AVTransport、RenderingControl
//final class SOAPControl {
//
//    private let log = OSLog(subsystem: "com.ioscastdemo.dlna", category: "SOAPControl")
//
//    private let session: URLSession = {
//        let config = URLSessionConfiguration.default
//        config.timeoutIntervalForRequest = 10
//        config.timeoutIntervalForResource = 30
//        return URLSession(configuration: config)
//    }()
//
//    // MARK: - Device Info
//
//    /// 从设备描述 XML 中获取设备名称和控制 URL
//    func fetchDeviceInfo(locationUrl: String,
//                         completion: @escaping (DLNADeviceInfo?) -> Void) {
//        guard let url = URL(string: locationUrl) else {
//            os_log(.error, log: log, "SOAP: 无效的 location URL: %{public}@", locationUrl)
//            completion(nil)
//            return
//        }
//
//        let baseURL = url.deletingLastPathComponent()
//
//        let task = session.dataTask(with: url) { [weak self] data, response, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                os_log(.error, log: self.log, "SOAP: 获取设备描述失败: %{public}@", error.localizedDescription)
//                completion(nil)
//                return
//            }
//
//            guard let data = data, let xmlString = String(data: data, encoding: .utf8) else {
//                os_log(.error, log: self.log, "SOAP: 设备描述数据无效")
//                completion(nil)
//                return
//            }
//
//            let friendlyName = self.extractElement("friendlyName", from: xmlString)
//            let avTransportPath = self.extractControlURL(for: "urn:schemas-upnp-org:service:AVTransport:1",
//                                                         from: xmlString)
//            let renderingControlPath = self.extractControlURL(for: "urn:schemas-upnp-org:service:RenderingControl:1",
//                                                              from: xmlString)
//
//            let avTransportFull = avTransportPath.flatMap { self.resolveURL($0, baseURL: baseURL) }
//            let renderingControlFull = renderingControlPath.flatMap { self.resolveURL($0, baseURL: baseURL) }
//
//            let info = DLNADeviceInfo(
//                friendlyName: friendlyName ?? "未知设备",
//                avTransportControlURL: avTransportFull,
//                renderingControlControlURL: renderingControlFull
//            )
//
//            os_log(.info, log: self.log,
//                   "SOAP: 设备信息 name=%{public}@ avTransport=%{public}@ renderingControl=%{public}@",
//                   info.friendlyName,
//                   info.avTransportControlURL ?? "nil",
//                   info.renderingControlControlURL ?? "nil")
//
//            completion(info)
//        }
//        task.resume()
//    }
//
//    // MARK: - AVTransport
//
//    /// 设置播放 URI
//    func setAVTransportURI(controlUrl: String,
//                           mediaUrl: String,
//                           title: String,
//                           mimeType: String,
//                           completion: @escaping (Bool) -> Void) {
//        let didlMetadata = buildDIDLMetadata(title: title, mimeType: mimeType, url: mediaUrl)
//        let bodyXML = """
//        <u:SetAVTransportURI xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
//            <InstanceID>0</InstanceID>
//            <CurrentURI>\(escapeXML(mediaUrl))</CurrentURI>
//            <CurrentURIMetaData>\(escapeXML(didlMetadata))</CurrentURIMetaData>
//        </u:SetAVTransportURI>
//        """
//
//        sendSOAPRequest(
//            controlUrl: controlUrl,
//            serviceType: "urn:schemas-upnp-org:service:AVTransport:1",
//            action: "SetAVTransportURI",
//            bodyXML: bodyXML,
//            completion: completion
//        )
//    }
//
//    /// 播放
//    func play(controlUrl: String, completion: @escaping (Bool) -> Void) {
//        let bodyXML = """
//        <u:Play xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
//            <InstanceID>0</InstanceID>
//            <Speed>1</Speed>
//        </u:Play>
//        """
//
//        sendSOAPRequest(
//            controlUrl: controlUrl,
//            serviceType: "urn:schemas-upnp-org:service:AVTransport:1",
//            action: "Play",
//            bodyXML: bodyXML,
//            completion: completion
//        )
//    }
//
//    /// 暂停
//    func pause(controlUrl: String, completion: @escaping (Bool) -> Void) {
//        let bodyXML = """
//        <u:Pause xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
//            <InstanceID>0</InstanceID>
//        </u:Pause>
//        """
//
//        sendSOAPRequest(
//            controlUrl: controlUrl,
//            serviceType: "urn:schemas-upnp-org:service:AVTransport:1",
//            action: "Pause",
//            bodyXML: bodyXML,
//            completion: completion
//        )
//    }
//
//    /// 停止
//    func stop(controlUrl: String, completion: @escaping (Bool) -> Void) {
//        let bodyXML = """
//        <u:Stop xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
//            <InstanceID>0</InstanceID>
//        </u:Stop>
//        """
//
//        sendSOAPRequest(
//            controlUrl: controlUrl,
//            serviceType: "urn:schemas-upnp-org:service:AVTransport:1",
//            action: "Stop",
//            bodyXML: bodyXML,
//            completion: completion
//        )
//    }
//
//    // MARK: - RenderingControl
//
//    /// 设置音量 (0.0 ~ 1.0)
//    func setVolume(controlUrl: String, volume: Float, completion: @escaping (Bool) -> Void) {
//        let clampedVolume = max(0.0, min(1.0, volume))
//        let dlnaVolume = Int(clampedVolume * 100)
//
//        let bodyXML = """
//        <u:SetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1">
//            <InstanceID>0</InstanceID>
//            <Channel>Master</Channel>
//            <DesiredVolume>\(dlnaVolume)</DesiredVolume>
//        </u:SetVolume>
//        """
//
//        sendSOAPRequest(
//            controlUrl: controlUrl,
//            serviceType: "urn:schemas-upnp-org:service:RenderingControl:1",
//            action: "SetVolume",
//            bodyXML: bodyXML,
//            completion: completion
//        )
//    }
//
//    // MARK: - Private: SOAP 请求
//
//    private func sendSOAPRequest(controlUrl: String,
//                                 serviceType: String,
//                                 action: String,
//                                 bodyXML: String,
//                                 completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: controlUrl) else {
//            os_log(.error, log: log, "SOAP: 无效的 control URL: %{public}@", controlUrl)
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
//        os_log(.debug, log: log, "SOAP: 发送 %{public}@ → %{public}@", action, controlUrl)
//
//        let task = session.dataTask(with: request) { [weak self] data, response, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                os_log(.error, log: self.log, "SOAP: %{public}@ 请求失败: %{public}@", action, error.localizedDescription)
//                completion(false)
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                if httpResponse.statusCode == 200 {
//                    os_log(.info, log: self.log, "SOAP: %{public}@ 成功", action)
//                    completion(true)
//                } else {
//                    os_log(.error, log: self.log, "SOAP: %{public}@ HTTP %{public}d", action, httpResponse.statusCode)
//                    completion(false)
//                }
//            } else {
//                completion(false)
//            }
//        }
//        task.resume()
//    }
//
//    // MARK: - Private: XML 解析
//
//    /// 从 XML 中提取指定元素的内容
//    private func extractElement(_ tagName: String, from xml: String) -> String? {
//        let pattern = "<\(tagName)[^>]*>(.*?)</\(tagName)>"
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
//            return nil
//        }
//        let range = NSRange(xml.startIndex..., in: xml)
//        guard let match = regex.firstMatch(in: xml, options: [], range: range) else {
//            return nil
//        }
//        if let contentRange = Range(match.range(at: 1), in: xml) {
//            return String(xml[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
//        }
//        return nil
//    }
//
//    /// 从 XML 中提取指定 serviceType 的 controlURL
//    private func extractControlURL(for serviceType: String, from xml: String) -> String? {
//        // 匹配 <serviceType>...</serviceType> 内的 <controlURL>...</controlURL>
//        let pattern = "<serviceType>\\s*\(NSRegularExpression.escapedPattern(for: serviceType))\\s*</serviceType>.*?<controlURL>\\s*(.*?)\\s*</controlURL>"
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
//            return nil
//        }
//        let range = NSRange(xml.startIndex..., in: xml)
//        guard let match = regex.firstMatch(in: xml, options: [], range: range) else {
//            return nil
//        }
//        if let urlRange = Range(match.range(at: 1), in: xml) {
//            return String(xml[urlRange]).trimmingCharacters(in: .whitespacesAndNewlines)
//        }
//        return nil
//    }
//
//    /// 将相对路径解析为绝对 URL
//    private func resolveURL(_ path: String, baseURL: URL) -> String? {
//        if path.hasPrefix("http://") || path.hasPrefix("https://") {
//            return path
//        }
//        return URL(string: path, relativeTo: baseURL)?.absoluteString
//    }
//
//    /// 构建 DIDL-Lite 元数据 XML
//    private func buildDIDLMetadata(title: String, mimeType: String, url: String) -> String {
//        let escapedTitle = escapeXML(title)
//        let escapedUrl = escapeXML(url)
//        let escapedMime = escapeXML(mimeType)
//
//        return """
//        <DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" \
//        xmlns:dc="http://purl.org/dc/elements/1.1/" \
//        xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" \
//        xmlns:dlna="urn:schemas-dlna-org:metadata-1-0/">\
//        <item id="0" parentID="-1" restricted="1">\
//        <dc:title>\(escapedTitle)</dc:title>\
//        <upnp:class>object.item.videoItem</upnp:class>\
//        <res protocolInfo="http-get:*:\(escapedMime):*" size="">\(escapedUrl)</res>\
//        </item></DIDL-Lite>
//        """
//    }
//
//    /// XML 转义
//    private func escapeXML(_ string: String) -> String {
//        var result = string
//        result = result.replacingOccurrences(of: "&", with: "&amp;")
//        result = result.replacingOccurrences(of: "<", with: "&lt;")
//        result = result.replacingOccurrences(of: ">", with: "&gt;")
//        result = result.replacingOccurrences(of: "\"", with: "&quot;")
//        result = result.replacingOccurrences(of: "'", with: "&apos;")
//        return result
//    }
//}
