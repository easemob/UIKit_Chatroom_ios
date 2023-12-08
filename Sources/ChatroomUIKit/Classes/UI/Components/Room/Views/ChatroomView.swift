//
//  ChatroomView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit


/// ChatroomView all action events delegate.
@objc public protocol ChatroomViewActionEventsDelegate {
    
    /// The method called on ChatroomView message  clicked.
    /// - Parameter message: `ChatMessage`
    func onMessageClicked(message: ChatMessage)
    
    /// The method called on ChatroomView message  long pressed.
    /// - Parameter message: `ChatMessage`
    func onMessageLongPressed(message: ChatMessage)
    
    /// The method called on ChatroomView raise keyboard button clicked.
    func onKeyboardRaiseClicked()
    
    /// The method called on ChatroomView extension view  item clicked that below chat area list .
    /// - Parameter item: The item conform `ChatBottomItemProtocol` instance.
    func onExtensionBottomItemClicked(item: ChatBottomItemProtocol)
}

/// ChatroomUIKit's ChatroomView UI component.
@objc open class ChatroomView: UIView {
    
    /// ``RoomService``
    public private(set) weak var service: RoomService?
    
    lazy private var eventHandlers: NSHashTable<ChatroomViewActionEventsDelegate> = NSHashTable<ChatroomViewActionEventsDelegate>.weakObjects()
        
    public private(set) lazy var carouselTextView: GlobalBoardcastView = {
        GlobalBoardcastView(originPoint: Appearance.notifyMessageOriginPoint, width: self.frame.width-40, font: UIFont.theme.headlineExtraSmall, textColor: UIColor.theme.neutralColor98).cornerRadius(.large).backgroundColor(Appearance.notifyBackgroundColor)
    }()
        
    /// Gift list on receive gift.
    public private(set) lazy var giftArea: GiftMessageList = {
        GiftMessageList(frame: CGRect(x: 10, y: self.touchFrame.minY, width: self.touchFrame.width-120, height: Appearance.giftAreaRowHeight*2),source:self)
    }()
    
    /// Chat area list.
    public private(set) lazy var chatList: MessageList = {
        MessageList(frame: CGRect(x: 0, y: ChatroomUIKitClient.shared.option.option_UI.showGiftMessageArea ? self.giftArea.frame.maxY+5:self.touchFrame.minY, width: self.touchFrame.width-50, height: self.touchFrame.height-54-BottomBarHeight-5-(ChatroomUIKitClient.shared.option.option_UI.showGiftMessageArea ? (Appearance.giftAreaRowHeight*2):0))).backgroundColor(.clear)
    }()
    
    /// Bottom function bar below chat  list.
    public private(set) lazy var bottomBar: BottomAreaToolBar = {
        BottomAreaToolBar(frame: CGRect(x: 0, y: self.frame.height-54-BottomBarHeight, width: self.touchFrame.width, height: 54), datas: ChatroomUIKitClient.shared.option.option_UI.bottomDataSource)
    }()
    
    /// Input text menu bar.
    public private(set) lazy var inputBar: MessageInputBar = {
        ComponentsRegister.shared.InputBar.init(frame: CGRect(x: 0, y: self.frame.height, width: self.touchFrame.width, height: 52),text: nil,placeHolder: Appearance.inputPlaceHolder)
    }()
    
    private var touchFrame = CGRect.zero
    
