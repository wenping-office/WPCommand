//import Foundation
//import os.log
//
//private let log = OSLog(subsystem: "com.castdemo.airplay", category: "Discovery")
//
//final class AirPlayDiscovery: NSObject {
//
//    private let browser = NetServiceBrowser()
//    private var resolvingServices: Set<NetService> = []
//    private let lock = NSLock()
//
//    var onDeviceFound: ((CastDevice) -> Void)?
//    var onDeviceLost: ((CastDevice) -> Void)?
//
//    private var isSearching = false
//
//    func start() {
//        lock.lock()
//        defer { lock.unlock() }
//
//        guard !isSearching else { return }
//        isSearching = true
//
//        os_log(.info, log: log, "AirPlay discovery started, searching _airplay._tcp.")
//        browser.delegate = self
//        browser.searchForServices(ofType: "_airplay._tcp.", inDomain: "local.")
//    }
//
//    func stop() {
//        lock.lock()
//        defer { lock.unlock() }
//
//        guard isSearching else { return }
//        isSearching = false
//
//        os_log(.info, log: log, "AirPlay discovery stopped")
//        browser.stop()
//        resolvingServices.removeAll()
//    }
//}
//
//// MARK: - NSNetServiceBrowserDelegate
//
//extension AirPlayDiscovery: NetServiceBrowserDelegate {
//
//    func netServiceBrowser(_ browser: NetServiceBrowser,
//                           didFind service: NetService,
//                           moreComing: Bool) {
//        os_log(.debug, log: log, "Found service: %{public}@ (%{public}@)",
//               service.name, service.type)
//
//        service.delegate = self
//        service.resolve(withTimeout: 10.0)
//
//        lock.lock()
//        resolvingServices.insert(service)
//        lock.unlock()
//    }
//
//    func netServiceBrowser(_ browser: NetServiceBrowser,
//                           didRemove service: NetService,
//                           moreComing: Bool) {
//        os_log(.debug, log: log, "Service removed: %{public}@", service.name)
//
//        let deviceId = deviceIdentifier(from: service)
//        let device = CastDevice(
//            id: deviceId,
//            name: service.name,
//            type: .airplay,
//            address: nil,
//            raw: nil
//        )
//        onDeviceLost?(device)
//
//        lock.lock()
//        resolvingServices.remove(service)
//        lock.unlock()
//    }
//
//    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
//        let errorCode = errorDict[NetService.errorCode]?.intValue ?? -1
//        os_log(.error, log: log, "Discovery search failed with error code: %d", errorCode)
//    }
//}
//
//// MARK: - NSNetServiceDelegate
//
//extension AirPlayDiscovery: NetServiceDelegate {
//
//    func netServiceDidResolveAddress(_ sender: NetService) {
//        let hostname = sender.hostName ?? sender.name
//        let addresses = sender.addresses ?? []
//        let port = sender.port
//
//        let txtRecord = sender.txtRecordData().flatMap {
//            NetService.dictionary(fromTXTRecord: $0)
//        } ?? [:]
//
//        let parsed = parseTXTRecord(txtRecord)
//        let deviceId = parsed["deviceId"] ?? deviceIdentifier(from: sender)
//
//        let ipAddress = extractIPAddress(from: addresses)
//        let addressString = ipAddress.map { "\($0):\(port)" } ?? hostname
//
//        os_log(.info, log: log, "Resolved device: %{public}@, hostname: %{public}@, address: %{public}@, port: %d, features: %{public}@",
//               sender.name, hostname, ipAddress ?? "unknown", port, parsed["features"] ?? "unknown")
//
//        let device = CastDevice(
//            id: deviceId,
//            name: sender.name,
//            type: .airplay,
//            address: addressString,
//            raw: AirPlayDeviceInfo(
//                hostname: hostname,
//                ipAddress: ipAddress,
//                port: Int(port),
//                features: parsed["features"],
//                model: parsed["model"],
//                deviceId: deviceId,
//                service: sender
//            )
//        )
//
//        onDeviceFound?(device)
//
//        lock.lock()
//        resolvingServices.remove(sender)
//        lock.unlock()
//    }
//
//    func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
//        let errorCode = errorDict[NetService.errorCode]?.intValue ?? -1
//        os_log(.error, log: log, "Failed to resolve service %{public}@, error code: %d",
//               sender.name, errorCode)
//
//        lock.lock()
//        resolvingServices.remove(sender)
//        lock.unlock()
//    }
//}
//
//// MARK: - Helpers
//
//private extension AirPlayDiscovery {
//
//    func deviceIdentifier(from service: NetService) -> String {
//        let hash = "\(service.name)_\(service.type)_\(service.port)"
//        return hash.data(using: .utf8).map { data in
//            data.map { String(format: "%02x", $0) }.joined()
//        } ?? "\(service.name.hashValue)"
//    }
//
//    func parseTXTRecord(_ record: [String: Data]) -> [String: String] {
//        var result: [String: String] = [:]
//        for (key, data) in record {
//            if let value = String(data: data, encoding: .utf8) {
//                result[key] = value
//            }
//        }
//        return result
//    }
//
//    func extractIPAddress(from addresses: [Data]) -> String? {
//
//        for data in addresses {
//
//            var hostname = [CChar](
//                repeating: 0,
//                count: Int(NI_MAXHOST)
//            )
//
//
//            data.withUnsafeBytes { rawBuffer in
//
//                guard
//                    let sockaddrPtr =
//                        rawBuffer.baseAddress?
//                        .assumingMemoryBound(
//                            to: sockaddr.self
//                        )
//                else {
//                    return
//                }
//
//
//                let sa = sockaddrPtr.pointee
//
//
//                if sa.sa_family == sa_family_t(AF_INET) {
//
//
//                    let addr =
//                    sockaddrPtr
//                        .withMemoryRebound(
//                            to: sockaddr_in.self,
//                            capacity: 1
//                        ) {
//                            $0.pointee
//                        }
//
//
//                    var ipAddr =
//                        addr.sin_addr
//
//
//                    inet_ntop(
//                        AF_INET,
//                        &ipAddr,
//                        &hostname,
//                        socklen_t(NI_MAXHOST)
//                    )
//
//
//                } else if sa.sa_family == sa_family_t(AF_INET6) {
//
//
//                    let addr =
//                    sockaddrPtr
//                        .withMemoryRebound(
//                            to: sockaddr_in6.self,
//                            capacity: 1
//                        ) {
//                            $0.pointee
//                        }
//
//
//                    var ipAddr =
//                        addr.sin6_addr
//
//
//                    inet_ntop(
//                        AF_INET6,
//                        &ipAddr,
//                        &hostname,
//                        socklen_t(NI_MAXHOST)
//                    )
//                }
//            }
//
//
//            let ip =
//            String(cString: hostname)
//
//
//            if !ip.isEmpty {
//
//                return ip
//            }
//        }
//
//
//        return nil
//    }
//}
//
//// MARK: - AirPlay Device Info
//
//struct AirPlayDeviceInfo {
//    let hostname: String
//    let ipAddress: String?
//    let port: Int
//    let features: String?
//    let model: String?
//    let deviceId: String
//    let service: NetService
//}
