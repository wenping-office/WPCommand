//
//  ObservableType+Ex.swift
//  Pods
//
//  Created by Wen on 2024/9/25.
//

import RxSwift

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


