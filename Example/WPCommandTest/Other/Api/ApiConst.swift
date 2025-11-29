//
//  ApiConst.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

public typealias ApiModel = Codable & WPSpaceProtocol

/// 业务接口类型
public enum BusinessType:Int,Codable{
    /// 业务成功
    case success = 200
}

/// 默认空模型
public struct ApiEmpty: ApiModel {}

public struct ApiResualt<T: ApiModel>: ApiModel{
    
    /// 业务接口
    public var code: BusinessType?
    /// 数据类型
    public var data:T?
    /// 描述
    public var message: String?
}


public extension Dictionary {
    /// 安全设置字典的值，可链式调用
    /// - Parameters:
    ///   - value: 要设置的值（可选，如果是 nil 则移除 key）
    ///   - key: 字典 key
    @discardableResult
    func setSafe(_ value: Value?, forKey key: Key) -> Self {
        var new = self
        if let value = value {
            new[key] = value
        } else {
            new.removeValue(forKey: key)
        }
        return new
    }
}
