//
//  RoomUIKitClient.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

/// A wrapper class for some options to be set during initialization of ChatroomUIKit.ChatroomView.
@objcMembers open class ChatroomUIKitInitialOptions: NSObject {
    
    /// The option of UI components.
    public var option_UI: UIOptions = UIOptions()
    
    /// The option of chat sdk function.
    public var option_chat: ChatOptions = ChatOptions()
    
    @objcMembers public class UIOptions: NSObject {
        /// Whether to show a gift barrage.
        @objc public var showGiftsBarrage = true
        
        /// Data source of ``ChatBottomBar``.
        @objc public var bottomDataSource: [ChatBottomItemProtocol] = []
        
        /// Whether to show the gift information in the chat barrage area.
        @objc public var chatBarrageAreaShowGift = false
    }
    
    @objcMembers public class ChatOptions: NSObject {
        
        /// Whether print chat sdk log or not.
        public var enableConsoleLog = false
        
        /// Whether auto login or not.
        public var autoLogin = false
        
        /// Whether to use user attributes.
        @objc public var useProperties: Bool = true
        
    }
}

///ChatroomUIKit initialization class.
@objcMembers final public class ChatroomUIKitClient: NSObject {
    
    static public let shared = ChatroomUIKitClient()
    
    /// User-related protocol implementation class.
    public private(set) lazy var userImplement: UserServiceProtocol? = nil
    
    /// Chat room-related protocol implementation class.
    public private(set) lazy var roomService: RoomService? = nil
    
    /// Options function wrapper.
    public private(set) lazy var option: ChatroomUIKitInitialOptions = ChatroomUIKitInitialOptions()
    
    /// Chatroom id
    public private(set) var roomId = ""
    
    /// Initializes the chat room UIKit.
    /// - Parameters:
    ///   - appKey: The unique identifier that Chat assigns to each app. For details, see https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios#get-chat-project-information.
    /// Returns the initialization success or an error that includes the description of the cause of the failure.
    @objc public func setup(with appKey: String,option: ChatroomUIKitInitialOptions.ChatOptions = ChatroomUIKitInitialOptions.ChatOptions()) -> ChatError? {
        let option = ChatSDKOptions(appkey: appKey)
        option.enableConsoleLog = true
        option.isAutoLogin = false
        return ChatClient.shared().initializeSDK(with: option)
    }
    
    /// Login user.
    /// - Parameters:
    ///   - user: An instance that conforms to ``UserInfoProtocol``.
    ///   - token: The user chat token.
    ///   - userProperties: Whether the user passes in his or her own user information (including the avatar, nickname, and user ID) as user attributes for use in ChatRoom
    @objc public func login(user: UserInfoProtocol,token: String,completion: @escaping (ChatError?) -> Void) {
        ChatroomContext.shared?.currentUser = user
        self.userImplement = UserServiceImplement(userInfo: user, token: token, use: self.option.option_chat.useProperties, completion: completion)
        self.userImplement?.bindUserStateChangedListener(listener: self)
    }
    
    /// Login user id.
    /// - Parameters:
    ///   - userId: The user ID.
    ///   - token: The user chat token.
    ///   - completion: Login result.
    @objc public func login(userId: String,token: String,completion: @escaping (ChatError?) -> Void) {
        let user = User()
        user.userId = userId
        ChatroomContext.shared?.currentUser = user
        self.userImplement = UserServiceImplement(userInfo: user, token: token, use: false, completion: completion)
        self.userImplement?.bindUserStateChangedListener(listener: self)
    }
    
    /// Logout user
    @objc public func logout() {
        self.userImplement?.logout(completion: { _, _ in })
        self.userImplement?.unBindUserStateChangedListener(listener: self)
    }
    
