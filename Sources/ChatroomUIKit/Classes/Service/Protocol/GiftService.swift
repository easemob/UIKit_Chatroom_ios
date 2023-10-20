//
//  GiftService.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/28.
//

import Foundation

@objc public protocol GiftEntityProtocol: NSObjectProtocol {
    var giftId: String {set get}
    var giftName: String {set get}
    var giftPrice: String {set get}
    var giftCount: String {set get}
    var giftIcon: String {set get}
    /// Developers can upload a special effect to the server that matches the gift ID. The special effect name is the ID of the gift. When entering the room, the SDK will pull the gift resource and download the special effect corresponding to the gift ID. If the value of the gift received is true, the corresponding special effect will be found in full screen. For playback and broadcasting, the gift resource and special effects resource download server can create a web page for users to use. After each app is started, the gift resources are pre-downloaded and cached to disk for UIKit to access before loading the scene.
    var giftEffect: String {set get}
    
    var selected: Bool {set get}
    
    ///  Do you want to close the pop-up window after sending a gift?`true` mens dialog close.
    var sentThenClose: Bool {set get}
    
    var sendUser: UserInfoProtocol? {set get}
}

@objc public protocol GiftService: NSObjectProtocol {
    
    /// Bind user state changed listener
    /// - Parameter listener: UserStateChangedListener
    func bindGiftResponseListener(listener: GiftResponseListener)
    
    /// Unbind user state changed listener
    /// - Parameter listener: UserStateChangedListener
    func unbindGiftResponseListener(listener: GiftResponseListener)
 
    /// Send gift.
    /// - Parameters:
    ///   - gift: ``GiftEntityProtocol``
    ///   - completion: Callback,what if success or error.
    func sendGift(gift: GiftEntityProtocol,completion: @escaping (ChatMessage?,ChatError?) -> Void)
}

@objc public protocol GiftResponseListener: NSObjectProtocol {
    
    /// Some one send gift to chatroom
    /// - Parameter gift: ``GiftEntityProtocol``
    func receiveGift(roomId:String,gift: GiftEntityProtocol)
    
    
    /// Some one send gift to chatroom
    /// - Parameter gift: ``GiftEntityProtocol``
    ///   - message: ``ChatMessage``
    func receiveGift(roomId:String,gift: GiftEntityProtocol,message: ChatMessage)
}
