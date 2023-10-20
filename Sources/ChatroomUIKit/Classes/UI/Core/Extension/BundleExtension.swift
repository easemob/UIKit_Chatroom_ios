//
//  BundleExtension.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import Foundation

/**
 A type extension to provide a computed property for ChatroomResourceBundle.
 
 This extension provides a computed property `chatroomBundle` of type `Bundle` to access the ChatroomResourceBundle. If the ChatroomResourceBundle is already initialized, it returns the existing instance. Otherwise, it initializes the ChatroomResourceBundle with the path of the "ChatRoomResource.bundle" file in the main bundle. If the bundle is not found, it returns the main bundle.
 */
fileprivate var ChatroomResourceBundle: Bundle?

public extension Bundle {
    /**
     A computed property to access the ChatroomResourceBundle.
     
     This computed property returns the ChatroomResourceBundle. If the ChatroomResourceBundle is already initialized, it returns the existing instance. Otherwise, it initializes the ChatroomResourceBundle with the path of the "ChatRoomResource.bundle" file in the main bundle. If the bundle is not found, it returns the main bundle.
     */
    class var chatroomBundle: Bundle {
        if ChatroomResourceBundle != nil {
            return ChatroomResourceBundle!
        }
        let bundlePath = Bundle.main.path(forResource: "ChatRoomResource", ofType: "bundle") ?? ""
        ChatroomResourceBundle = Bundle(path:  bundlePath) ?? .main
        return ChatroomResourceBundle!
    }
}
