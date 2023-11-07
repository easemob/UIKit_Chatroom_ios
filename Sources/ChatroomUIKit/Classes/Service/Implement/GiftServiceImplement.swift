//
//  GiftServiceImplement.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import UIKit

let chatroom_UIKit_gift = "CHATROOMUIKITGIFT"

@objc public final class GiftServiceImplement: NSObject {
    
    private var currentRoomId: String = ""
        
    public private(set) var responseDelegates: NSHashTable<GiftResponseListener> = NSHashTable<GiftResponseListener>.weakObjects()

    @objc public init(roomId: String) {
        self.currentRoomId = roomId
        super.init()
        ChatClient.shared().chatManager?.add(self, delegateQueue: .main)
    }
    
    @objc public func notifyGiftDriveShowSelfSend(gift: GiftEntityProtocol,message: ChatMessage) {
        for response in self.responseDelegates.allObjects {
            if ChatroomUIKitClient.shared.option.option_UI.chatBarrageAreaShowGift {
                response.receiveGift(roomId: self.currentRoomId, gift: gift, message: message)
            } else {
                response.receiveGift(roomId: self.currentRoomId, gift: gift)
            }
        }
    }
    
    deinit {
        ChatClient.shared().removeDelegate(self)
    }
}
//MARK: - GiftService
extension GiftServiceImplement: GiftService {
    
    public func sendGift(gift: GiftEntityProtocol, completion: @escaping (ChatMessage?,ChatError?) -> Void) {
        let gift = gift
        let user =  ChatroomContext.shared?.currentUser
        let userMap = ["chatroom_uikit_userInfo":user?.toJsonObject()]
        let message = ChatMessage(conversationID: self.currentRoomId, body: ChatCustomMessageBody(event: chatroom_UIKit_gift, customExt: ["chatroom_uikit_gift" : gift.toJsonObject().chatroom.jsonString]), ext: userMap as [AnyHashable : Any])
        message.chatType = .chatRoom
        ChatClient.shared().chatManager?.send(message, progress: nil,completion: { chatMessage, error in
            completion(chatMessage,error)
        })
    }
    
    public func bindGiftResponseListener(listener: GiftResponseListener) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
    }
    
    public func unbindGiftResponseListener(listener: GiftResponseListener) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
}
//MARK: - ChatManagerDelegate
extension GiftServiceImplement: ChatEventsListener {
    
    public func messagesDidReceive(_ aMessages: [ChatMessage]) {
        for message in aMessages {
            for response in self.responseDelegates.allObjects {
                switch message.body.type {
                case .custom:
                    if let body = message.body as? ChatCustomMessageBody {
                        if body.event == chatroom_UIKit_gift,let json = message.ext?["chatroom_uikit_userInfo"] as? [String:Any] {
                            let user = User()
                            user.setValuesForKeys(json)
                            if let customExt = body.customExt {
                                if !customExt.isEmpty,let jsonString = customExt["chatroom_uikit_gift"] {
                                    let json = jsonString.chatroom.jsonToDictionary()
                                    let entity = GiftEntity()
                                    entity.setValuesForKeys(json)
                                    entity.sendUser = user
                                    if ChatroomUIKitClient.shared.option.option_UI.chatBarrageAreaShowGift {
                                        response.receiveGift(roomId: self.currentRoomId, gift: entity,message: message)
                                    } else {
                                        response.receiveGift(roomId: self.currentRoomId, gift: entity)
                                    }

                                }
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
    }
}

@objcMembers public class GiftEntity:NSObject,GiftEntityProtocol {
    public func toJsonObject() -> Dictionary<String, Any> {
        ["giftId":self.giftId,"giftName":self.giftName,"giftPrice":self.giftPrice,"giftCount":self.giftCount,"giftIcon":self.giftIcon,"giftEffect":self.giftEffect]
    }
    
    
    public var giftId: String = ""
    
    public var giftName: String = ""
    
    public var giftPrice: String = ""
    
    public var giftCount: String = "1"
    
    public var giftIcon: String = ""
    
    public var giftEffect: String = ""
    
    public var selected: Bool = false
    
    public var sentThenClose: Bool = true
    
    public var sendUser: UserInfoProtocol?
    
    required public override init() {
        
    }

    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}

