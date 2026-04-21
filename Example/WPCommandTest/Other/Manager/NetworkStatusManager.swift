//
//  NetworkStatusManager.swift
//  WPCommand
//
//  Created by tmb on 2026/4/21.
//

import Foundation
import Network
import Combine

/// 网络状态封装器
class NetworkStatusManager {
    static let shared = NetworkStatusManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    /// Combine 发布器，发出网络状态变化
    private let statusSubject = PassthroughSubject<NWPath.Status, Never>()
    
    /// 外部订阅
    var statusPublisher: AnyPublisher<NWPath.Status, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    private var started = false
    
    /// 开始监听网络状态，只会在第一次调用时启动
    func startMonitoring() {
        guard !started else { return } // 确保只启动一次
        started = true
        
        monitor.pathUpdateHandler = { [weak self] path in
            self?.statusSubject.send(path.status)
        }
        monitor.start(queue: queue)
    }
    
    /// 检查当前网络状态
    func currentStatus() -> NWPath.Status {
        return monitor.currentPath.status
    }
}
