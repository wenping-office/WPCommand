//
//  WPSystem.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CoreMotion
import Photos
//import RxCocoa
//import RxSwift
import UIKit
import Combine

open class WPSystem: NSObject {
    /// 键盘相关
    public static let keyboard: WPSystem.KeyBoard = .init()
    
    /// app相关
    public static let application: WPSystem.Appliaction = .init()
    
    /// 屏幕相关
    public static let screen: WPSystem.Screen = .init()
}

public extension WPSystem {
    /// 键盘
    struct KeyBoard {
        /// 获取目标视图与键盘顶部的Y轴差值 0 键盘收回 正数代表没有被键盘覆盖的差值 负数代表被键盘覆盖的差值
        /// - Parameters:
        ///   - veiw: 目标视图
        /// - Returns: 观察者
        public func offsetY(in view:UIView) -> AnyPublisher<Double,Never>{
            return NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification).merge(with: NotificationCenter.default.publisher(for: UIApplication.keyboardDidChangeFrameNotification)).map { notification in
                guard let userInfo = notification.userInfo,
                      let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return 0.0
                }
                return frameValue.cgRectValue.minY
            }.merge(with: NotificationCenter.default.publisher(for: UIApplication.keyboardDidHideNotification).map({ _ in return 0.0})).scan((CGRect.zero,CGFloat(0)), { value, keyboardHeight in
                var newValue = value
                if newValue.0.size == .zero{
                    let frame = view.convert(view.bounds, to: UIApplication.wp.keyWindow!)
                    newValue.0 = frame
                }
                newValue.1 = keyboardHeight
                return newValue
            }).map({ value in
                if value.1 <= 0{
                    return 0
                }else{
                    return -(value.0.maxY - value.1)
                }
            }).removeDuplicates().eraseToAnyPublisher()
        }
        
        /// 键盘高度
        public func height()->AnyPublisher<Double,Never>{
            return NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification).merge(with: NotificationCenter.default.publisher(for: UIApplication.keyboardDidChangeFrameNotification)).map { notification in
                guard let userInfo = notification.userInfo,
                      let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return 0.0
                }
                return frameValue.cgRectValue.minY
            }.merge(with: NotificationCenter.default.publisher(for: UIApplication.keyboardDidHideNotification).map({ _ in return 0.0})).eraseToAnyPublisher()
        }
    }
    
    /// app相关
    struct Appliaction {
        /// 将要进入前台
        public var willEnterForeground: NotificationCenter.Publisher {
            return NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
        }
        
        /// 已经激活app
        public var didBecomeActive: NotificationCenter.Publisher {
            return NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
        }
        
        /// 将要挂起
        public var willResignActive: NotificationCenter.Publisher {
            return NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
        }
        
        /// 已经进入后台
        public var didEnterBackground: NotificationCenter.Publisher {
            return NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
        }
        
        /// 将被杀死
        public var willTerminate: NotificationCenter.Publisher{
            return NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
        }
    }
    
    /// 屏幕相关
    struct Screen {
        /// 系统相关
        public var system = System()
        /// 导航栏高度
        public var navigationHeight : CGFloat{
            return UIApplication.shared.statusBarFrame.size.height + UINavigationController().navigationBar.frame.size.height
        }
        /// 安全内边距
        public var safeArea : UIEdgeInsets{
            if #available(iOS 11.0, *) {
                if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                    return window.safeAreaInsets
                }
                
                if let window = UIApplication.shared.windows.first {
                    return window.safeAreaInsets
                }
                if let window = UIApplication.shared.delegate?.window as? UIWindow {
                    return window.safeAreaInsets
                }
                
                return .zero
            } else {
                return .zero
            }
        }
        
        /// 屏幕大小
        public var size : CGSize{
            return UIScreen.main.bounds.size
        }
        
        /// 屏幕宽
        public var maxWidth:CGFloat{
            return size.width
        }
        
        /// 屏幕高
        public var maxHeight:CGFloat{
            return size.height
        }
        
        /// 是否是刘海屏
        public var isFull : Bool{
            if #available(iOS 11, *) {
                if safeArea.left > 0 || safeArea.bottom > 0 {
                    return true
                }
            }
            return false
        }
        
        /// 判断是否是16:9屏
        /// - Returns: true 是 false不是
        public var is16x9: Bool {
            let maxWidth = size.width
            let Sheight = size.height
            let maxHeight = maxWidth / 9 * 16
            let range = Sheight - maxHeight
            return range <= 2
        }
        
        /// 是否是横屏幕 根据系统手机方向判断
        public var isHorizontal: Bool {
            switch UIDevice.current.orientation {
            case .faceDown, .faceUp, .portrait, .portraitUpsideDown, .unknown:
                return false
            default:
                return true
            }
        }
        
        /// 比例
        public enum Proportion {
            /// 4:3屏幕
            case p4x3
            /// 16x9屏幕
            case p16x9
            
            /// 获取一个比例高度
            /// - Returns: 比例高度
            public var height: CGFloat {
                let maxHeight = WPSystem.screen.size.height
                let maxWidth = WPSystem.screen.size.width
                switch self {
                case .p16x9:
                    if WPSystem.screen.is16x9 {
                        return maxHeight
                    } else {
                        return maxWidth / 9 * 16
                    }
                case .p4x3:
                    return maxWidth / 3 * 4
                }
            }
        }
        
        /// 系统屏幕相关
        public struct System {
            /// 屏幕方向
            public var orientation: AnyPublisher<UIDeviceOrientation,Never> {
                return NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification).map { _ in
                    return UIDevice.current.orientation
                }.eraseToAnyPublisher()
            }
        }
    }
}