    /// Launches a chat room view of ChatroomUIKit.
    /// - Parameters:
    ///   - roomId: Chat room ID.
    ///   - frame: Frame.
    ///   - ownerId: Owner's user id..
    ///   - options: ``UIOptions``
    /// - Returns: ``ChatroomView`` instance.
    @objc public func launchRoomViewWithOptions(roomId: String,frame: CGRect, ownerId: String , options: ChatroomUIKitInitialOptions.UIOptions = ChatroomUIKitInitialOptions.UIOptions()) -> ChatroomView {
        self.roomId = roomId
        ChatroomContext.shared?.roomId = roomId
        ChatroomContext.shared?.ownerId = ownerId
        self.option.option_UI.bottomDataSource = options.bottomDataSource
        self.option.option_UI.showGiftsBarrage = options.showGiftsBarrage
        self.option.option_UI.chatBarrageAreaShowGift = options.chatBarrageAreaShowGift
        let room = ChatroomView(respondTouch: frame)
        let service = RoomService(roomId: roomId)
        self.roomService = service
        room.connectService(service: service)
        return room
    }
    
    /// Destroys a chat room.
    /// This method frees memory.
    @objc public func destroyRoom() {
        if ChatroomContext.shared?.owner ?? false {
            self.roomService?.destroyed(completion: { [weak self] error in
                self?.roomService = nil
                self?.roomId = ""
            })
        } else {
            self.roomService?.leaveRoom(completion: { [weak self] error in
                self?.roomService = nil
                self?.roomId = ""
            })
        }
    }
    
    /// unregister theme.
    @objc public func unregisterThemes() {
        Theme.unregisterSwitchThemeViews()
    }
    
    /// Updates user information that is used for login with the `login(with user: UserInfoProtocol,token: String,use userProperties: Bool = true,completion: @escaping (ChatError?) -> Void)` method.
    /// - Parameters:
    ///   - info: An instance that conforms to ``UserInfoProtocol``.
    ///   - completion: Callback.
    @objc public func updateUserInfo(info: UserInfoProtocol,completion: @escaping (ChatError?) -> Void) {
        self.userImplement?.updateUserInfo(userInfo: info, completion: { success, error in
            completion(error)
        })
    }
    
    /// Registers a chat room event listener.
    /// - Parameter listener: ``RoomEventsListener``
    @objc public func registerRoomEventsListener(listener: RoomEventsListener) {
        self.roomService?.registerListener(listener: listener)
    }
    
    /// Unregisters a chat room event listener.
    /// - Parameter listener: ``RoomEventsListener``
    @objc public func unregisterRoomEventsListener(listener: RoomEventsListener) {
        self.roomService?.unregisterListener(listener: listener)
    }
    
    ///  Refreshes the user chat token when receiving the ``RoomEventsListener.onUserTokenWillExpired`` callback.
    /// - Parameter token: The user chat token.
    @objc public func refreshToken(token: String) {
        ChatClient.shared().renewToken(token)
    }
}

extension ChatroomUIKitClient: UserStateChangedListener {
    
    public func onUserLoginOtherDevice(device: String) {
        //User will be kick by UIKit.
        if let service = self.roomService {
            for listener in service.eventsListener.allObjects {
                listener.onUserLoginOtherDevice(device: device)
            }
        }
    }
    
    public func onUserTokenWillExpired() {
        //Renew token form your service
        if let service = self.roomService {
            for listener in service.eventsListener.allObjects {
                listener.onUserTokenWillExpired()
            }
        }
    }
    
    public func onUserTokenDidExpired() {
        //Renew token form your service
        if let service = self.roomService {
            for listener in service.eventsListener.allObjects {
                listener.onUserTokenDidExpired()
            }
        }
    }
    
    public func onSocketConnectionStateChanged(state: ConnectionState) {
        switch state {
        case .connected:
            if !self.roomId.isEmpty {
                self.roomService?.enterRoom(completion: { error in
                    if let service = self.roomService,let error = error {
                        for listener in service.eventsListener.allObjects {
                            listener.onErrorOccur(error: error, type: .join)
                        }
                    }
                })
            }
        default:
            break
        }
        if let service = self.roomService {
            for listener in service.eventsListener.allObjects {
                listener.onSocketConnectionStateChanged(state: state)
            }
        }

    }
    
    
}
