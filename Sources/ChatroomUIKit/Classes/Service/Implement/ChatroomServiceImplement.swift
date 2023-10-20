//
//  ChatServiceImplement.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import UIKit
import KakaJSON

let chatroom_UIKit_user_join = "CHATROOMUIKITUSERJOIN"

@objc public final class ChatroomServiceImplement: NSObject {
    
    var cursor = ""
            
    private var responseDelegates: NSHashTable<ChatroomResponseListener> = NSHashTable<ChatroomResponseListener>.weakObjects()
    
    @objc public override init() {
        super.init()
        ChatClient.shared().roomManager?.add(self, delegateQueue: .main)
        ChatClient.shared().chatManager?.add(self, delegateQueue: .main)
        
    }

    deinit {
        ChatClient.shared().roomManager?.remove(self)
        ChatClient.shared().removeDelegate(self)
    }
}
//MARK: - ChatroomService
extension ChatroomServiceImplement: ChatroomService {
    
    public func bindResponse(response: ChatroomResponseListener) {
        if self.responseDelegates.contains(response) {
            return
        }
        self.responseDelegates.add(response)
    }
    
    public func unbindResponse(response: ChatroomResponseListener) {
        if self.responseDelegates.contains(response) {
            self.responseDelegates.remove(response)
        }
    }
    
    public func chatroomOperating(roomId: String, userId: String, type: ChatroomOperationType, completion: @escaping (Bool, ChatError?) -> Void) {
        switch type {
        case .join:
            ChatClient.shared().roomManager?.joinChatroom(roomId,completion: { [weak self] room, error in
                if error != nil {
                    completion(false,error)
                } else {
                    self?.sendJoinMessage(roomId: room?.chatroomId ?? "", completion: { error in
                        completion(error == nil,error)
                    })
                }
            })
        case .leave:
            ChatClient.shared().roomManager?.leaveChatroom(roomId,completion: { error in
                completion(error == nil,error)
            })
        }
    }
    
    public func announcement(roomId: String, completion: @escaping (String?, ChatError?) -> Void) {
        
        ChatClient.shared().roomManager?.getChatroomAnnouncement(withId: roomId,completion: { content, error in
            completion(content,error)
        })
    }
    
    public func updateAnnouncement(roomId: String, announcement: String, completion: @escaping (Bool, ChatError?) -> Void) {
        ChatClient.shared().roomManager?.updateChatroomAnnouncement(withId: roomId, announcement: announcement,completion: { room, error in
            completion(error == nil,error)
        })
    }
    
