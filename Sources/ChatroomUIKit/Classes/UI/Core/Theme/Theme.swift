//
//  Theme.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import Foundation

/// Contain light and dark themes of the chat room UIKit.
@objc public enum ThemeStyle: UInt {
    case light
    case dark
}

/// When the system theme changes, you can use this static method to switch between the light and dark themes of the chat room UIKit.
@objc public protocol ThemeSwitchProtocol: NSObjectProtocol {
    
    /// When some view Implement the protocol method,you can use `Theme.switchTheme(style: .dark)` to switch theme.
    /// - Parameter style: ``ThemeStyle``
    func switchTheme(style: ThemeStyle)
    
    /// After the custom view implements this protocol method, you can use this method to switch the custom theme color, which includes the following five hue values: primary, secondary, error, neutral, and neutral special. The designer recommends that the hue values of primary and neutral are the same. The hue values ​​of neutral and neutral special are similar.
    func switchHues()
}


/// The theme switching class is used for users to switch themes or register some user's own views that comply with the ThemeSwitchProtocol protocol.
/// How to use?
/// A view conform ThemeSwitchProtocol.Then Implement protocol methods.When you want switch theme that light and dark themes provided by default chatroom UIKit  `theme` .
/// Call `Theme.switchTheme(style: .dark)` method
/// A view conform ThemeSwitchProtocol.Then Implement protocol methods.When you want switch themes provided by customer .
/// Call `Theme.switchHues(hues: [0.56,0.66,0.76,0.56,0.54])` method.
/// Only one of the above two methods can be called.
@objcMembers open class Theme: NSObject {
    
    public static var style: ThemeStyle = .light
    
    private static var registerViews :NSHashTable<ThemeSwitchProtocol> = NSHashTable<ThemeSwitchProtocol>.weakObjects()
    
    /// Register some user's own views that Implement with the ThemeSwitchProtocol protocol.
    /// - Parameter view: The view conform ThemeSwitchProtocol.
    /// How to use?
    /// `Theme.registerSwitchThemeViews(view: Some view implement ThemeSwitchProtocol)`
    public static func registerSwitchThemeViews(view: ThemeSwitchProtocol) {
        if self.registerViews.contains(view) {
            return
        }
        self.registerViews.add(view)
    }
    
    /// Clean register views.
    public static func unregisterSwitchThemeViews() {
        self.registerViews.removeAllObjects()
    }
    
    /// The method
    /// - Parameter style: ThemeStyle
    /// How to use?
    /// `Theme.switchTheme(style: .dark)`
    @MainActor public static func switchTheme(style: ThemeStyle) {
        self.style = style
        for view in self.registerViews.allObjects {
            view.switchTheme(style: style)
        }
    }
    /// After the custom view implements this protocol method, you can use this method to switch the custom theme color, which includes the following five hue values: primary, secondary, error, neutral, and neutral special. The designer recommends that the hue values of primary and neutral are the same. The hue values ​​of neutral and neutral special are similar.
    @MainActor public static func switchHues() {
        UIColor.ColorTheme.switchHues(hues: [Appearance.primaryHue,Appearance.secondaryHue,Appearance.errorHue,Appearance.neutralHue,Appearance.neutralSpecialHue])
        for view in self.registerViews.allObjects {
            view.switchHues()
        }
    }
        
}

extension Unmanaged where Instance : ThemeSwitchProtocol&UIView {
    
}
