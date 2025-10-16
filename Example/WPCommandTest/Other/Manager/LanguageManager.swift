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

private extension String{
    /// 加载国际化对应key字符串
    /// - Returns: 结果
    func loadLanguageStr()->Self {
        guard let path = Bundle.main.path(forResource: LanguageManager.current.localFileString, ofType: "lproj") else {
            return Bundle.main.localizedString(forKey: self, value: "", table: nil)
        }
        let bundle = Foundation.Bundle(path: path)
        return bundle?.localizedString(forKey: self, value: "", table: nil) ?? self
    }
}

extension String {
    /// 国际化对应字符串
    /// - Parameter values: 需要替换字符从后往前替换
    /// - Returns: 结果
    func local(_ values:[String] = []) -> String {
        let str = loadLanguageStr()
        var newStr = str as NSString
        let newValue = Array(values.reversed())
        var i = 0
        str.wp.matches(for: "\\[\\$\\$\\]").reversed().forEach { res in
            if let v = newValue.wp.get(i){
                newStr = newStr.replacingCharacters(in: NSRange(res.1, in: str), with: v) as NSString
            }
            i += 1;
        }
        return newStr as String
    }
}

extension Notification.Name{
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

extension LanguageManager {
    enum Lang:String {
        case en_US
        case fr_FR
        case es_ES
        case zh_CN
        case ko_KR
        case zh_TW
        
        init?(localFileString: String) {
            var str:String = ""
            switch localFileString {
            case "en":
                str = Lang.en_US.rawValue
            case "fr":
                str = Lang.fr_FR.rawValue
            case "es":
                str = Lang.es_ES.rawValue
            case "zh-Hans":
                str = Lang.zh_CN.rawValue
            case "ko":
                str = Lang.ko_KR.rawValue
            case "zh-Hant":
                str = Lang.zh_TW.rawValue
            default:
                break
            }
            self.init(rawValue: str)
        }

        var localFileString:String{
            switch self {
            case .en_US:
                return "en"
            case .fr_FR:
                return "fr"
            case .es_ES:
                return "es"
            case .zh_CN:
                return "zh-Hans"
            case .ko_KR:
                return "ko"
            case .zh_TW:
                return "zh-Hant"
            }
        }
        
        var title:String{
            switch self {
            case .en_US:
                return "English"
            case .fr_FR:
                return "Français"
            case .es_ES:
                return "español"
            case .zh_CN:
                return "中文（简体）"
            case .ko_KR:
                return "한국어"
            case .zh_TW:
                return "中文（繁体）"
            }
        }
    }
}

