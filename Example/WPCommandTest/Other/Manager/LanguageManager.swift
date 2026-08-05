//
//  LanguageManager.swift
//  WPCommand_Example
//
//  Created by 1234 on 2024/12/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//
import UIKit
import WPCommand

fileprivate var langManager = LanguageManager()

public extension String{
    /// 加载国际化对应key字符串
    /// - Returns: 结果
   func loadLanguageStr()->Self {
       guard let path = Bundle.main.path(forResource: code, ofType: "lproj") else {
           return Bundle.main.localizedString(forKey: self, value: "", table: nil)
       }
       let bundle = Foundation.Bundle(path: path)
       return bundle?.localizedString(forKey: self, value: "", table: nil) ?? self
    }
    
    /// 带注释的本地化替换
    func local(comment: String = "", _ arguments: CVarArg...) -> String {
        return String(format: loadLanguageStr(), arguments: arguments)
    }
}

public class LanguageCenter:NSObject {
    
    /// 当前语言
   public static var current:Lang{
        if let code = UserDefaults.standard.value(forKey: "localLang") as? String{
            if let lange = Lang.init(rawValue: code){
                return lange
            }
        }else{
            let code = Locale.preferredLanguages.first ?? "en"
            if let lange = Lang.init(rawValue: code){
                return lange
            }
        }
        return .en
    }
    
    /// 切换语言

   public static func switchLange(_ lang:Lang){
        UserDefaults.standard.set(lang.rawValue, forKey: "localLang")
        NotificationCenter.default.post(name: .UpdateLanguage, object: nil)
    }
}

public extension Notification.Name{
    ///语言环境更新通知
    static var UpdateLanguage = Notification.Name.init("APPUpdateLanguage")
}


class LanguageManager:NSObject {
    
    /// 当前语言
    static var current:Lang{
        if let code = UserDefaults.standard.value(forKey: "localLang") as? String{
            if let lange = Lang.init(localFileString: code){
                return lange
            }
        }else{
            let code = Locale.current.languageCode ?? "en"
            if let lange = Lang.init(localFileString: code){
                return lange
            }
        }
        return .en_US
    }
    
    /// 切换语言
    static func switchLange(_ lang:Lang){
        UserDefaults.standard.set(lang.localFileString, forKey: "localLang")
        NotificationCenter.default.post(name: .UpdateLanguage, object: nil)
    }
}

public extension LanguageCenter {
    enum Lang: String, CaseIterable {

        case en          // English
        case ja          // Japanese
        case fr          // French
        case de          // German
        case ar          // Arabic
        case fil         // Filipino
        case hi          // Hindi
        case id          // Indonesian
        case ms          // Malay
        case es          // Spanish
        case pt       // Portuguese
        case zh_Hans     // Simplified Chinese
        case zh_Hant     // Traditional Chinese
        case ko          // Korean
        case bn          // Bengali
        case ur          // Urdu
        case sw          // Swahili
        case ha          // Hausa
        case th          // Thai
        case vi          // Vietnamese
        case ta          // Tamil


        // MARK: - 本地化文件名 (.lproj)

        public func localFileString() -> String {
            return rawValue.replacingOccurrences(of: "_", with: "-")
        }


        public var title: String {

            switch self {

            case .en:
                return "English"

            case .zh_Hans:
                return "中文（简体）"

            case .zh_Hant:
                return "中文（繁體）"

            case .ar:
                return "العربية"

            case .es:
                return "Español"

            case .fr:
                return "Français"

            case .de:
                return "Deutsch"

            case .pt:
                return "Português"

            case .ja:
                return "日本語"

            case .ko:
                return "한국어"

            case .hi:
                return "हिन्दी"

            case .id:
                return "Bahasa Indonesia"

            case .ms:
                return "Bahasa Melayu"

            case .fil:
                return "Filipino"

            case .bn:
                return "বাংলা"

            case .ur:
                return "اردو"

            case .sw:
                return "Kiswahili"

            case .ha:
                return "Hausa"

            case .th:
                return "ไทย"

            case .vi:
                return "Tiếng Việt"

            case .ta:
                return "தமிழ்"
            }
        }
    }
}
