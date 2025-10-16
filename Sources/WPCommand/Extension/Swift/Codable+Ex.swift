//
//  Codable+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/28.
//

import UIKit

public extension WPSpace where Base : Encodable {
    /// 转换成data
    func toData() -> Data? {
        return try? JSONEncoder().encode(base)
    }

    /// 转换成string
    func toJSONString(pretty: Bool = false) -> String? {
        let encoder = JSONEncoder()
        if pretty {
            if #available(iOS 13.0, *) {
                encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            } else {
                // Fallback on earlier versions
            }
        }
        guard let data = toData() else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// 转换成json
    func toJson()-> [String: Any] {
        guard let data = try? JSONEncoder().encode( base) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] } ?? [:]
    }
}

public extension WPSpace where Base : Decodable {
    /// jsonData解码成对象
    /// - Parameter data: jsonData
    /// - Returns: 结果
    static func map(jsonData: Data) throws -> Base {
        do {
            return try JSONDecoder().decode(Base.self, from: jsonData)
        }catch let decodingError as DecodingError {
            printDecodingError(decodingError)
            throw decodingError
        } catch {
            throw error
        }
    }

    /// jsonStr解码成对象
    /// - Parameter jsonString: jsonStr
    /// - Returns: 结果
    static func map(jsonString: String) throws -> Base {
        do {
            return try JSONDecoder().decode(Base.self, from: Data(jsonString.utf8))
        }catch let decodingError as DecodingError {
            printDecodingError(decodingError)
            throw decodingError
        } catch {
            throw error
        }
    }

    /// json解码成对象
    /// - Parameter json: json
    /// - Returns: 结果
    static func map(json: Any) throws -> Base {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            return try JSONDecoder().decode(Base.self, from: data)
        } catch let decodingError as DecodingError {
            printDecodingError(decodingError)
            throw decodingError
        } catch {
            throw error
        }
    }
    
    private static func printDecodingError(_ error: DecodingError) {
        switch error {
        case .typeMismatch(let type, let context):
            WPDLog("类型不匹配: \(type) 在路径: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            WPDLog("Debug Description: \(context.debugDescription)")
            WPDLog("Underlying Error: \(String(describing: context.underlyingError))")
        case .valueNotFound(let type, let context):
            WPDLog("缺失值: \(type) 在路径: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            WPDLog("Debug Description: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            WPDLog("缺失 key: \(key.stringValue) 在路径: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            WPDLog("Debug Description: \(context.debugDescription)")
        case .dataCorrupted(let context):
            WPDLog("数据损坏: \(context.debugDescription)")
        @unknown default:
            print("未知错误: \(error.localizedDescription)")
        }
    }
}