public extension WPSystem{
    
    /// 从指定 Localizable.xcstrings 文件获取指定语种的 key-value
    /// - Parameters:
    ///   - filePath: Localizable.xcstrings 文件完整路径 模拟器下才能使用
    ///   - languageKey: 指定语种 key，默认 "en"
    /// - Returns: 字典 [key: value]
    static func getLocalizableKeys(from filePath: String, languageKey: String = "en") -> [String: String] {
        var result: [String: String] = [:]
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: filePath) else {
            print("❌ 文件不存在: \(filePath)")
            return result
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let strings = json["strings"] as? [String: Any] else {
                print("❌ 文件结构不合法")
                return result
            }
            
            for (key, value) in strings {
                guard let dict = value as? [String: Any],
                      let localizations = dict["localizations"] as? [String: Any],
                      let langDict = localizations[languageKey] as? [String: Any],
                      let stringUnit = langDict["stringUnit"] as? [String: Any],
                      let stringValue = stringUnit["value"] as? String else {
                    continue
                }
                result[key] = stringValue
            }
            
            print("✅ 已解析文件: \(filePath)")
            print("   共 \(result.count) 个 key")
            
        } catch {
            print("❌ 解析失败: \(error)")
        }
        
        return result
    }

    /// 将翻译合并到 Localizable.xcstrings 文件（支持新增和替换）
    /// - Parameters:
    ///   - translations: 翻译字典 [key: value]
    ///   - language: 语言代码，如 "ar", "zh-Hant", "es" 等
    ///   - filePath: Localizable.xcstrings 文件的路径
    ///   - overwrite: 是否覆盖已存在的翻译，true=覆盖，false=只添加不存在的
   static func mergeTranslations(_ translations: [String: String],
                           forLanguage language: String,
                           to filePath: String,
                           overwrite: Bool = true) throws {
        
        let url = URL(fileURLWithPath: filePath)
        
        // 1. 读取现有文件
        let data = try Data(contentsOf: url)
        var json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        // 2. 获取或创建 strings 字典
        var strings = json["strings"] as? [String: Any] ?? [:]
        
        var addedCount = 0
        var replacedCount = 0
        var skippedCount = 0
        
        // 3. 遍历翻译，更新或创建条目
        for (key, value) in translations {
            // 获取或创建 key 的条目
            var keyEntry = strings[key] as? [String: Any] ?? [:]
            var localizations = keyEntry["localizations"] as? [String: Any] ?? [:]
            
            // 检查该语言是否已存在
            let existingTranslation = localizations[language] != nil
            
            if existingTranslation && !overwrite {
                // 已存在且不允许覆盖，跳过
                skippedCount += 1
                continue
            }
            
            // 获取或创建 extractionState（默认为 manual）
            if keyEntry["extractionState"] == nil {
                keyEntry["extractionState"] = "manual"
            }
            
            // 创建该语言的翻译
            let translationEntry: [String: Any] = [
                "stringUnit": [
                    "state": "translated",
                    "value": value
                ]
            ]
            
            // 添加到 localizations
            localizations[language] = translationEntry
            
            // 更新 keyEntry
            keyEntry["localizations"] = localizations
            strings[key] = keyEntry
            
            if existingTranslation {
                replacedCount += 1
            } else {
                addedCount += 1
            }
        }
        
        // 4. 更新 json
        json["strings"] = strings
        json["sourceLanguage"] = json["sourceLanguage"] ?? "en"
        json["version"] = json["version"] ?? "1.0"
        
        // 5. 写入文件
        let outputData = try JSONSerialization.data(withJSONObject: json,
                                                     options: [.prettyPrinted, .withoutEscapingSlashes])
        try outputData.write(to: url)
        
        print("✅ 合并完成！")
        print("   📝 新增: \(addedCount) 条")
        print("   🔄 替换: \(replacedCount) 条")
        print("   ⏭️ 跳过: \(skippedCount) 条")
        print("   🌐 目标语言: \(language)")
    }

    /// 从 JSON 文件读取翻译并合并
    /// - Parameters:
    ///   - jsonFilePath: 翻译 JSON 文件路径
    ///   - language: 目标语言代码
    ///   - xcstringsPath: Localizable.xcstrings 文件路径
    ///   - overwrite: 是否覆盖已存在的翻译
   static func mergeTranslationsFromJSONFile(_ jsonFilePath: String,
                                       forLanguage language: String,
                                       to xcstringsPath: String,
                                       overwrite: Bool = true) throws {
        
        let url = URL(fileURLWithPath: jsonFilePath)
        let data = try Data(contentsOf: url)
        let translations = try JSONSerialization.jsonObject(with: data) as? [String: String] ?? [:]
        
        try mergeTranslations(translations, forLanguage: language, to: xcstringsPath, overwrite: overwrite)
    }
    
    
    /// 获取一个 Localizable.xcstrings 所在目录下的所有语言 key 模拟器使用
   static func getAllLanguageKeys(path: String) -> [String] {
        let fileManager = FileManager.default
        // 获取 Localizable.xcstrings 的目录
        let dir = (path as NSString).deletingLastPathComponent
        
        do {
            // 遍历目录下所有文件夹
            let items = try fileManager.contentsOfDirectory(atPath: dir)
            var languages = [String]()
            
            for item in items {
                // 只处理 .lproj 文件夹
                if item.hasSuffix(".lproj") {
                    let langKey = (item as NSString).deletingPathExtension
                    languages.append(langKey)
                }
            }
            
            return languages.sorted()
        } catch {
            print("读取目录失败: \(error)")
            return []
        }
    }
    
    /// 从 Localizable JSON 文件中获取所有语种 key 模拟器使用
    /// - Parameter filePath: JSON 文件路径
    /// - Returns: 语种 key 数组
    static func getAllLanguageKeys(filePath: String) -> [String] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath) else {
            print("❌ 文件不存在: \(filePath)")
            return []
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let stringsDict = jsonObject["strings"] as? [String: Any] else {
                print("❌ JSON 结构不合法")
                return []
            }
            
            var languageSet = Set<String>()
            
            // 遍历每个 strings key
            for (_, stringEntry) in stringsDict {
                if let entryDict = stringEntry as? [String: Any],
                   let localizations = entryDict["localizations"] as? [String: Any] {
                    // 将 localizations key 添加到集合
                    for langKey in localizations.keys {
                        languageSet.insert(langKey)
                    }
                }
            }
            
            // 返回排序后的数组
            return Array(languageSet).sorted()
            
        } catch {
            print("❌ 解析 JSON 失败: \(error)")
            return []
        }
    }
    
    /// 删除指定语种的内容 模拟器使用
    /// - Parameters:
    ///   - filePath: JSON 文件路径
    ///   - languageKey: 要删除的语种，例如 "zh-Hans"
    static func deleteLanguage(filePath: String, languageKey: String) {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath) else {
            print("❌ 文件不存在: \(filePath)")
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            guard var jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  var stringsDict = jsonObject["strings"] as? [String: Any] else {
                print("❌ JSON 结构不合法")
                return
            }
            
            var modified = false
            
            // 遍历每个 strings key
            for (stringKey, stringEntry) in stringsDict {
                if var entryDict = stringEntry as? [String: Any],
                   var localizations = entryDict["localizations"] as? [String: Any] {
                    if localizations.removeValue(forKey: languageKey) != nil {
                        entryDict["localizations"] = localizations
                        stringsDict[stringKey] = entryDict
                        modified = true
                        print("✅ 已删除 \(languageKey) 在 key '\(stringKey)' 下的翻译")
                    }
                }
            }
            
            if modified {
                jsonObject["strings"] = stringsDict
                // 写回文件
                let newData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
                try newData.write(to: URL(fileURLWithPath: filePath))
                print("✅ 已更新文件: \(filePath)")
            } else {
                print("⚠️ 没有找到语种 \(languageKey)")
            }
            
        } catch {
            print("❌ 操作失败: \(error)")
        }
    }
    
    /// 翻译国际化文件 需要翻译的语言会打印在控制台 必须用模拟器运行 真机照不到path下的文件
    /// filePath Localizable.xcstrings 文件路径
    /// optionKeys 需要翻译的key 如有有重复的key 会覆盖
   static func translation(filePath:String,
               targetLanguageKey:String,
               optionKeys:(_ launchKey:String) -> [String:String]) {
        func formatDict(_ dict: [String: String]) -> String {
            var result = "[\n"
            let keys = dict.keys.sorted()
            for (index, key) in keys.enumerated() {
                var value = dict[key] ?? ""
                // 把真实换行替换成 \n
                value = value
                    .replacingOccurrences(of: "\n", with: "\\n")
                    .replacingOccurrences(of: "\r", with: "")
                
                result += "\"\(key)\":\"\(value)\""
                
                if index != keys.count - 1 {
                    result += ","
                }
                result += "\n"
            }
            result += "]"
            return result
        }
        
        func printSwitchTemplate(keys: [String]) {
            let sortedKeys = keys.sorted()
            print("switch key {")
            for key in sortedKeys {
                if key != targetLanguageKey {
                    print("""
                    case "\(key)":
                        return [:]
                    """)
                }
            }
            print("""
                default:
                    return [:]
                }
                """)
        }
        
        let keys = WPSystem.getAllLanguageKeys(filePath:filePath)
        let targetValues = WPSystem.getLocalizableKeys(from: filePath, languageKey: targetLanguageKey)
        print("所支持的keys\(keys)\n\n\n")
        print("需要翻译的语言\n\n\(printSwitchTemplate(keys: keys))")
        print("目标kyes\n\n\n\(formatDict(targetValues))\n\n\n")
        
        
        keys.forEach { key in
            if key != targetLanguageKey {
                let values = optionKeys(key)
                try? WPSystem.mergeTranslations(values, forLanguage: key, to: filePath, overwrite: true)
            }
        }
    }
}

