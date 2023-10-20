//
//  RoomService.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

/// All business service errors
@objc public enum RoomEventsError: UInt {
    case join
    case leave
    case kick
    case mute
    case unmute
    case translate
    case recall
    case report
    case fetchParticipants
    case fetchMutes
}

/// The chat room event listener.
@objc public protocol RoomEventsListener: NSObjectProtocol {
    
    /// Occurs when the network connection status changes.
    /// - Parameter state: ConnectionState. The state of the connection between the UIKit and the server.
    func onSocketConnectionStateChanged(state: ConnectionState)
    
    /// Occurs when the user token expires.
    /// You need to get a new user token from your app server and call `RoomUIKitClient.shared.login(with userId: "user id", token: "token", completion: <#T##(ChatError?) -> Void#>)` to log in again.
    func onUserTokenDidExpired()
    
    /// Occurs when the user token is about to expire.
    /// This callback occurs, starting from when half of the token validity period has passed.
    /// When a user goes offline for two minutes, the server will kick the user out of the chat room and the user needs to rejoin the chat room.
    /// To rejoin the chat room, the user needs to fetch a new token from the server, call `RoomUIKitClient.shared.refreshToken(token: "token")` to refresh the token, and then call the `enterRoom` method to join the chat room.
    func onUserTokenWillExpired()
    
    /// Occurs when a member logs in on another device while remaining in the login state on the current device in a single-device login scenario.
    /// The callback occurs on the current device that gets kicked off.
    /// - Parameter device: The name of another device.
    func onUserLoginOtherDevice(device: String)
    
    /// Occurs when a member is unmuted.
    /// The unmuted member, administrators, and the owner of the chat room receive this event.
    /// - Parameters:
    ///   - roomId: Chat room ID.
    ///   - userId: The user ID of the unmuted member.
    ///   - operatorId: The user ID of the operator that removes the member from the mute list of the chat room.
    func onUserUnmuted(roomId: String, userId: String, operatorId: String)
    
    /// Occurs when a member is muted.
    /// The muted member, administrators, and the owner of the chat room receive this event.
    /// - Parameters:
    ///   - roomId: Chat room ID.
    ///   - userId: The user ID of the muted member.
    ///   - operatorId: The user ID of the operator that adds the member to the mute list of the chat room.
    func onUserMuted(roomId: String, userId: String, operatorId: String)
    
    /// Occurs when a user joins the chat room.
    /// All members in the chat room, except the new member, receive the event.
    /// - Parameters:
    ///   - roomId: Chat room ID.
    ///   - user: The user ID that conforms to UserInfoProtocol.
    func onUserJoined(roomId: String, user: UserInfoProtocol)
    
    /// Occurs when a member leaves the chat room.
    /// All members in the chat room, except the one that leaves, receive the event.
    /// - Parameters:
    ///   - roomId: Chat room ID.
    ///   - userId: The user ID of the member that leaves the chat room.
    func onUserLeave(roomId: String, userId: String)
    
    /// Occurs when a member is removed from the chat room.
    /// The member that is removed from the chat room receives the event.
    /// - Parameters:
    ///   - roomId: Chat room ID.
    ///   - reason: ChatroomBeKickedReason.
    func onUserBeKicked(roomId: String, reason: ChatroomBeKickedReason)
    
    /// Occurs when a global notification message is received.
    /// All members in the chat room receive the event.
    /// - Parameter message: ChatMessage instance.
    func onReceiveGlobalNotify(message: ChatMessage)
    
    /// Occurs when receive new message.
    /// - Parameter message: ``ChatMessage``
    func onReceiveMessage(message: ChatMessage)
    
    /// Occurs when the chat room announcement is updated.
    /// All members in the chat room receive the event.
    /// - Parameters:
    ///   - roomId: Chat room ID.
    ///   - announcement: The chat room announcement text.
    func onAnnouncementUpdate(roomId: String, announcement: String)
    
    /// Occurs when a chat room event error is reported.
    /// The current user receives the event.
    /// - Parameters:
    ///   - error: ChatError
    ///   - type: RoomEventsError
    func onErrorOccur(error: ChatError,type: RoomEventsError)
}

/// Chat room request & response wrapper class in the chat room UIKit.
@objc open class RoomService: NSObject {
    
    /// The chat room events listener.
    public private(set) var eventsListener: NSHashTable<RoomEventsListener> = NSHashTable<RoomEventsListener>.weakObjects()
    
    /// Current chat room ID.
    public private(set)var roomId = "" {
        willSet {
            if !newValue.isEmpty {
                ChatroomContext.shared?.roomId = newValue
            }
        }
    }
    
    /// The current page number for getting chat room members.
    public private(set)var pageNum = 1
    
