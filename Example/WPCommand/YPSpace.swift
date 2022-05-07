//
//  YPSpace.swift
//  ypCommand
//
//  Created by WenPing on 2021/11/1.
//

import RxSwift
import UIKit

/// 命名空间
public struct YPSpace<Base> {
    /// 命名空间类
    public var base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

/// 命名空间协议
public protocol YPSpaceProtocol {
    associatedtype Base

    var yp: Base { get set }

    static var yp: Base.Type { get set }
}

/// 命名空间实现
public extension YPSpaceProtocol {
    static var yp: YPSpace<Self>.Type {
        get { return YPSpace<Self>.self }
        set {}
    }

    var yp: YPSpace<Self> {
        get { return YPSpace(self) }
        set {}
    }
}

