//
//  WPSpace.swift
//  WPCommand
//
//  Created by WenPing on 2021/11/1.
//

import UIKit
import RxSwift


/// 命名空间
public struct WPSpace<Base> {
    
    /// 命名空间类
    public var base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

/// 命名空间协议
public protocol WPSpaceProtocol {
    
    associatedtype Base

    var wp: Base { get set }
    
    static var wp: Base.Type { get set }
}

/// 命名空间实现
public extension WPSpaceProtocol {

    static var wp: WPSpace<Self>.Type {
        get { return WPSpace<Self>.self }
        set {}
    }

    var wp: WPSpace<Self> {
        get { return WPSpace(self) }
        set {}
    }
}

extension NSObject: WPSpaceProtocol{}
extension String: WPSpaceProtocol{}
extension Date: WPSpaceProtocol{}
extension Array : WPSpaceProtocol{}
extension CGRect : WPSpaceProtocol{}
extension CGPoint : WPSpaceProtocol{}
extension CGSize : WPSpaceProtocol{}




 