    public private(set) lazy var giftService: GiftService? = {
        let newValue = GiftServiceImplement(roomId: self.roomId)
        newValue.unbindGiftResponseListener(listener: self)
        newValue.bindGiftResponseListener(listener: self)
        return newValue
    }()
    
    public private(set) lazy var roomService: ChatroomService? =  {
        let implement = ChatroomServiceImplement()
        implement.unbindResponse(response: self)
        implement.bindResponse(response: self)
        return implement
    }()
    
    /// ``ChatroomView``  UI Drive.
    public private(set) weak var chatDrive: IChatBarrageListDrive?
    
    /// ``GiftsBarrageList`` UI Drive
    public private(set) weak var giftDrive: IGiftsBarrageListDrive?
    
    /// ``HorizontalTextCarousel`` UI Drive
    public private(set) weak var notifyDrive: IHorizontalTextCarouselDrive?
    
    @objc public required init(roomId: String) {
        self.roomId = roomId
    }
    
    func bindChatDrive(Drive: IChatBarrageListDrive) {
        self.chatDrive = Drive
    }
    
    func bindGiftDrive(Drive: IGiftsBarrageListDrive) {
        self.giftDrive = Drive
    }
    
    func bindGlobalNotifyDrive(Drive: IHorizontalTextCarouselDrive) {
        self.notifyDrive = Drive
    }
    
    /// Registers an event listener in the chat room.
    /// - Parameter listener: ``RoomEventsListener``
    @objc public func registerListener(listener: RoomEventsListener) {
        if self.eventsListener.contains(listener) {
            return
        }
        self.eventsListener.add(listener)
    }
    
    /// Unregisters an event listener in the chat room.
    /// - Parameter listener: ``RoomEventsListener``
    @objc public func unregisterListener(listener: RoomEventsListener) {
        if self.eventsListener.contains(listener) {
            self.eventsListener.remove(listener)
        }
    }
    
    @objc public func destroyed() {
        self.roomId = ""
        self.roomService = nil
        self.giftDrive = nil
        self.chatDrive = nil
        self.giftDrive = nil
        self.notifyDrive = nil
        self.eventsListener.removeAllObjects()
        ChatroomContext.shared?.roomId = nil
        ChatroomContext.shared?.usersMap?.removeAll()
        ChatroomContext.shared?.muteMap?.removeAll()
    }
    
    private func handleError(type: RoomEventsError,error: ChatError) {
        for handler in self.eventsListener.allObjects {
            handler.onErrorOccur(error: error,type: type)
        }
    }
    
    //MARK: - Room operation
    /// Switches to another chat room.
    /// In this case, the SDK will clean the user cache and fetch member information and the mute list from the server. This will cause a lot of network IO.
    /// This method can only be called by other chat room members than the chat room owner.
    /// - Parameters:
    ///   - roomId: Chat room ID.
    ///   - completion: Switch result.
//    @objc public func switchChatroom(roomId: String,completion: @escaping (ChatError?) -> Void) {
//        self.leaveRoom { _ in }
//        self.roomId = roomId
//        ChatroomContext.shared?.roomId = self.roomId
//        ChatroomContext.shared?.usersMap?.removeAll()
//        ChatroomContext.shared?.muteMap?.removeAll()
//        self.enterRoom(completion: { [weak self] in
//            if $0 == nil {
//                self?.chatDrive?.cleanMessages()
//            }
//            completion($0)
//        })
//    }
    
    @objc public func enterRoom(completion: @escaping (ChatError?) -> Void) {
        if let userId = ChatroomContext.shared?.currentUser?.userId  {
            self.roomService?.chatroomOperating(roomId: self.roomId, userId: userId, type: .join) { [weak self] success, error in
                guard let `self` = self else { return  }
                if !success {
                    let errorInfo = "Joined chatroom error:\(error?.errorDescription ?? "")"
                    consoleLogInfo(errorInfo, type: .error)
                    self.handleError(type: .join, error: error!)
                    UIViewController.currentController?.showToast(toast: errorInfo, duration: 3)
                } else {
                    _ = self.giftService
                }
                completion(error)
            }
        }
    }
    
