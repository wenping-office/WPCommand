//
//  ObservableType+Ex.swift
//  Pods
//
//  Created by Wen on 2024/9/25.
//

import RxSwift

public enum RxCallBack {
    case onNext
    case afterNext
    case onError
    case afterError
    case onCompleted
    case afterCompleted
    case onSubscribe
    case onSubscribed
    case onDispose
}

public extension ObservableType{
    
    /// 转可选值
    func option() -> Observable<Element?> {
        return flatMap { elmt in
            return Observable<Element?>.just(elmt)
        }
    }
    
    /// 转换为void结果
    func void() -> Observable<Void> {
        return map { _ in
            return ()
        }
    }
    
    /// 乔接do
    /// - Parameters:
    ///   - callBack: 回调
    ///   - callBackTypes: 回调类型
    /// - Returns: 序列
    func did(_ callBack: @escaping (Element?,Error?) -> Void,
             callBackTypes: [RxCallBack] = [.onNext, .afterNext, .onError, .afterError, .onCompleted, .afterCompleted, .onSubscribe, .onSubscribed, .onDispose],
             onNext: ((Element) throws -> Void)? = nil,
             afterNext: ((Element) throws -> Void)? = nil,
             onError: ((Swift.Error) throws -> Void)? = nil,
             afterError: ((Swift.Error) throws -> Void)? = nil,
             onCompleted: (() throws -> Void)? = nil,
             afterCompleted: (() throws -> Void)? = nil,
             onSubscribe: (() -> Void)? = nil,
             onSubscribed: (() -> Void)? = nil,
             onDispose: (() -> Void)? = nil) -> Observable<Element>
    {
        return flatMap { elmt in
            Observable.just(elmt)
        }.do { elmt in
            try onNext?(elmt)
            if callBackTypes.wp_isContent(in: { $0 == .onNext }) {
                callBack(elmt,nil)
            }
        } afterNext: { elmt in
            try afterNext?(elmt)
            if callBackTypes.wp_isContent(in: { $0 == .afterNext }) {
                callBack(elmt,nil)
            }
        } onError: { error in
            try onError?(error)
            if callBackTypes.wp_isContent(in: { $0 == .onError }) {
                callBack(nil,error)
            }
        } afterError: { error in
            try afterError?(error)
            if callBackTypes.wp_isContent(in: { $0 == .afterError }) {
                callBack(nil, error)
            }
        } onCompleted: {
            try onCompleted?()
            if callBackTypes.wp_isContent(in: { $0 == .onCompleted }) {
                callBack(nil,nil)
            }
        } afterCompleted: {
            try afterCompleted?()
            if callBackTypes.wp_isContent(in: { $0 == .afterCompleted }) {
                callBack(nil,nil)
            }
        } onSubscribe: {
            onSubscribe?()
            if callBackTypes.wp_isContent(in: { $0 == .onSubscribe }) {
                callBack(nil,nil)
            }
        } onSubscribed: {
            onSubscribed?()
            if callBackTypes.wp_isContent(in: { $0 == .onSubscribed }) {
                callBack(nil,nil)
            }
        } onDispose: {
            onDispose?()
            if callBackTypes.wp_isContent(in: { $0 == .onDispose }) {
                callBack(nil,nil)
            }
        }
    }

    ///  通知序列执行 源序列成功后才会执行
    /// - Parameter observable: 序列
    func notice<T>(_ observable: Observable<T>) -> Observable<Element>{
        return flatMap{observable.flatMap{_ in Observable.empty() }.catch {_ in Observable.empty()}.startWith($0)}
    }
    
    ///  闭包形式通知序列执行 源序列成功后才会执行
    /// - Parameter source: 序列闭包
    func notice<T>(_ source: @escaping (_ value:Element)->Observable<T>) -> Observable<Element>{
        return flatMap{source($0).flatMap { _ in Observable.empty() }.catch { _ in Observable.empty()}.startWith($0)}
    }
}


