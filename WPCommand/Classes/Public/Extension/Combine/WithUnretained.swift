//
//  Combine+Ex.swift
//  WPCommand
//
//  Created by new on 2025/5/15.
//

import UIKit
import Combine

@available(iOS 13.0, *)
public struct WPWithUnretained<Upstream: Publisher, Root: AnyObject>: Publisher {
    public typealias Output = (Root, Upstream.Output)
    public typealias Failure = Upstream.Failure

    private let upstream: Upstream
    private let root: Root

    init(upstream: Upstream, root: Root) {
        self.upstream = upstream
        self.root = root
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        upstream
            .compactMap { [weak root] output in
                guard let root = root else { return nil }
                return (root, output)
            }
            .receive(subscriber: subscriber)
    }
}


@available(iOS 13.0, *)
public extension Publisher {
    /// 弱引用
    /// - Parameter root: 对象
    /// - Returns: 结果
    func withUnretained<Root: AnyObject>(_ root: Root) -> WPWithUnretained<Self, Root> {
        return WPWithUnretained(upstream: self, root: root)
    }
}
