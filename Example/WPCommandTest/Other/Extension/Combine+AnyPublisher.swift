//
//  Combine+AnyPublisher.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/31.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Combine

extension AnyPublisher {
    /// 发出一个值
    static func just(_ value: Output) -> AnyPublisher<Output, Failure> {
        Just(value)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
    
    /// 空订阅不触发下游事件
    static func empty() -> AnyPublisher<Output, Failure> {
        Empty(completeImmediately: false)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
    
    /// 发出一个错误
    static func fail(with error: Failure) -> AnyPublisher<Output, Failure> {
        Fail(error: error)
            .eraseToAnyPublisher()
    }
    
    func asFuture() -> Future<Output, Failure> {
        return Future { promise in
            var cancellable: AnyCancellable?
            cancellable = self.sink { completion in
                if case let .failure(error) = completion {
                    promise(.failure(error))
                }
                cancellable?.cancel()
            } receiveValue: { value in
                promise(.success(value))
                cancellable?.cancel()
            }
        }
    }
}

extension Future{
    /// 发出一个值
    static func just(_ value: Output) -> Future<Output, Failure> {
        return Future<Output, Failure>.init { promise in
            promise(.success(value))
        }
    }
    
    /// 空事件
    static func empty() -> Future<Output, Failure> {
        return Future<Output, Failure>({ _ in})
    }
    
    /// 发出错误
    static func fail(with error: Failure) -> Future<Output, Failure> {
        return Future<Output, Failure>.init { promise in
            promise(.failure(error))
        }
    }
}
