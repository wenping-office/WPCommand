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
    var wp: WPSpace<Self> {
        WPSpace(self)
    }

    static var wp: WPSpace<Self>.Type {
        WPSpace<Self>.self
    }

}

public enum PublisherResult<Value, Failure: Error> {
    case success(Value)
    case failure(Failure)
}

@available(iOS 14.0, *)
public extension Publisher{
    
    /// 合并结果
    func asResult() -> AnyPublisher<PublisherResult<Output, Failure>, Never> {
        map { .success($0) }
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }

    /// 解包结果
    func unwrapResult<T, E>() -> AnyPublisher<T, E>
    where Output == PublisherResult<T, E>, Failure == Never {
        flatMap { result -> AnyPublisher<T, E> in
            switch result {
            case .success(let value):
                return .wp.just(value).eraseToAnyPublisher()
            case .failure(let error):
                return .wp.fail(with: error).eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }
}

public extension WPSpace where Base: Publisher{
    /// create
    /// - Parameter block: 提供一个 closure 手动触发 promise
    /// - Returns: 发出一次值后失效
    static func future(_ block: @escaping (@escaping (Result<Base.Output, Base.Failure>) -> Void) -> Void) -> AnyPublisher<Base.Output, Base.Failure> {
        Deferred {
            Future { promise in
                block { result in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 创建一个可持续发值的PassthroughSubject
    static func create(
        _ block: @escaping (PassthroughSubject<Base.Output, Base.Failure>) -> Void
    ) -> AnyPublisher<Base.Output, Base.Failure> {
        Deferred {
            let subject = PassthroughSubject<Base.Output, Base.Failure>()
            block(subject)
            return subject
        }
        .eraseToAnyPublisher()
    }
    
    /// 发出值
    static func just(_ value: Base.Output) -> AnyPublisher<Base.Output, Base.Failure> {
        Just(value)
            .setFailureType(to: Base.Failure.self)
            .eraseToAnyPublisher()
    }
    
    /// 空订阅
    static func empty() -> AnyPublisher<Base.Output, Base.Failure> {
        Empty(completeImmediately: false)
            .setFailureType(to: Base.Failure.self)
            .eraseToAnyPublisher()
    }
    
    /// 发出错误
    static func fail(with error: Base.Failure) -> AnyPublisher<Base.Output, Base.Failure> {
        Fail(error: error)
            .eraseToAnyPublisher()
    }
    
    /// 弱引用
    /// - Parameter object: 弱引用对象
    /// - Returns: 输出 (弱对象, 上游值)，自动适配上游 Failure 类型
    func withWeak<Object: AnyObject>(
        _ object: Object
    ) -> AnyPublisher<(Object, Base.Output), Base.Failure> {
        base
            .tryCompactMap { [weak object] value -> (Object, Base.Output)? in
                guard let obj = object else { return nil }
                return (obj, value)
            }
            .mapError { $0 as! Base.Failure } // 自动适配 Failure 类型
            .eraseToAnyPublisher()
    }
    
    func asFuture() -> Future<Base.Output, Base.Failure> {
        return Future { promise in
            var cancellable: AnyCancellable?
            cancellable = base.sink { completion in
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
    
    func toAwait() async throws -> Base.Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = base.first()
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
    
    /// 闭包形式通知序列执行，源序列成功后才会执行
    /// 最终只输出源序列的值，不输出内部序列的值
    /// - Parameter source: 返回新序列的闭包
    /// - Returns: 只输出源序列值的 Publisher
    func notice<T>(_ source: @escaping (Base.Output) -> AnyPublisher<T, Never>) -> AnyPublisher<Base.Output, Base.Failure> {
        return base.handleEvents(receiveOutput: { value in
            Task{
                try? await source(value).wp.toAwait()
            }
        }).eraseToAnyPublisher()
    }
}


public extension WPSystem{
    
   /// 超时回掉 TimeoutError
   static func withTimeout<T>(
        seconds: Int,
        operation: @escaping () async throws -> T
    ) async throws -> T {

        try await withThrowingTaskGroup(of: T.self) { group in

            // 正常任务
            group.addTask {
                try await operation()
            }

            // timeout 任务
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
                throw TimeoutError()
            }

            let result = try await group.next()!

            group.cancelAll()

            return result
        }
    }
}


public struct TimeoutError: Error {}

@available(iOS 14.0, *)
public extension WPSpace where Base: Publisher{
    /// 安全重试操作符（固定延迟 + jitter + 次数控制）
        ///
        /// 特点：
        /// - 不使用 Stride 数学运算（避免 Combine 泛型坑）
        /// - 不使用 magnitude / Double 转换
        /// - 每次固定 delay（可 jitter）
        /// - 控制最大重试次数
        /// - 每次失败可回调 onRetry
        func retryWithDelay<S: Scheduler>(
            maxRetries: Int,
            delay: TimeInterval,
            jitter: Double = 0,
            scheduler: S,
            shouldRetry: @escaping (Base.Failure) -> Bool = { _ in true },
            onRetry: ((Int, Base.Failure) -> Void)? = nil
        ) -> AnyPublisher<Base.Output, Base.Failure> {
            return base.catch { error -> AnyPublisher<Base.Output, Base.Failure> in

                // ❌ 不允许重试
                guard maxRetries > 0, shouldRetry(error) else {
                    return Fail(error: error).eraseToAnyPublisher()
                }

                // 🔔 retry 回调
                onRetry?(maxRetries, error)

                // 🎲 jitter（防雪崩）
                let jitterValue: TimeInterval = jitter > 0
                    ? Double.random(in: -jitter...jitter) * delay
                    : 0

                let finalDelay = Swift.max(0, delay + jitterValue)

                // ⏳ 延迟后递归
                return Just(())
                    .delay(for: .seconds(delay), scheduler: scheduler)
                    .flatMap { _ in
                        self.retryWithDelay(
                            maxRetries: maxRetries - 1,
                            delay: finalDelay,
                            jitter: jitter,
                            scheduler: scheduler,
                            shouldRetry: shouldRetry,
                            onRetry: onRetry
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }

}




