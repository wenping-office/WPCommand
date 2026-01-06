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
