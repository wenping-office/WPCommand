//
//  PropertyWrapper+Ex.swift
//  Alamofire
//
//  Created by kuaiyin on 2025/12/19.
//

import RxSwift
import RxCocoa
import Combine

public enum UserDefaultsSuite {
    case standard
    case appGroup(String)
    public var userDefaults: UserDefaults {
        switch self {
        case .standard:
            return .standard
        case .appGroup(let identifier):
            guard let ud = UserDefaults(suiteName: identifier) else {
                assertionFailure("Invalid App Group: \(identifier)")
                return .standard
            }
            return ud
        }
    }
}

/// RxBehaviorRelay 策略
@propertyWrapper
public struct WPRxBehavior<Value> {
    private let relay:BehaviorRelay<Value>
    public var wrappedValue: Value{
        get{
            relay.value
        }
        set{
            relay.accept(newValue)
        }
    }
    public init(wrappedValue: Value) {
        self.relay = .init(value: wrappedValue)
    }
    public var projectedValue:Driver<Value>{
        return relay.asDriver()
    }
}

@available(iOS 13.0, *)
/// CombineCurrentValueSubject 策略
@propertyWrapper
public struct WPBehavior<Value> {
    private let relay:CurrentValueSubject<Value,Never>
    public var wrappedValue: Value{
        get{
            relay.value
        }
        set{
            relay.send(newValue)
        }
    }
    public init(wrappedValue: Value) {
        self.relay = .init(wrappedValue)
    }
    public var projectedValue:AnyPublisher<Value,Never>{
        return relay.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
}

/// UserDefault 缓存策略
@propertyWrapper
public struct WPRxPreference<Value: Codable & WPSpaceProtocol> {
    private let relay: BehaviorRelay<Value>
    private let key: String
    private let storage: UserDefaults

    public var wrappedValue: Value {
        get {
            relay.value
        }
        set {
            relay.accept(newValue)
            guard let data = newValue.wp.toData() else {
                storage.removeObject(forKey: key)
                return
            }
            storage.set(data, forKey: key)
        }
    }

    public init(
        wrappedValue: Value,
        key: String,
        suite: UserDefaultsSuite = .standard
    ) {
        self.key = key
        self.storage = suite.userDefaults

        if let data = storage.data(forKey: key),
           let value = try? Value.wp.map(jsonData: data) {
            self.relay = BehaviorRelay(value: value)
        } else {
            self.relay = BehaviorRelay(value: wrappedValue)
            if let data = wrappedValue.wp.toData() {
                storage.set(data, forKey: key)
            }
        }
    }

    public var projectedValue: Driver<Value> {
        relay.asDriver()
    }
}


@available(iOS 13.0, *)
/// UserDefault 缓存策略
@propertyWrapper
public struct WPPreference<Value: Codable & WPSpaceProtocol> {
    private let relay: CurrentValueSubject<Value, Never>
    private let key: String
    private let storage: UserDefaults

   public var wrappedValue: Value {
        get {
            relay.value
        }
        set {
            relay.send(newValue)
            guard let data = newValue.wp.toData() else {
                storage.removeObject(forKey: key)
                return
            }
            storage.set(data, forKey: key)
        }
    }

   public init(
        wrappedValue: Value,
        key: String,
        suite: UserDefaultsSuite = .standard
    ) {
        self.key = key
        self.storage = suite.userDefaults

        if let data = storage.data(forKey: key),
           let value = try? Value.wp.map(jsonData: data) {
            self.relay = CurrentValueSubject<Value, Never>(value)
        } else {
            self.relay = CurrentValueSubject<Value, Never>(wrappedValue)
            if let data = wrappedValue.wp.toData() {
                storage.set(data, forKey: key)
            }
        }
    }

   public var projectedValue: AnyPublisher<Value, Never> {
        relay
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}



public enum KeychainSuite {
    case standard(service: String)
    case accessGroup(service: String, group: String)

    var queryBase: [String: Any] {
        var q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        if case let .accessGroup(_, group) = self {
            q[kSecAttrAccessGroup as String] = group
        }
        return q
    }

    private var service: String {
        switch self {
        case .standard(let service),
             .accessGroup(let service, _):
            return service
        }
    }
}


enum KeychainClient {

    static func read(key: String, suite: KeychainSuite) -> Data? {
        var query = suite.queryBase
        query[kSecAttrAccount as String] = key
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess ? result as? Data : nil
    }

    static func write(_ data: Data, key: String, suite: KeychainSuite) {
        var query = suite.queryBase
        query[kSecAttrAccount as String] = key

        let attrs = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attrs as CFDictionary)

        if status == errSecItemNotFound {
            query.merge(attrs) { $1 }
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    static func delete(key: String, suite: KeychainSuite) {
        var query = suite.queryBase
        query[kSecAttrAccount as String] = key
        SecItemDelete(query as CFDictionary)
    }
}


/// Keychain 缓存策略
@propertyWrapper
public struct WPRxSecurePreference<Value: Codable & WPSpaceProtocol> {
    private let relay: BehaviorRelay<Value?>
    private let key: String
    private let suite: KeychainSuite
    public var wrappedValue: Value? {
        get { relay.value }
        set {
            relay.accept(newValue)
            guard let value = newValue,
                  let data = value.wp.toData() else {
                KeychainClient.delete(key: key, suite: suite)
                return
            }
            KeychainClient.write(data, key: key, suite: suite)
        }
    }

    public init(
        wrappedValue: Value? = nil,
        key: String,
        suite: KeychainSuite
    ) {
        self.key = key
        self.suite = suite

        if let data = KeychainClient.read(key: key, suite: suite),
           let value = try? Value.wp.map(jsonData: data) {
            self.relay = BehaviorRelay(value: value)
        } else {
            self.relay = BehaviorRelay(value: wrappedValue)
        }
    }

    public var projectedValue: Driver<Value?> {
        relay.asDriver()
    }
}

/// Keychain 缓存策略
@available(iOS 13.0, *)
@propertyWrapper
public struct WPSecurePreference<Value: Codable> {

    private let relay: CurrentValueSubject<Value?, Never>
    private let key: String
    private let suite: KeychainSuite

    public var wrappedValue: Value? {
        get { relay.value }
        set {
            relay.send(newValue)
            guard let value = newValue,
                  let data = try? JSONEncoder().encode(value) else {
                KeychainClient.delete(key: key, suite: suite)
                return
            }
            KeychainClient.write(data, key: key, suite: suite)
        }
    }

    public init(
        wrappedValue: Value? = nil,
        key: String,
        suite: KeychainSuite
    ) {
        self.key = key
        self.suite = suite

        if let data = KeychainClient.read(key: key, suite: suite),
           let value = try? JSONDecoder().decode(Value.self, from: data) {
            self.relay = CurrentValueSubject(value)
        } else {
            self.relay = CurrentValueSubject(wrappedValue)
        }
    }

    public var projectedValue: AnyPublisher<Value?, Never> {
        relay.eraseToAnyPublisher()
    }
}


