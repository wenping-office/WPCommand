//
//  WPSpace.swift
//  WPCommand
//
//  Created by WenPing on 2021/11/1.
//

import UIKit
import RxSwift

public struct WPSpace<Base> {

    public var base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

public protocol WPSpaceProtocol {
    
    associatedtype Base

    var wp: Base { get set }
    
    static var wp: Base.Type { get set }
}

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




 