    @objc public func leaveRoom(completion: @escaping (ChatError?) -> Void) {
        self.roomService?.chatroomOperating(roomId: self.roomId, userId: ChatClient.shared().currentUsername ?? "", type: .leave, completion: { [weak self] success, error in
            if success {
                self?.roomId = ""
            } else {
                self?.handleError(type: .leave, error: error!)
                self?.destroyed()
            }
        })
    }
    //MARK: - Participants operation
    @objc public func kick(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .kick, completion: { [weak self] success, error in
            if error != nil {
                self?.handleError(type: .kick, error: error!)
            } else {
                ChatroomContext.shared?.usersMap?.removeValue(forKey: userId)
            }
            completion(error)
        })
    }
    
    @objc public func mute(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .mute, completion: { [weak self] success, error in
            if error != nil {
                self?.handleError(type: .mute, error: error!)
            } else {
                ChatroomContext.shared?.muteMap?[userId] = true
            }
            completion(error)
        })
    }
    
    @objc public func unmute(userId: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .unmute, completion: { [weak self] success, error in
            if error != nil {
                self?.handleError(type: .unmute, error: error!)
            } else {
                ChatroomContext.shared?.muteMap?.removeValue(forKey: userId)
            }
            completion(error)
        })
    }
    
    @objc public func fetchParticipants(pageSize: UInt, completion: @escaping (([UserInfoProtocol]?,ChatError?)->Void)) {
        self.roomService?.fetchParticipants(roomId: self.roomId, pageSize: pageSize, completion: { [weak self] userIds, error in
            guard let `self` = self else { return  }
            if let ids = userIds {
                var unknownUserIds = [String]()
                for userId in ids {
                    if ChatroomContext.shared?.usersMap?[userId] == nil {
                        unknownUserIds.append(userId)
                    }
                }
                if ChatroomUIKitClient.shared.option.option_chat.useProperties {
                    if unknownUserIds.count > 0,self.pageNum <= 1 {
                        ChatroomUIKitClient.shared.userImplement?.userInfos(userIds: unknownUserIds, completion: { infos, error in
                            if error == nil {
                                var users = [UserInfoProtocol]()
                                for userId in ids {
                                    if let user = ChatroomContext.shared?.usersMap?[userId] {
                                        users.append(user)
                                    }
                                }
                                completion(users,error)
                            } else {
                                completion(nil,error)
                            }
                        })
                    } else {
                        var users = [UserInfoProtocol]()
                        for userId in ids {
                            if let user = ChatroomContext.shared?.usersMap?[userId] {
                                users.append(user)
                            }
                        }
                        completion(users,error)
                    }
                } else {
                    var users = [UserInfoProtocol]()
                    for userId in ids {
                        if let user = ChatroomContext.shared?.usersMap?[userId] {
                            users.append(user)
                        } else {
                            let user = User()
                            user.userId = userId
                            users.append(user)
                        }
                    }
                    completion(users,error)
                }
            } else {
                if error != nil {
                    self.handleError(type: .fetchParticipants, error: error!)
                }
            }
        })
    }
    
    @objc public func fetchMuteUsers(pageSize: UInt, completion: @escaping (([UserInfoProtocol]?,ChatError?)->Void)) {
        self.roomService?.fetchMuteUsers(roomId: self.roomId, pageNum: UInt(self.pageNum), pageSize: pageSize, completion: { [weak self] userIds, error in
            guard let `self` = self else { return }
            if let ids = userIds,(ids.count != 0) {
                var unknownUserIds = [String]()
                for userId in ids {
                    ChatroomContext.shared?.muteMap?[userId] = true
                    if ChatroomContext.shared?.usersMap?[userId] == nil {
                        unknownUserIds.append(userId)
                    }
                }
                if unknownUserIds.count > 0,self.pageNum == 1,ChatroomUIKitClient.shared.option.option_chat.useProperties {
                    ChatroomUIKitClient.shared.userImplement?.userInfos(userIds: unknownUserIds, completion: { infos, error in
                        if error == nil {
                            var users = [UserInfoProtocol]()
                            for userId in ids {
                                if let user = ChatroomContext.shared?.usersMap?[userId] {
                                    users.append(user)
                                }
                            }
                            completion(users,error)
                        } else {
                            completion(nil,error)
                        }
                    })
                } else {
                    var users = [UserInfoProtocol]()
                    for userId in ids {
                        if let user = ChatroomContext.shared?.usersMap?[userId] {
                            users.append(user)
                        } else {
                            let user = User()
                            user.userId = userId
                            users.append(user)
                        }
                    }
                    completion(users,error)
                }
            } else {
                if error != nil {
                    self.handleError(type: .fetchMutes, error: error!)
                }
                completion(nil,error)
            }
        })
    }
    
    /// Fetch user infos on members list end scroll,Then cache user info
    /// - Parameters:
    ///   - unknownUserIds: User ID array without user information
    ///   - completion: Callback user infos and error.
    @objc public func fetchThenCacheUserInfosOnEndScroll(unknownUserIds:[String], completion: @escaping (([UserInfoProtocol]?,ChatError?)->Void)) {
        ChatroomUIKitClient.shared.userImplement?.userInfos(userIds: unknownUserIds, completion: { infos, error in
            if error == nil {
                for info in infos {
                    ChatroomContext.shared?.usersMap?[info.userId] = info
                }
                completion(infos,error)
            } else {
                completion(nil,error)
            }
        })
    }
    
