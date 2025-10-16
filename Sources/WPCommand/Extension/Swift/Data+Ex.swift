//
//  Data+Ex.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/10/16.
//

import UIKit

extension Data: WPSpaceProtocol{}

public extension WPSpace where Base == Data {
    
    /// 转换成json
    func toJson(options opt: JSONSerialization.ReadingOptions = []) throws ->  [String: Any]? {
        return (try JSONSerialization.jsonObject(with: base) as? [String:Any]?)!
    }
}
