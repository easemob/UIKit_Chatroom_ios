//
//  UserService.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/28.
//

import Foundation


@objc public protocol UserInfoProtocol: NSObjectProtocol {
    
    /// Your application's userId register for chat.
    var userId: String { set get }
    
    /// User's nickname
    var nickName: String { set get }
    
    /// User's avatar url
    var avatarURL: String { set get }
    
    /// The user's gender. If you didn't set, the default value is 0.  For example you can set 1 for male and 2 for female
    var gender: Int { set get }
    
    /// User's identify picture url
    var identify: String {set get}
}

@objc public protocol UserServiceProtocol: NSObjectProtocol {
    
    /// Bind user state changed listener
    /// - Parameter listener: UserStateChangedListener
    func bindUserStateChangedListener(listener: UserStateChangedListener)
    
    /// Unbind user state changed listener
    /// - Parameter listener: UserStateChangedListener
    func unBindUserStateChangedListener(listener: UserStateChangedListener)
    
    /// Get user info by userId.The frequency of api usage for free users is 100 times in 1 second.Upgrading the package can increase the usage.
    /// - Parameters:
    ///   - userId: userId
    ///   - completion: completion
    func userInfo(userId: String, completion: @escaping (UserInfoProtocol?,ChatError?) -> Void)
    
    /// Get user info by userIds.The frequency of api usage for free users is 100 times in 1 second.Upgrading the package can increase the usage.
    /// - Parameters:
    ///   - userIds: userIds
    ///   - completion: completion
    func userInfos(userIds: [String], completion: @escaping ([UserInfoProtocol],ChatError?) -> Void)
    
    /// Update user info.The frequency of api usage for free users is 100 times in 1 second.Upgrading the package can increase the usage.
    /// - Parameters:
    ///   - userInfo: UserInfoProtocol
    ///   - completion: 
    func updateUserInfo(userInfo: UserInfoProtocol, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Login SDK
    /// - Parameters:
    ///   - userId: user id
    ///   - token: chat token(https://console.agora.io/project/WLRRH-ir6/extension?id=Chat or https://console.easemob.com/app/applicationOverview/userManagement  can build temp token)
    ///   - completion: Callback,success or failure
    func login(userId: String, token: String, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Logout SDK
    /// - Parameter completion: Callback,success or failure
    func logout(completion: @escaping (Bool,ChatError?) -> Void)
    
    
}


@objc public protocol UserStateChangedListener: NSObjectProtocol {
    
    /// User login at other device
    /// - Parameter device: Other device name
    func onUserLoginOtherDevice(device: String)
    
    /// User token will expired,when you need to fetch chat token  re-login.
    func onUserTokenWillExpired()
    
    /// User token expired,when you need to fetch chat token  re-login.
    func onUserTokenDidExpired()
    
    /// Chatroom socket connection state changed listener.
    /// - Parameter state: ConnectionState
    func onSocketConnectionStateChanged(state: ConnectionState)
        
}