    public func operatingUser(roomId: String, userId: String, type: ChatroomUserOperationType, completion: @escaping (Bool, ChatError?) -> Void) {
        switch type {
//        case .addAdministrator:
//            ChatClient.shared().roomManager?.addAdmin(userId, toChatroom: roomId,completion: { room, error in
//                completion(error == nil,error)
//            })
//        case .removeAdministrator:
//            ChatClient.shared().roomManager?.removeAdmin(userId, fromChatroom: roomId,completion: { room, error in
//                completion(error == nil,error)
//            })
        case .block:
            ChatClient.shared().roomManager?.blockMembers([userId], fromChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        case .unblock:
            ChatClient.shared().roomManager?.unblockMembers([userId], fromChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        case .mute:
            ChatClient.shared().roomManager?.muteMembers([userId], muteMilliseconds: 999999, fromChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        case .unmute:
            ChatClient.shared().roomManager?.unmuteMembers([userId], fromChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        case .kick:
            ChatClient.shared().roomManager?.removeMembers([userId], fromChatroom: roomId,completion: { room, error in
                completion(error == nil,error)
            })
        default:
            break
        }
    }
    
    public func sendMessage(text: String, roomId: String, completion: @escaping (ChatMessage, ChatError?) -> Void) {
        let user = ChatroomContext.shared?.currentUser as? User
        let message = ChatMessage(conversationID: roomId, body: ChatTextMessageBody(text: text), ext: user?.kj.JSONObject())
        message.chatType = .chatRoom
        ChatClient.shared().chatManager?.send(message, progress: nil,completion: { chatMessage, error in
            completion(chatMessage ?? ChatMessage(),error)
        })
    }
    
    public func sendMessage(to userIds: [String], roomId: String, content: String, completion: @escaping (Bool, ChatError?) -> Void) {
        let user = ChatroomContext.shared?.currentUser as? User
        let message = ChatMessage(conversationID: roomId, body: ChatTextMessageBody(text: content), ext: user?.kj.JSONObject())
        message.chatType = .chatRoom
        message.receiverList = userIds
        ChatClient.shared().chatManager?.send(message, progress: nil,completion: { chatMessage, error in
            completion(error == nil,error)
        })
    }
    
    public func sendCustomMessage(to userIds: [String], roomId: String, eventType: String, infoMap: [String : String], completion: @escaping (Bool, ChatError?) -> Void) {
        let user = ChatroomContext.shared?.currentUser as? User
        let message = ChatMessage(conversationID: roomId, body: ChatCustomMessageBody(event: eventType, customExt: infoMap), ext: user?.kj.JSONObject())
        message.chatType = .chatRoom
        message.receiverList = userIds
        ChatClient.shared().chatManager?.send(message, progress: nil,completion: { chatMessage, error in
            completion(error == nil,error)
        })
    }
    
    public func translateMessage(message: ChatMessage, completion: @escaping (ChatMessage?,ChatError?) -> Void) {
        ChatClient.shared().chatManager?.translate(message, targetLanguages: [Appearance.targetLanguage.rawValue],completion: { chatMessage, error in
            completion(chatMessage,error)
        })
    }
    
    private func sendJoinMessage(roomId: String, completion: @escaping (ChatError?) -> Void) {
        let user = ChatroomContext.shared?.currentUser.map({
            let user = User()
            user.userId = $0.userId
            user.nickName = $0.nickName
            user.avatarURL = $0.avatarURL
            user.identify = $0.identify
            user.gender = $0.gender
            return user
        })
        let user_json = user?.kj.JSONObject()
        let message = ChatMessage(conversationID: roomId, body: ChatCustomMessageBody(event: chatroom_UIKit_user_join, customExt: nil), ext: user_json)
        message.chatType = .chatRoom
        ChatClient.shared().chatManager?.send(message, progress: nil,completion: { [weak self] chatMessage, error in
            if error == nil {
                self?.notifyJoin(message: message, response: nil)
            }
            completion(error)
        })
    }
    
    public func recall(messageId: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.recallMessage(withMessageId: messageId,completion: { error in
            completion(error)
        })
    }
    
    public func report(messageId: String, tag: String, reason: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.reportMessage(withId: messageId, tag: tag, reason: reason,completion: { error in
            completion(error)
        })
    }
    
    public func fetchParticipants(roomId: String, pageSize: UInt, completion: @escaping ([String]?, ChatError?) -> Void) {
        ChatClient.shared().roomManager?.getChatroomMemberListFromServer(withId: roomId, cursor: self.cursor, pageSize: Int(pageSize),completion: { [weak self] cursorResult, error in
            if error == nil {
                self?.cursor = cursorResult?.cursor ?? ""
            }
            completion(cursorResult?.list as? [String],error)
        })
    }
    
    public func fetchMuteUsers(roomId: String, pageNum: UInt, pageSize: UInt, completion: @escaping ([String]?, ChatError?) -> Void) {
        ChatClient.shared().roomManager?.getChatroomMuteListFromServer(withId: roomId, pageNumber: Int(pageNum), pageSize: Int(pageSize),completion: { ids, error in
            completion(ids,error)
        })
    }
}
//MARK: - ChatRoomManagerDelegate
extension ChatroomServiceImplement: ChatroomManagerDelegate {
    
    public func didDismiss(from aChatroom: ChatRoom, reason aReason: ChatroomBeKickedReason) {
        for response in self.responseDelegates.allObjects {
            if let roomId = aChatroom.chatroomId,let userMap = ChatroomContext.shared?.usersMap {
                if userMap.keys.contains(where: { $0 == ChatroomContext.shared?.currentUser?.userId ?? "" }) {
                    ChatroomContext.shared?.usersMap?.removeValue(forKey: ChatroomContext.shared?.currentUser?.userId ?? "")
                }
                response.onUserBeKicked(roomId: roomId, reason: aReason)
            }
        }
    }
    
    public func chatroomAnnouncementDidUpdate(_ aChatroom: ChatRoom, announcement aAnnouncement: String?) {
        for response in self.responseDelegates.allObjects {
            if let announcement = aAnnouncement,let roomId = aChatroom.chatroomId {
                response.onAnnouncementUpdate(roomId: roomId, announcement: announcement)
            }
        }
    }
    
    public func userDidLeave(_ aChatroom: ChatRoom, user aUsername: String) {
        for response in self.responseDelegates.allObjects {
            if let roomId = aChatroom.chatroomId,let userMap = ChatroomContext.shared?.usersMap {
                if userMap.keys.contains(where: { $0 == aUsername }) {
                    ChatroomContext.shared?.usersMap?.removeValue(forKey: aUsername)
                }
                response.onUserLeave(roomId: roomId, userId: aUsername)
            }
        }
    }
    
    public func chatroomMuteListDidUpdate(_ aChatroom: ChatRoom, removedMutedMembers aMutes: [String]) {
        for response in self.responseDelegates.allObjects {
            for userId in aMutes {
                if let roomId = aChatroom.chatroomId {
                    ChatroomContext.shared?.muteMap?.removeValue(forKey: userId)
                    response.onUserUnmuted(roomId: roomId, userId: userId, operatorId: "")
                }
            }
        }
    }
    
    public func chatroomMuteListDidUpdate(_ aChatroom: ChatRoom, addedMutedMembers aMutes: [String], muteExpire aMuteExpire: Int) {
        for response in self.responseDelegates.allObjects {
            for userId in aMutes {
                if let roomId = aChatroom.chatroomId {
                    ChatroomContext.shared?.muteMap?[userId] = true
                    response.onUserMuted(roomId: roomId, userId: userId, operatorId: "")
                }
            }
        }
    }
    
}
//MARK: - ChatManagerDelegate
extension ChatroomServiceImplement: ChatManagerDelegate {
    
    public func messagesDidReceive(_ aMessages: [ChatMessage]) {
        for message in aMessages {
            for response in self.responseDelegates.allObjects {
                switch message.body.type {
                case .text:
                    if let json = message.ext as? [String:Any] {
                        if let user = model(from: json, type: User.self) as? User {
                            ChatroomContext.shared?.usersMap?[user.userId] = user
                        }
                    }
                    response.onMessageReceived(roomId: message.to, message: message)
                case .custom:
                    self.notifyJoin(message: message, response: response)
                default:
                    if message.broadcast {
                        if let json = message.ext as? [String:Any] {
                            if let user = model(from: json, type: User.self) as? User {
                                ChatroomContext.shared?.usersMap?[user.userId] = user
                            }
                        }
                        response.onGlobalNotifyReceived(roomId: message.to, notifyMessage: message)
                    }
                    break
                }
            }
        }
    }
    
    private func notifyJoin(message: ChatMessage, response: ChatroomResponseListener?) {
        if let body = message.body as? ChatCustomMessageBody{
            if body.event == chatroom_UIKit_user_join,let json = message.ext as? [String:Any] {
                if let user = model(from: json, type: User.self) as? User {
                    ChatroomContext.shared?.usersMap?[user.userId] = user
                    if response != nil {
                        response?.onUserJoined(roomId: message.to, message: message)
                    } else {
                        for response in self.responseDelegates.allObjects {
                            response.onUserJoined(roomId: message.to, message: message)
                        }
                    }
                }
            }
        }
    }
    
    public func messagesInfoDidRecall(_ aRecallMessagesInfo: [RecallInfo]) {
        for info in aRecallMessagesInfo {
            for response in self.responseDelegates.allObjects {
                response.onMessageRecalled(roomId: info.recallMessage.to, message: info.recallMessage, by: info.recallBy)
            }
        }
    }
}


