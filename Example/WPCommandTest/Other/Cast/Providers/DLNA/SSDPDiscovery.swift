//import Foundation
//import Darwin
//import os.log
//
//final class SSDPDiscovery {
//    private let log = OSLog(subsystem: "com.ioscastdemo.dlna", category: "SSDPDiscovery")
//    
//    private let multicastAddress = "239.255.255.250"
//    private let multicastPort: UInt16 = 1900
//
//    private let mSearchMessage: String = {
//        return "M-SEARCH * HTTP/1.1\r\n" +
//               "HOST: 239.255.255.250:1900\r\n" +
//               "MAN: \"ssdp:discover\"\r\n" +
//               "ST: ssdp:all\r\n" +
//               "MX: 3\r\n" +
//               "\r\n"
//    }()
//
//    func discoverMediaRenderers(timeout: TimeInterval = 3.0,
//                                completion: @escaping (_ ip: String, _ locationUrl: String) -> Void) {
//        
//        // 1. 强制触发本地网络权限弹窗
//        triggerLocalNetworkPermission()
//        
//        // 2. 延迟执行，给系统弹窗和用户点击留出时间
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.5) { [weak self] in
//            self?.performDiscovery(timeout: timeout, completion: completion)
//        }
//    }
//
//    // MARK: - Private
//
//    private func performDiscovery(timeout: TimeInterval,
//                                  completion: @escaping (String, String) -> Void) {
//
//        let sock = socket(AF_INET, SOCK_DGRAM, 0)
//        guard sock >= 0 else {
//            print("❌ SSDP socket 创建失败 errno:\(errno)")
//            return
//        }
//        defer { close(sock) }
//
//        // MARK: SO_REUSEADDR & SO_BROADCAST
//        var reuse: Int32 = 1
//        setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))
//        
//        var broadcast: Int32 = 1
//        setsockopt(sock, SOL_SOCKET, SO_BROADCAST, &broadcast, socklen_t(MemoryLayout<Int32>.size))
//
//        // MARK: 获取 WiFi IP
//        guard let localIP = getLocalIPAddress() else {
//            print("❌ SSDP 获取WiFi IP失败")
//            return
//        }
//        print("📡 SSDP Local IP: \(localIP)")
//
//        // MARK: bind 本地地址
//        var localAddr = sockaddr_in()
//        localAddr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
//        localAddr.sin_family = sa_family_t(AF_INET)
//        localAddr.sin_port = 0 // 随机端口
//        
//        inet_pton(AF_INET, localIP, &localAddr.sin_addr)
//
//        let bindResult = withUnsafePointer(to: &localAddr) {
//            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
//                bind(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
//            }
//        }
//        guard bindResult >= 0 else {
//            print("❌ SSDP bind失败 errno: \(errno) (\(String(cString: strerror(errno))))")
//            return
//        }
//        print("✅ SSDP bind成功 IP: \(localIP)")
//
//        // MARK: 【核心修复 1】使用 IP_BOUND_IF 强制绑定到 en0 (Wi-Fi) 网卡
//        // 这能彻底防止 iOS 将多播包错误路由到蜂窝网络导致 errno=65
//        let interfaceIndex = if_nametoindex("en0")
//        if interfaceIndex > 0 {
//            var idx = UInt32(interfaceIndex)
//            let boundResult = setsockopt(sock, IPPROTO_IP, IP_BOUND_IF, &idx, socklen_t(MemoryLayout<UInt32>.size))
//            if boundResult < 0 {
//                print("⚠️ IP_BOUND_IF 设置失败: \(errno)")
//            } else {
//                print("✅ 成功强制绑定到 en0 (Wi-Fi) 网卡")
//            }
//        } else {
//            print("⚠️ 未找到 en0 网卡，请确保 Wi-Fi 已连接")
//        }
//
//        // MARK: 指定 multicast 出口 (双重保险)
//        var interfaceAddr = in_addr()
//        inet_pton(AF_INET, localIP, &interfaceAddr)
//        let multicastInterfaceResult = setsockopt(
//            sock, IPPROTO_IP, IP_MULTICAST_IF, &interfaceAddr, socklen_t(MemoryLayout<in_addr>.size)
//        )
//        if multicastInterfaceResult < 0 {
//            print("⚠️ IP_MULTICAST_IF 设置失败: \(errno)")
//        }
//
//        // MARK: TTL & Timeout
//        var ttl: UInt8 = 2
//        setsockopt(sock, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, socklen_t(MemoryLayout<UInt8>.size))
//
//        var tv = timeval(tv_sec: Int(timeout), tv_usec: 0)
//        setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
//
//        // MARK: M-SEARCH 发送
//        guard let messageData = mSearchMessage.data(using: .utf8) else { return }
//
//        var target = sockaddr_in()
//        target.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
//        target.sin_family = sa_family_t(AF_INET)
//        target.sin_port = multicastPort.bigEndian
//        inet_pton(AF_INET, multicastAddress, &target.sin_addr)
//
//        let sentBytes = messageData.withUnsafeBytes { buffer -> Int in
//            guard let baseAddress = buffer.baseAddress else { return -1 }
//            return withUnsafePointer(to: &target) {
//                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
//                    Darwin.sendto(sock, baseAddress, messageData.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
//                }
//            }
//        }
//
//        if sentBytes < 0 {
//            let err = errno
//            print("""
//            ❌ SSDP SEND FAILED
//            errno: \(err) (\(String(cString: strerror(err))))
//            local: \(localIP) -> target: \(multicastAddress):\(multicastPort)
//            
//            💡 如果依然是 65，请务必：
//            1. 彻底关闭 iPhone 的【蜂窝数据】(4G/5G)！
//            2. 确保 Xcode Target -> Signing & Capabilities 中添加了【Multicast Network】。
//            """)
//            return
//        }
//
//        print("✅ SSDP SEND SUCCESS bytes: \(sentBytes)")
//
//        // MARK: 接收 SSDP 响应
//        var recvBuffer = [UInt8](repeating: 0, count: 4096)
//        var senderAddr = sockaddr_in()
//        var senderLen = socklen_t(MemoryLayout<sockaddr_in>.size)
//
//        while true {
//            let recvBytes = withUnsafeMutablePointer(to: &senderAddr) {
//                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
//                    recvfrom(sock, &recvBuffer, recvBuffer.count, 0, $0, &senderLen)
//                }
//            }
//
//            if recvBytes < 0 {
//                if errno == EAGAIN || errno == EWOULDBLOCK {
//                    print("ℹ️ SSDP 接收超时")
//                } else {
//                    print("❌ SSDP recv失败 errno: \(errno)")
//                }
//                break
//            }
//
//            let data = Data(bytes: recvBuffer, count: recvBytes)
//            guard let response = String(data: data, encoding: .utf8) else { continue }
//            
//            guard let location = extractHeader(named: "LOCATION", from: response) else { continue }
//
//            var ipBuffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
//            var copy = senderAddr
//            inet_ntop(AF_INET, &copy.sin_addr, &ipBuffer, socklen_t(INET_ADDRSTRLEN))
//            let ip = String(cString: ipBuffer)
//
//            print("✅ SSDP发现 IP: \(ip) LOCATION: \(location)")
//            completion(ip, location)
//        }
//    }
//
//    // MARK: - Helpers
//
//    private func extractHeader(named name: String, from response: String) -> String? {
//        let lines = response.components(separatedBy: "\r\n")
//        for line in lines {
//            if line.lowercased().hasPrefix(name.lowercased() + ":") {
//                let parts = line.components(separatedBy: ":")
//                guard parts.count >= 2 else { continue }
//                return parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
//            }
//        }
//        return nil
//    }
//    
//    private func getLocalIPAddress() -> String? {
//        var address: String?
//        var ifaddr: UnsafeMutablePointer<ifaddrs>?
//        guard getifaddrs(&ifaddr) == 0 else { return nil }
//        defer { freeifaddrs(ifaddr) }
//
//        var ptr = ifaddr
//        while ptr != nil {
//            defer { ptr = ptr?.pointee.ifa_next }
//            guard let interface = ptr?.pointee else { continue }
//            
//            let flags = Int32(interface.ifa_flags)
//            let isUp = (flags & (IFF_UP | IFF_RUNNING)) == (IFF_UP | IFF_RUNNING)
//            let isLoopback = (flags & IFF_LOOPBACK) != 0
//            guard isUp, !isLoopback else { continue }
//            
//            let family = interface.ifa_addr.pointee.sa_family
//            if family == UInt8(AF_INET) {
//                let name = String(cString: interface.ifa_name)
//                if !name.hasPrefix("pdp_ip") && !name.hasPrefix("utun") && !name.hasPrefix("lo") {
//                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//                    if getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
//                                   &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
//                        let ip = String(cString: hostname)
//                        if name == "en0" { return ip }
//                        address = ip
//                    }
//                }
//            }
//        }
//        return address
//    }
//    
//    /// 【核心修复 2】强制触发 iOS 本地网络权限弹窗
//    private func triggerLocalNetworkPermission() {
//        // 必须发起真实的网络请求才能触发弹窗！仅仅创建 socket 是没用的。
//        // 这里尝试访问局域网网关（假设是 192.168.3.1，如果不是请改成你的路由器 IP，或随便一个局域网 IP）
//        let url = URL(string: "http://192.168.3.1:80")!
//        var request = URLRequest(url: url)
//        request.timeoutInterval = 1.0 // 1秒超时，不需要真连上，只要触发系统拦截即可
//        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
//    }
//}
