//
//  ChatService.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/28.
//

import Foundation


/// Chatroom user operation events.
@objc public enum ChatroomUserOperationType: Int {
    case addAdministrator
    case removeAdministrator
    case mute
    case unmute
    case block
    case unblock
    case kick
}

/// Chatroom operation events.Ext,leave or join.
@objc public enum ChatroomOperationType: Int {
    case join
    case leave
}


@objc public protocol ChatroomService: NSObjectProtocol {
    
    /// Binding a listener to receive callback events.
    /// - Parameter response: ChatResponseListener
    func bindResponse(response: ChatroomResponseListener)
    
    /// Unbind the listener.
    /// - Parameter response: ChatResponseListener
    func unbindResponse(response: ChatroomResponseListener)
    
    /// Chatroom operation events.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: user id
    ///   - type: ChatroomOperationType
    ///   - completion: callback,what if success or error.
    func chatroomOperating(roomId: String, userId: String, type: ChatroomOperationType, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Fetch chatroom participants.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - pageSize: The number of chat room members you want to obtain at a time.
    ///   - completion: Callback,what if success or error.Success mens result contain [UserId].
    func fetchParticipants(roomId: String,pageSize: UInt,completion: @escaping ([String]?,ChatError?) -> Void)
    
    /// Fetch chatroom mute users
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - pageNum: pageNum
    ///   - pageSize: pageSize
    ///   - completion: Callback,what if success or error.Success mens result contain [UserId].
    func fetchMuteUsers(roomId: String,pageNum: UInt,pageSize: UInt,completion: @escaping ([String]?,ChatError?) -> Void)
    
    /// Get chatroom announcement.
    func announcement(roomId: String, completion: @escaping (String?,ChatError?) -> Void)
    
    /// Update chatroom announcement
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - announcement: announcement content
    ///   - completion: Updated callback,what if success or error.
    func updateAnnouncement(roomId: String, announcement: String, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Various operations of group owners or administrators on users.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: user id
    ///   - type: ChatroomUserOperationType
    ///   - completion: callback,what if success or error.
    func operatingUser(roomId: String, userId: String, type: ChatroomUserOperationType, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Send text message to chatroom.
    /// - Parameters:
    ///   - text: You'll send text.
    ///   - roomId: chatroom id
    ///   - completion: Send callback,what if success or error.
    func sendMessage(text: String, roomId: String, completion: @escaping (ChatMessage,ChatError?) -> Void)
    
    /// Send targeted text messages to some members of the chat room
    /// - Parameters:
    ///   - userIds: [UserId]
    ///   - roomId: chatroom id
    ///   - content: content text
    ///   - completion: Send callback,what if success or error.
    func sendMessage(to userIds:[String], roomId: String, content: String, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Send targeted custom messages to some members of the chat room
    /// - Parameters:
    ///   - userIds: userIds description
    ///   - roomId: [UserId]
    ///   - eventType: A constant String value that identifies the type of event.
    ///   - infoMap: Extended Information
    ///   - completion: Send callback,what if success or error.
    func sendCustomMessage(to userIds:[String], roomId: String, eventType: String, infoMap:[String:String], completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Translate the specified message
    /// - Parameters:
    ///   - message: ChatMessage kind of text message.
    ///   - completion: Translate callback,what if success or error.
    func translateMessage(message: ChatMessage, completion: @escaping (ChatMessage?,ChatError?) -> Void)
    
    /// Recall message.
    /// - Parameters:
    ///   - messageId: message id
    ///   - completion: Recall callback,what if success or error.
    func recall(messageId: String, completion: @escaping (ChatError?) -> Void)
    
    /// Report illegal message.
    /// - Parameters:
    ///   - messageId: message id
    ///   - tag: Illegal type defined at console.
    ///   - reason: reason
    ///   - completion: Report callback,what if success or error.
    func report(messageId: String,tag: String,reason: String, completion: @escaping (ChatError?) -> Void)
}


@objc public protocol ChatroomResponseListener:NSObjectProtocol {
    
    /// Received message from chatroom members.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - message: EMChatMessage
    func onMessageReceived(roomId: String,message: ChatMessage)
    
    /// When some one recall a message,the method will call.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - message: ChatMessage
    ///   - userId: call recall user id
    func onMessageRecalled(roomId: String, message: ChatMessage,by userId: String)
    
    /// When admin publish global notify message,the method will called.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - notifyMessage: ChatMessage
    func onGlobalNotifyReceived(roomId: String,notifyMessage: ChatMessage)
    
    /// When a user joins a chatroom.The method carry user info for display.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - message: ``ChatMessage``
    func onUserJoined(roomId: String, message: ChatMessage)
    
    /// When some user leave chatroom.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: user id
    func onUserLeave(roomId: String,userId: String)
    
    /// When chatroom announcement updated.The method will called.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - announcement: announcement
    func onAnnouncementUpdate(roomId: String,announcement: String)
    
    /// When some user kicked out by owner.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: user id
    ///   - reason: reason
    func onUserBeKicked(roomId: String, reason: ChatroomBeKickedReason)
    
    /// When some room members were muted,then method will call notify Administrator.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: UserId were muted
    ///   - operatorId: Operator user id
    func onUserMuted(roomId: String,userId: String,operatorId: String)
    
    /// When some room members were unmuted,then method will call notify Administrator.
    /// - Parameters:
    ///   - roomId: chatroom id
    ///   - userId: UserId were muted
    ///   - operatorId: Operator user id
    func onUserUnmuted(roomId: String,userId: String,operatorId: String)
}


