//
//  JSONSerialization+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension JSONSerialization {
    /// json 转 模型
    /// - Parameters:
    ///   - json: 字典
    ///   - type: 模型类型
    /// - Returns: 模型
    static func wp_model<T: Codable>(by json: [String: Any], type: T.Type)->T? {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let decorder = JSONDecoder()
        decorder.dateDecodingStrategy = .millisecondsSince1970

        guard let newJsonData = jsonData else {
            return nil
        }

        return try? decorder.decode(T.self, from: newJsonData)
    }

    /// 字典数组 转 模型数组
    /// - Parameters:
    ///   - jsonArray: 字典数组
    ///   - type: 模型类型
    /// - Returns: 模型数组
    static func wp_modelList<T: Codable>(by jsonArray: [[String: Any]], type: T.Type)->[T]? {
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: .fragmentsAllowed)
        let decorder = JSONDecoder()
        decorder.dateDecodingStrategy = .millisecondsSince1970

        guard let newJsonData = jsonData else {
            return nil
        }

        return try? decorder.decode([T].self, from: newJsonData)
    }
}
