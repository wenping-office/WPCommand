//
//  UIControl+Ex.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/9/4.
//

import Foundation
import Combine
import UIKit


public extension WPSpace where Base: UIControl {
    
    /// 监听事件
    /// - Parameter events: 事件
    /// - Returns: 结果
    @available(iOS 14.0, *)
    func publisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
        let subject = PassthroughSubject<Void, Never>()
        base.addAction(UIAction { _ in subject.send() }, for: events)
        return subject.eraseToAnyPublisher()
    }
}
