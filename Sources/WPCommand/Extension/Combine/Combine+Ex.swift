//
//  Combine+Ex.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/9/4.
//

import Combine
import ObjectiveC
import Foundation
import RxSwift

private var wp_cancellablePointer = "wp_cancellables"


open class CancellableBox {
   public var set: Set<AnyCancellable> = []
}

public extension WPSpace where Base : NSObject{
    
    /// 懒加载垃圾袋
    var cancellables: CancellableBox {
        set {
            WPRunTime.set(base, newValue, withUnsafePointer(to: &wp_cancellablePointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let disposeBag: CancellableBox = WPRunTime.get(base, withUnsafePointer(to: &wp_cancellablePointer, {$0})) else {
                let box = CancellableBox()
                WPRunTime.set(base, box, withUnsafePointer(to: &wp_cancellablePointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return box
            }
            return disposeBag
        }
    }
}

public extension Publisher {
    /// 转换为 RxSwift 的 Observable
    func asObservable() -> Observable<Output> {
        return Observable.create { observer in
            let cancellable = self.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                },
                receiveValue: { value in
                    observer.onNext(value)
                }
            )
            // 取消 Combine 订阅
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
}


public extension Publisher {
    /// 弱引用
    /// - Parameter object: 弱引用对象
    /// - Returns: 输出 (弱对象, 上游值)，自动适配上游 Failure 类型
    func withWeak<Object: AnyObject>(
        _ object: Object
    ) -> AnyPublisher<(Object, Output), Failure> {
        self
            .tryCompactMap { [weak object] value -> (Object, Output)? in
                guard let obj = object else { return nil }
                return (obj, value)
            }
            .mapError { $0 as! Failure } // 自动适配 Failure 类型
            .eraseToAnyPublisher()
    }

    /// 发出值
    static func just(_ value: Output) -> AnyPublisher<Output, Failure> {
        Just(value)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
    
    /// 空订阅
    static func empty() -> AnyPublisher<Output, Failure> {
        Empty(completeImmediately: false)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
    
    /// 发出错误
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
    
    func asAwait() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.first()
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    }
                )
        }
    }
}
