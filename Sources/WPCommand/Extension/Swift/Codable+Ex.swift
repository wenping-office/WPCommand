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
        if let data = base as? Data {
            return data
        }
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

extension KeyedDecodingContainer: WPSpaceProtocol {}

fileprivate func wp_convert<T>(_ value: Any) -> T? {
    switch T.self {
    case is String.Type:
        if let v = value as? String { return v as? T }
        if let v = value as? Int { return String(v) as? T }
        if let v = value as? Double { return String(v) as? T }
        if let v = value as? Bool { return String(v) as? T }
        return nil
    case is Int.Type:
        if let v = value as? Int { return v as? T }
        if let v = value as? Double { return Int(v) as? T }
        if let v = value as? String { return Int(v) as? T }
        if let v = value as? Bool { return (v ? 1 : 0) as? T }
        return nil
    case is Double.Type:
        if let v = value as? Double { return v as? T }
        if let v = value as? Int { return Double(v) as? T }
        if let v = value as? String { return Double(v) as? T }
        if let v = value as? Bool { return (v ? 1.0 : 0.0) as? T }
        return nil
    case is Bool.Type:
        if let v = value as? Bool { return v as? T }
        if let v = value as? Int { return (v == 1) as? T }
        if let v = value as? Double { return (v == 1) as? T }
        if let v = value as? String {
            return ["true","yes","1"].contains(v.lowercased()) as? T
        }
        return nil
    default:
        return nil
    }
}

public extension WPSpace where Base: KeyedDecodingContainerProtocol {

    /// 解析单值支持String<->Int<->Double<->Bool 互转
    func decode<T:Decodable, K: CodingKey>(forKey key: K) -> T? where Base == KeyedDecodingContainer<K> {
        if let str = try? base.decodeIfPresent(String.self, forKey: key), let converted: T = wp_convert(str) { return converted }
        if let intVal = try? base.decodeIfPresent(Int.self, forKey: key), let converted: T = wp_convert(intVal) { return converted }
        if let doubleVal = try? base.decodeIfPresent(Double.self, forKey: key), let converted: T = wp_convert(doubleVal) { return converted }
        if let boolVal = try? base.decodeIfPresent(Bool.self, forKey: key), let converted: T = wp_convert(boolVal) { return converted }
        if let obj = try? base.decodeIfPresent(T.self, forKey: key) {
            return obj
        }
        return nil
    }

    /// 解析数组
    func decodeArray<T:Codable, K: CodingKey>(forKey key: K) -> [T]? where Base == KeyedDecodingContainer<K> {
        if let arr = try? base.decodeIfPresent([String].self, forKey: key) { return arr.compactMap { wp_convert($0) } }
        if let arr = try? base.decodeIfPresent([Int].self, forKey: key) { return arr.compactMap { wp_convert($0) } }
        if let arr = try? base.decodeIfPresent([Double].self, forKey: key) { return arr.compactMap { wp_convert($0) } }
        if let arr = try? base.decodeIfPresent([Bool].self, forKey: key) { return arr.compactMap { wp_convert($0) } }
        if let objArr = try? base.decodeIfPresent([T].self, forKey: key) {
            return objArr
        }
        return nil
    }
    
    /// 解析枚举
    func decodeEnum<T, K: CodingKey>(forKey key: K) -> T?
        where Base == KeyedDecodingContainer<K>, T: RawRepresentable, T.RawValue: Decodable {
        if let raw: T.RawValue = decode(forKey: key) {
            return T(rawValue: raw)
        }
        return nil
    }
    
    /// 解析枚举数组
    func decodeEnumArray<T, K: CodingKey>(forKey key: K) -> [T]?
        where Base == KeyedDecodingContainer<K>, T: RawRepresentable, T.RawValue: Decodable {
        if let rawArray: [T.RawValue] = decode(forKey: key) {
            let enums = rawArray.compactMap { T(rawValue: $0) }
            return enums.isEmpty ? nil : enums
        }
        if let raw: T.RawValue = decode(forKey: key), let enumValue = T(rawValue: raw) {
            return [enumValue]
        }
        return nil
    }
}



