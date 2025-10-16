//
//  KeyedDecodingContainer+Ex.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/10/15.
//

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


