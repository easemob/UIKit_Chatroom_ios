//
//  ChatroomContext.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import UIKit


/**
 A singleton class that represents the context of a chatroom. It contains information about the current user, the owner of the chatroom, the mute map, the room ID, and a dictionary of users in the chatroom.
 */
@objcMembers public final class ChatroomContext: NSObject {
    
    public static let shared: ChatroomContext? = ChatroomContext()
    
    public var ownerId: String = ""
    
    public var currentUser: UserInfoProtocol? {
        willSet {
            if let user = newValue {
                self.usersMap?[user.userId] = user
            }
        }
    }
    
    public var owner: Bool {
        if self.ownerId.isEmpty {
            let chatroom = ChatRoom(id: self.roomId ?? "")
            return (chatroom?.owner ?? "" == ChatClient.shared().currentUsername)
        } else {
            return (self.ownerId == ChatClient.shared().currentUsername)
        }
    }
    
    /// The cache mute users map.Key is user id.
    public var muteMap: Dictionary<String,Bool>? = Dictionary<String,Bool>()
    
    public var roomId: String?
    
    /// The cache users map.Key is user id.Value is conform `UserInfoProtocol` instance.
    public var usersMap: Dictionary<String,UserInfoProtocol>? = Dictionary<String,UserInfoProtocol>()
}