//    @objc public func block(userId: String,completion: @escaping (ChatError?) -> Void) {
//        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .block, completion: { success, error in
//            completion(error)
//        })
//    }
//
//    @objc public func unblock(userId: String,completion: @escaping (ChatError?) -> Void) {
//        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .unblock, completion: { success, error in
//            completion(error)
//        })
//    }
//
//    @objc public func addAdmin(userId: String,completion: @escaping (ChatError?) -> Void) {
//        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .addAdministrator, completion: { success, error in
//            completion(error)
//        })
//    }
//
//    @objc public func removeAdmin(userId: String,completion: @escaping (ChatError?) -> Void) {
//        self.roomService?.operatingUser(roomId: self.roomId, userId: userId, type: .removeAdministrator, completion: { success, error in
//            completion(error)
//        })
//    }
    //MARK: - Message operation
    @objc public func translate(message: ChatMessage,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.translateMessage(message: message, completion: { [weak self] translateResult, error in
            if error == nil,let translation = translateResult {
                self?.chatDrive?.refreshMessage(message: translation)
            } else {
                self?.handleError(type: .translate, error: error!)
            }
            completion(error)
        })
    }
    
    @objc public func recall(message: ChatMessage,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.recall(messageId: message.messageId, completion: { [weak self] error in
            if error != nil {
                self?.handleError(type: .recall, error: error!)
            } else {
                self?.chatDrive?.removeMessage(message: message)
            }
            completion(error)
        })
    }
    
    @objc public func report(message: ChatMessage,tag: String, reason: String,completion: @escaping (ChatError?) -> Void) {
        self.roomService?.report(messageId: message.messageId, tag: tag, reason: reason, completion: { [weak self] error in
            if error != nil {
                self?.handleError(type: .report, error: error!)
            }
            completion(error)
        })
    }
}

extension RoomService: ChatroomResponseListener {
    
    public func onUserMuted(roomId: String, userId: String, operatorId: String) {
        for listener in self.eventsListener.allObjects {
            listener.onUserMuted(roomId: roomId, userId: userId, operatorId: operatorId)
        }

    }
    
    public func onUserUnmuted(roomId: String, userId: String, operatorId: String) {
        for listener in self.eventsListener.allObjects {
            listener.onUserUnmuted(roomId: roomId, userId: userId, operatorId: operatorId)
        }
    }
    
    public func onMessageRecalled(roomId: String, message: ChatMessage, by userId: String) {
        if roomId == self.roomId {
            self.chatDrive?.removeMessage(message: message)
        }
    }
    
    public func onGlobalNotifyReceived(roomId: String, notifyMessage: ChatMessage) {
        if self.roomId == roomId {
            if let body = notifyMessage.body as? ChatTextMessageBody {
                self.notifyDrive?.showNewNotify(text: body.text)
            }
        }
        for listener in self.eventsListener.allObjects {
            listener.onReceiveGlobalNotify(message: notifyMessage)
        }
    }
    
    public func onMessageReceived(roomId: String, message: ChatMessage) {
        if roomId == self.roomId {
            self.chatDrive?.showNewMessage(message: message, gift: nil)
        }
        for listener in self.eventsListener.allObjects {
            listener.onReceiveMessage(message: message)
        }
    }
        
    public func onUserJoined(roomId: String, message: ChatMessage) {
        if roomId == self.roomId {
            self.chatDrive?.showNewMessage(message: message, gift: nil)
        }
        for listener in self.eventsListener.allObjects {
            if let user = message.user {
                listener.onUserJoined(roomId: roomId, user: user)
            }
        }
    }
    
    public func onUserLeave(roomId: String, userId: String) {
        for listener in self.eventsListener.allObjects {
            listener.onUserLeave(roomId: roomId, userId: userId)
        }
    }
    
    public func onAnnouncementUpdate(roomId: String, announcement: String) {
        for listener in self.eventsListener.allObjects {
            listener.onAnnouncementUpdate(roomId: roomId, announcement: announcement)
        }
    }
    
    public func onUserBeKicked(roomId: String, reason: ChatroomBeKickedReason) {
        for listener in self.eventsListener.allObjects {
            listener.onUserBeKicked(roomId: roomId, reason: reason)
        }
    }
    
}


extension RoomService: GiftResponseListener {
    
    public func receiveGift(roomId: String,gift: GiftEntityProtocol) {
        if roomId == self.roomId {
            self.giftDrive?.receiveGift(gift: gift)
        }
    }
    
    public func receiveGift(roomId: String,gift: GiftEntityProtocol, message: ChatMessage) {
        if self.roomId == roomId {
            self.chatDrive?.showNewMessage(message: message,gift: gift)
        }
    }
    
    
}
