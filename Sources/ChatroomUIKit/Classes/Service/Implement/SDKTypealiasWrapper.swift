//
//  TypealiasWrapper.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import Foundation
/**
 This code defines typealiases for chat client, delegates, errors, messages, message bodies, chatrooms, user info, connection state, options, recall info, and cursor result for two different chat SDKs: HyphenateChat and AgoraChat.
 
 If HyphenateChat is imported, the typealiases are defined for HyphenateChat classes. If AgoraChat is imported, the typealiases are defined for AgoraChat classes.
 
 */

#if canImport(HyphenateChat)
import HyphenateChat
public typealias ChatClient = EMClient
public typealias ChatClientDelegate = EMClientDelegate
public typealias ChatManagerDelegate = EMChatManagerDelegate
public typealias ChatError = EMError
public typealias ChatErrorCode = EMErrorCode
public typealias ChatMessage = EMChatMessage
public typealias ChatMessageBody = EMMessageBody
public typealias ChatTextMessageBody = EMTextMessageBody
public typealias ChatCustomMessageBody = EMCustomMessageBody
public typealias ChatroomManagerDelegate = EMChatroomManagerDelegate
public typealias ChatRoom = EMChatroom
public typealias UserInfo = EMUserInfo
public typealias ChatroomBeKickedReason = EMChatroomBeKickedReason
public typealias ConnectionState = EMConnectionState
public typealias Options = EMOptions
public typealias RecallInfo = EMRecallMessageInfo
public typealias CursorResult = EMCursorResult

#elseif canImport(AgoraChat)
import AgoraChat
public typealias ChatClient = AgoraChatClient
public typealias ChatClientDelegate = AgoraChatClientDelegate
public typealias ChatManagerDelegate = AgoraChatChatManagerDelegate
public typealias ChatError = AgoraChatError
public typealias ChatErrorCode = AgoraChatErrorCode
public typealias ChatMessage = AgoraChatChatMessage
public typealias ChatMessageBody = AgoraChatMessageBody
public typealias ChatTextMessageBody = AgoraChatTextMessageBody
public typealias ChatCustomMessageBody = AgoraChatCustomMessageBody
public typealias ChatroomManagerDelegate = AgoraChatChatroomManagerDelegate
public typealias ChatRoom = AgoraChatChatroom
public typealias UserInfo = AgoraChatUserInfo
public typealias ChatroomBeKickedReason = AgoraChatChatroomBeKickedReason
public typealias ConnectionState = AgoraChatConnectionState
public typealias Options = AgoraChatOptions
public typealias RecallInfo = AgoraChatRecallMessageInfo
public typealias CursorResult = AgoraChatCursorResult
#endif

