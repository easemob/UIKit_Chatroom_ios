//
//  LanguaConvertor.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import UIKit


/// https://learn.microsoft.com/en-us/azure/ai-services/translator/language-support#translation 
public enum LanguageType: String {
    case Chinese = "zh-Hans", Chinese_traditional = "zh-Hant", English = "en", Russian = "ru", German = "de", French = "fr", Japanese = "ja", Korean = "ko", Auto = "auto"
}

/**
 A utility class for converting language keys to localized strings.
 */
@objc public final class LanguageConvertor: NSObject {

    public static func localValue(key: String) -> String {
        LanguageConvertor.shared.localValue(key)
    }

    public static let shared = LanguageConvertor()

    override private init() {}

    var currentLocal: Locale {
        Locale.current
    }

    /**
     Returns a localized string for the given key.
     
     - Parameter key: The key for the localized string.
     - Returns: The localized string for the given key.
     */
    private func localValue(_ key: String) -> String {
        guard var lang = NSLocale.preferredLanguages.first else { return Bundle.main.bundlePath }
        if lang.contains("zh") {
            lang = "zh-Hans"
        } else {
            lang = "en"
        }
        let path = Bundle.chatroomBundle.path(forResource: lang, ofType: "lproj") ?? ""
        let pathBundle = Bundle(path: path) ?? .main
        return pathBundle.localizedString(forKey: key, value: nil, table: nil)
    }

}