    /// Chatroom view init method.
    /// - Parameters:
    ///   - frame: CGRect
    @objc public required convenience init(respondTouch frame: CGRect) {
        if ChatroomUIKitClient.shared.option.option_UI.showGiftMessageArea {
            if frame.height < ScreenHeight/5.0+(Appearance.giftAreaRowHeight*2)+54 {
                assert(false,"The lower limit of the entire view height must not be less than `ScreenHeight/5.0+(Appearance.giftAreaRowHeight*2)+54`.")
            }
        } else {
            if frame.height < ScreenHeight/5.0+54 {
                assert(false,"The lower limit of the chat view height must not be less than `ScreenHeight/5.0+54`.")
            }
        }
        self.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: ScreenHeight))
        self.touchFrame = frame
        if ChatroomUIKitClient.shared.option.option_UI.showGiftMessageArea {
            self.addSubViews([self.giftArea,self.bottomBar,self.chatList,self.inputBar,self.carouselTextView])
        } else {
            self.addSubViews([self.bottomBar,self.chatList,self.inputBar,self.carouselTextView])
        }
        self.carouselTextView.alpha = 0
        self.chatList.addActionHandler(actionHandler: self)
        self.bottomBar.addActionHandler(actionHandler: self)
        self.inputBar.sendClosure = { [weak self] in
            self?.sendTextMessage(text: $0)
        }

    }
    
    private func sendTextMessage(text: String) {
        self.service?.roomService?.sendMessage(text: text, roomId: ChatroomContext.shared?.roomId ?? "", completion: { [weak self] message, error in
            if error == nil {
                self?.chatList.showNewMessage(message: message, gift: nil)
            } else {
                let errorInfo = "Send message failure!\n\(error?.errorDescription ?? "")"
                consoleLogInfo(errorInfo, type: .error)
            }
            if let eventsListeners =  self?.service?.eventsListener.allObjects {
                for listener in eventsListeners {
                    listener.onEventResultChanged(error: error, type: .sendMessage)
                }
            }
        })
    }
    
    /// This method binds your view to the model it serves. A ChatroomView can only call it once. There is judgment in this method. Calling it multiple times is invalid.
    /// - Parameter service: ``RoomService``
    @objc public func connectService(service: RoomService) {
        if self.service != nil {
            return
        }
        self.service = service
        service.bindChatDrive(Drive: self.chatList)
        if ChatroomUIKitClient.shared.option.option_UI.showGiftMessageArea {
            service.bindGiftDrive(Drive: self.giftArea)
        }
        service.bindGlobalNotifyDrive(Drive: self.carouselTextView)
        service.enterRoom(completion: { [weak self] error in

            if let eventsListeners =  self?.service?.eventsListener.allObjects {
                for listener in eventsListeners {
                    listener.onEventResultChanged(error: error, type: .join)
                }
            }
        })
    }
    
    /// Disconnect room service
    /// - Parameter service: ``RoomService``
    @objc public func disconnectService(service: RoomService) {
        self.service?.leaveRoom(completion: { [weak self] error in
            if error == nil {
                self?.service = nil
            } else {
                let errorInfo = "SDK leave chatroom failure!\nError:\(error?.errorDescription ?? "")"
                consoleLogInfo(errorInfo, type: .error)
                if let eventsListeners =  self?.service?.eventsListener.allObjects {
                    for listener in eventsListeners {
                        listener.onEventResultChanged(error: error, type: .leave)
                    }
                }
            }
        })
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let respondRect = CGRect(x: self.touchFrame.minX, y: self.touchFrame.minY+Appearance.giftAreaRowHeight*2-Appearance.maxInputHeight, width: self.touchFrame.width, height: self.touchFrame.height)
        if respondRect.contains(point) {
            for subview in subviews.reversed() {
                let convertedPoint = subview.convert(point, from: self)
                if let hitView = subview.hitTest(convertedPoint, with: event) {
                    return hitView
                }
            }
        }
        return super.hitTest(point, with: event)
    }
    
    /// When you want receive chatroom view's touch action events.You can called the method.
    /// - Parameter actionHandler: ``ChatroomViewActionEventsDelegate``
    @objc public func addActionHandler(actionHandler: ChatroomViewActionEventsDelegate) {
        if self.eventHandlers.contains(actionHandler) {
            return
        }
        self.eventHandlers.add(actionHandler)
    }
    
    /// When you doesn't want receive chatroom view's touch action events.You can called the method.
    /// - Parameter actionHandler: ``ChatroomViewActionEventsDelegate``
    @objc public func removeEventHandler(actionHandler: ChatroomViewActionEventsDelegate) {
        self.eventHandlers.remove(actionHandler)
    }
    
    deinit {
        consoleLogInfo("\(self.swiftClassName ?? "") deinit", type: .debug)
    }
}

