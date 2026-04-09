//
//  Combine+Rx.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/10/16.
//

import RxSwift
import Combine

public extension ObservableType {
    /// 转换为 Combine 的 Publisher（忽略错误）
    func asPublisher() -> AnyPublisher<Element, Never> {
        let subject = PassthroughSubject<Element, Never>()
        let disposable = self.subscribe(
            onNext: { subject.send($0) },
            onError: { _ in subject.send(completion: .finished) },
            onCompleted: { subject.send(completion: .finished) }
        )
        
        return subject
            .handleEvents(receiveCancel: { disposable.dispose() })
            .eraseToAnyPublisher()
    }
    
    /// 转换为 Combine 的 Publisher（保留错误）
    func asPublisherWithError() -> AnyPublisher<Element, Error> {
        let subject = PassthroughSubject<Element, Error>()
        let disposable = self.subscribe(
            onNext: { subject.send($0) },
            onError: { subject.send(completion: .failure($0)) },
            onCompleted: { subject.send(completion: .finished) }
        )
        
        return subject
            .handleEvents(receiveCancel: { disposable.dispose() })
            .eraseToAnyPublisher()
    }
}


public extension Publisher {
    /// 闭包形式通知序列执行，源序列成功后才会执行
    /// 最终只输出源序列的值，不输出内部序列的值
    /// - Parameter source: 返回新序列的闭包
    /// - Returns: 只输出源序列值的 Publisher
    func notice<T>(_ source: @escaping (Output) -> AnyPublisher<T, Never>) -> AnyPublisher<Output, Failure> {
        return self
            .flatMap { value -> AnyPublisher<Output, Failure> in
                // 执行通知序列，然后只输出源值
                source(value)
                    .flatMap { _ in Empty<Output, Never>() }  // 忽略通知序列的所有值
                    .catch { _ in Empty<Output, Never>() }    // 忽略错误
                    .append(value)  // 追加源值
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