/// 解析单值支持String<->Int<->Double<->Bool 互转
@propertyWrapper
public struct WPDecode<T: Codable>: Codable {
    public var wrappedValue: T?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(T.self) { self.wrappedValue = value; return }
        if let str = try? container.decode(String.self), let v: T = wp_convert(str) { self.wrappedValue = v; return }
        if let intVal = try? container.decode(Int.self), let v: T = wp_convert(intVal) { self.wrappedValue = v; return }
        if let doubleVal = try? container.decode(Double.self), let v: T = wp_convert(doubleVal) { self.wrappedValue = v; return }
        if let boolVal = try? container.decode(Bool.self), let v: T = wp_convert(boolVal) { self.wrappedValue = v; return }

        self.wrappedValue = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

/// 解析单值支持String<->Int<->Double<->Bool 互转
@propertyWrapper
public struct WPDecodeArray<T: Codable>: Codable {
    public var wrappedValue: [T]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let arr = try? container.decode([T].self) { self.wrappedValue = arr; return }
        if let arr = try? container.decode([String].self) { self.wrappedValue = arr.compactMap { wp_convert($0) }; return }
        if let arr = try? container.decode([Int].self) { self.wrappedValue = arr.compactMap { wp_convert($0) }; return }
        if let arr = try? container.decode([Double].self) { self.wrappedValue = arr.compactMap { wp_convert($0) }; return }
        if let arr = try? container.decode([Bool].self) { self.wrappedValue = arr.compactMap { wp_convert($0) }; return }

        self.wrappedValue = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

/// 解析单值支持String<->Int<->Double<->Bool 互转
@propertyWrapper
public struct WPDecodeEnum<T:Codable>: Codable where T: RawRepresentable, T.RawValue: Codable {

    public var wrappedValue: T?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(T.self) {
            wrappedValue = value
            return
        }

        if let any = try? container.decode(AnyDecodable.self),
           let raw = wp_convert(any.value) as T.RawValue?,
           let value = T(rawValue: raw) {
            wrappedValue = value
            return
        }

        wrappedValue = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue?.rawValue)
    }
}

/// 解析单值支持String<->Int<->Double<->Bool 互转
@propertyWrapper
public struct WPDecodeEnumArray<T>: Codable where T: RawRepresentable, T.RawValue: Encodable {
    public var wrappedValue: [T]?
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let array = try? container.decode([AnyDecodable].self) {
            let values = array
                .compactMap { wp_convert($0.value) as T.RawValue? }
                .compactMap { T(rawValue: $0) }

            self.wrappedValue = values.isEmpty ? nil : values
            return
        }
        if let single = try? container.decode(AnyDecodable.self),
           let raw = wp_convert(single.value) as T.RawValue?,
           let value = T(rawValue: raw) {
            self.wrappedValue = [value]
            return
        }
        self.wrappedValue = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue?.map { $0.rawValue })
    }
}

public struct AnyDecodable: Codable {
    public let value: Any
    public init(_ value: Any) {
        self.value = value
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let v = try? container.decode(Int.self) {
            value = v
            return
        }

        if let v = try? container.decode(Double.self) {
            value = v
            return
        }

        if let v = try? container.decode(Bool.self) {
            value = v
            return
        }

        if let v = try? container.decode(String.self) {
            value = v
            return
        }

        if let v = try? container.decode([AnyDecodable].self) {
            value = v.map { $0.value }
            return
        }

        if let v = try? container.decode([String: AnyDecodable].self) {
            value = v.mapValues { $0.value }
            return
        }

        if container.decodeNil() {
            value = NSNull()
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "AnyDecodable value cannot be decoded"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {

        case let v as Int:
            try container.encode(v)

        case let v as Double:
            try container.encode(v)

        case let v as Bool:
            try container.encode(v)

        case let v as String:
            try container.encode(v)

        case let v as [Any]:
            try container.encode(v.map { AnyDecodable($0) })

        case let v as [String: Any]:
            try container.encode(v.mapValues { AnyDecodable($0) })

        case is NSNull:
            try container.encodeNil()

        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "AnyDecodable value cannot be encoded"
                )
            )
        }
    }
}
