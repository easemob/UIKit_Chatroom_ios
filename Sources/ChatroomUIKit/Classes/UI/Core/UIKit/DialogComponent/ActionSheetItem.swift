//
//  ActionSheetItem.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/28.
//

import Foundation


public typealias ActionClosure = ((ActionSheetItemProtocol) -> Void)

/// An enumeration representing the type of an action sheet item.
@objc public enum ActionSheetItemType: Int {
    case normal
    case destructive
}

/// A protocol that defines properties and methods for an action sheet item.
@objc public protocol ActionSheetItemProtocol: NSObjectProtocol {
    
    /// The title of the action sheet item.
    var title: String {set get}
    
    /// The type of the action sheet item.``ActionSheetItemType``
    var type: ActionSheetItemType {set get}
    
    /// The tag of the action sheet item.
    var tag: String {set get}
    
    /// The closure to be executed when the action sheet item is selected.
    var action: ActionClosure? {set get}    

    /// The image of the action sheet item.
    var image: UIImage? {set get}
}

@objcMembers public final class ActionSheetItem: NSObject,ActionSheetItemProtocol {
    

/**
 A convenience initializer for creating an `ActionSheetItem` object with a title, type, tag, and action closure.

 - Parameters:
     - title: The title of the action sheet item.
     - type: The type of the action sheet item.
     - tag: The tag of the action sheet item.
     - action: The closure to be executed when the action sheet item is selected.

 - Returns: An `ActionSheetItem` object.
 */
@objc public required init(title: String, type: ActionSheetItemType, tag: String, action: @escaping ActionClosure) {
    self.action = action
    self.title = title
    self.type = type
    self.tag = tag
    super.init()
}

/**
 A convenience initializer for creating an `ActionSheetItem` object with a title, type, and tag.

 - Parameters:
     - title: The title of the action sheet item.
     - type: The type of the action sheet item.
     - tag: The tag of the action sheet item.

 - Returns: An `ActionSheetItem` object.
 */
@objc public required init(title: String, type: ActionSheetItemType, tag: String) {
    self.title = title
    self.type = type
    self.tag = tag
    super.init()
}

    public var title: String = ""
    public var type: ActionSheetItemType = .normal
    public var action: ActionClosure?
    public var image: UIImage? = nil
    public var tag: String = ""
}