//MARK: - GiftMessageListTransformAnimationDataSource
extension ChatroomView: GiftMessageListTransformAnimationDataSource {
    public func rowHeight() -> CGFloat {
        Appearance.giftAreaRowHeight
    }
}

//MARK: - MessageListActionEventsHandler
extension ChatroomView: MessageListActionEventsHandler {
    
    public func onMessageLongPressed(message: ChatMessage) {
        if message.body.type == .custom {
            return
        }
        var messageActions = [ActionSheetItemProtocol]()
        if let owner = ChatroomContext.shared?.owner,owner {
            messageActions.append(contentsOf: Appearance.defaultMessageActions)
            if let map = ChatroomContext.shared?.muteMap,let mute = map[message.from] {
                if mute {
                    if let index = messageActions.firstIndex(where: { $0.tag == "Mute"
                    }) {
                        messageActions[index] = ActionSheetItem(title: "barrage_long_press_menu_unmute".chatroom.localize, type: .normal,tag: "unMute")
                    }
                } else {
                    if let index = messageActions.firstIndex(where: { $0.tag == "unMute"
                    }) {
                        messageActions[index] = ActionSheetItem(title: "barrage_long_press_menu_mute".chatroom.localize, type: .normal, tag: "Mute")
                    }
                }
            } else {
                if let index = messageActions.firstIndex(where: { $0.tag == "unMute"
                }) {
                    messageActions[index] = ActionSheetItem(title: "barrage_long_press_menu_mute".chatroom.localize, type: .normal, tag: "Mute")
                } else {
                    let item = messageActions.first { $0.tag == "Mute" }
                    if item == nil {
                        messageActions.insert(ActionSheetItem(title: "barrage_long_press_menu_mute".chatroom.localize, type: .normal, tag: "Mute"), at: 2)
                    }
                }
            }
        } else {
            messageActions.append(contentsOf: Appearance.defaultMessageActions)
            if let index = messageActions.firstIndex(where: { $0.tag == "Mute"
            }) {
                messageActions.remove(at: index)
            }
            if let index = messageActions.firstIndex(where: { $0.tag == "unMute"
            }) {
                messageActions.remove(at: index)
            }
            if let index = messageActions.firstIndex(where: { $0.tag == "Delete"
            }) {
                messageActions.remove(at: index)
            }
        }
        self.showLongPressDialog(message: message, messageActions: messageActions)
        for delegate in self.eventHandlers.allObjects {
            delegate.onMessageLongPressed(message: message)
        }
    }
    
    private func showLongPressDialog(message: ChatMessage,messageActions: [ActionSheetItemProtocol]) {
        DialogManager.shared.showMessageActions(actions: messageActions) { [weak self] item in
            switch item.tag {
            case "Translate":
                self?.service?.translate(message: message, completion: { _ in })
            case "Delete":
                self?.service?.recall(message: message, completion: { _ in })
            case "Mute":
                self?.service?.mute(userId: message.from, completion: { _ in })
            case "unMute":
                self?.service?.unmute(userId: message.from, completion: { _ in })
            case "Report":
                DialogManager.shared.showReportDialog(message: message) { error in
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        if let eventsListeners =  self?.service?.eventsListener.allObjects {
                            for listener in eventsListeners {
                                listener.onEventResultChanged(error: error, type: .recall)
                            }
                        }
                    }
                }
            default:
                item.action?(item)
            }
        }
    }
    
    public func onMessageClicked(message: ChatMessage) {
        for delegate in self.eventHandlers.allObjects {
            delegate.onMessageClicked(message: message)
        }
    }
    
}

//MARK: - ChatBottomFunctionBarActionEvents
extension ChatroomView: BottomAreaToolBarActionEvents {
    
    public func onBottomItemClicked(item: ChatBottomItemProtocol) {
        item.action?(item)
        for delegate in self.eventHandlers.allObjects {
            delegate.onExtensionBottomItemClicked(item: item)
        }
    }
    
    public func onKeyboardWillWakeup() {
        self.inputBar.show()
        for delegate in self.eventHandlers.allObjects {
            delegate.onKeyboardRaiseClicked()
        }
    }
    
    
}
