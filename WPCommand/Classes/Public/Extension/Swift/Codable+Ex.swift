//
//  Codable+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/28.
//

import UIKit


public extension Encodable {
    
    /// 转换成data
    var wp_data:Data?{
        return try? JSONEncoder().encode(self)
    }
    
    /// 转换成string
    var wp_jsonStr :String? {
        if let bytes = wp_data {
            return String(bytes: bytes, encoding: .utf8)
        }
        return nil
    }
    
    /// 转换成json
    var wp_json : [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] } ?? [:]
    }
}

public extension Decodable {
    
    /// jsonAata解码成对象
    /// - Parameter data: jsonData
    /// - Returns: 结果
    static func wp_map(_ data: Data) -> Self? {
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch let error {
            print(error)
            return nil
        }
    }
    /// jsonStr解码成对象
    /// - Parameter jsonStr: jsonStr
    /// - Returns: 结果
    static func wp_map(_ jsonStr: String) -> Self? {
        do {
            return try JSONDecoder().decode(Self.self, from: Data(jsonStr.utf8))
        } catch let error {
            print(error)
            return nil
        }
    }
    
    /// json解码成对象
    /// - Parameter json: json
    /// - Returns: 结果
    static func wp_map(_ json: Any) -> Self? {
        guard JSONSerialization.isValidJSONObject(json) else {
            print("传入的不是一个json对象")
            return nil
        }
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            do {
                return try JSONDecoder().decode(Self.self, from: data)
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
        }
        return nil
    }
}
