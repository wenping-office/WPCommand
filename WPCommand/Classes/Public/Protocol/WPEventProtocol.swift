//
//  WPUIEventProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/10/14.
//

import RxSwift
import UIKit

/// 事件协议，继承协议后将需实现Event结构体，会持有一个Event结构体，结构体内使用
/// PublishSubject协议创建属性，目的归类所有的事件
public protocol WPEventProtocol {
    /// 事件类型 通用结构体作为事件
    associatedtype Event

    /// 事件
    var event: Event { get set }
}
