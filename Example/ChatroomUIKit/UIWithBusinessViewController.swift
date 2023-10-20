//
//  UIWithBusinessViewController.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import ChatroomUIKit

final class UIWithBusinessViewController: UIViewController {
    
    var style: ThemeStyle = .light
    
    var roomId = ""
    
    var owner = false
    
    var option: ChatroomUIKitInitialOptions.UIOptions {
        let options  = ChatroomUIKitInitialOptions.UIOptions()
        options.bottomDataSource = self.bottomBarDatas()
        options.showGiftsBarrage = true
        options.chatBarrageAreaShowGift = false
        return options
    }
    
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage(named: "background_light"))
    }()
    
    lazy var roomView: ChatroomUIKit.ChatroomView = {
        ChatroomUIKitClient.shared.launchRoomViewWithOptions(roomId: self.roomId, frame: CGRect(x: 0, y: ScreenHeight/2.0, width: ScreenWidth, height: ScreenHeight/2.0), is: ChatroomContext.shared?.owner ?? false, options: self.option)
    }()
    
    lazy var members: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 100, y: 160, width: 150, height: 20)).textColor(.white, .normal).backgroundColor(UIColor.theme.primaryColor6).cornerRadius(.extraSmall).title("Participants", .normal).addTargetFor(self, action: #selector(showParticipants), for: .touchUpInside)
    }()
    
    private lazy var modeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Light","Dark"])
        segment.frame = CGRect(x: 100, y: 195, width: 96, height: 46)
        segment.setImage(UIImage(named: "sun"), forSegmentAt: 0)
        segment.setImage(UIImage(named: "moon"), forSegmentAt: 1)
        segment.tintColor = UIColor(0x009EFF)
        segment.tag = 12
        segment.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        segment.selectedSegmentIndex = self.style == .light ? 0:1
        
        segment.selectedSegmentTintColor = UIColor(0x009EFF)
        segment.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 18, weight: .medium)], for: .selected)
        segment.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16, weight: .regular)], for: .normal)
        segment.addTarget(self, action: #selector(onChanged(sender:)), for: .valueChanged)
        return segment
    }()
    
    lazy var illustrate: UILabel = {
        UILabel(frame: CGRect(x: 100, y: 259, width: 130, height: 20)).text("show gift in chat area").font(UIFont.theme.labelSmall).textColor(UIColor.theme.neutralColor98)
    }()
    
    lazy var showGiftInChatArea: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.frame = CGRect(x: self.illustrate.frame.maxX, y: 255, width: 60, height: 20)
        mySwitch.setOn(false, animated: false)
        mySwitch.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
        return mySwitch
    }()
    
    lazy var gift1: GiftsViewController = {
        GiftsViewController(gifts: self.gifts())
    }()
    
    lazy var gift2: GiftsViewController = {
        GiftsViewController(gifts: self.gifts())
    }()
    
    @objc public required convenience init(chatroomId: String) {
        self.init()
        self.roomId = chatroomId
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.background,self.roomView,self.members,self.modeSegment,self.illustrate,self.showGiftInChatArea])
        //Not necessary.When you want to receive chatroom view's click events.
        self.roomView.addActionHandler(actionHandler: self)
        //Not necessary.But when you want to receive room events,you can call as follows.
        ChatroomUIKitClient.shared.registerRoomEventsListener(listener: self)
    }
        
    deinit {
        ChatroomUIKitClient.shared.unregisterRoomEventsListener(listener: self)
        ChatroomUIKitClient.shared.destroyRoom()
        consoleLogInfo("\(self.swiftClassName ?? "") deinit", type: .debug)
    }
}

extension UIWithBusinessViewController {
    
    @objc private func onChanged(sender: UISegmentedControl) {
        self.style = ThemeStyle(rawValue: UInt(sender.selectedSegmentIndex)) ?? .light
        Theme.switchTheme(style: self.style)
        self.background.image = Theme.style == .dark ? UIImage(named: "background_dark"):UIImage(named: "background_light")
    }
    
    @objc func switchValueChanged(sender: UISwitch) {
        ChatroomUIKitClient.shared.option.option_UI.chatBarrageAreaShowGift = sender.isOn
    }
    
    @objc func showParticipants() {
        DialogManager.shared.showParticipantsDialog { [weak self] user in
            self?.handleUserAction(user: user, muteTab: false)
        } muteMoreClosure: { [weak self] user in
            self?.handleUserAction(user: user, muteTab: true)
        }

    }
    
    private func handleUserAction(user: UserInfoProtocol,muteTab: Bool) {
        DialogManager.shared.showUserActions(actions: muteTab ? Appearance.defaultOperationMuteUserActions:Appearance.defaultOperationUserActions) { item in
            switch item.tag {
            case "Mute":
                ChatroomUIKitClient.shared.roomService?.mute(userId: user.userId, completion: { [weak self] error in
                    guard let `self` = self else { return }
                    if error == nil {
//                        self.removeUser(user: user)
                    } else {
                        self.showToast(toast: "\(error?.errorDescription ?? "")",duration: 3)
                    }
                })
            case "unMute":
                ChatroomUIKitClient.shared.roomService?.unmute(userId: user.userId, completion: { [weak self] error in
                    guard let `self` = self else { return }
                    if error == nil {
//                        self.removeUser(user: user)
                    } else {
                        self.showToast(toast: "\(error?.errorDescription ?? "")", duration: 3)
                    }
                })
            case "Remove":
                DialogManager.shared.showAlert(content: "Remove `\(user.nickName.isEmpty ? user.userId:user.nickName)`.Are you sure?", showCancel: true, showConfirm: true) { [weak self] in
                    guard let `self` = self else { return }
                    ChatroomUIKitClient.shared.roomService?.kick(userId: user.userId) { [weak self] error in
                        guard let `self` = self else { return }
                        if error == nil {
//                            self.removeUser(user: user)
                            self.showToast(toast: error == nil ? "Remove successful!":"\(error?.errorDescription ?? "")",duration: 2)
                        } else {
                            self.showToast(toast: "\(error?.errorDescription ?? "")", duration: 3)
                        }
                    }
                }
            default:
                item.action?(item)
            }
        }
    }
    
    /// Constructor of ``ChatBottomFunctionBar`` data source.
    /// - Returns: Conform ``ChatBottomItemProtocol`` class instance array.
    func bottomBarDatas() -> [ChatBottomItemProtocol] {
        var entities = [ChatBottomItemProtocol]()
        let names = ["ellipsis.circle","mic.slash","gift"]
        for i in 0...names.count-1 {
            let entity = ChatBottomItem()
            entity.showRedDot = false
            entity.selected = false
            entity.selectedImage = UIImage(systemName: names[i])?.withTintColor(UIColor.theme.neutralColor98,renderingMode: .alwaysOriginal)
            entity.normalImage = UIImage(systemName: names[i])?.withTintColor(UIColor.theme.neutralColor98,renderingMode: .alwaysOriginal)
            entity.type = i
            entities.append(entity)
        }
        return entities
    }
    
    /// Simulate fetch json from server .
    /// - Returns: Conform ``GiftEntityProtocol`` class instance.
    private func gifts() -> [GiftEntityProtocol] {
        if let path = Bundle.main.url(forResource: "Gifts", withExtension: "json") {
            var data = Dictionary<String,Any>()
            do {
                data = try Data(contentsOf: path).chatroom.toDictionary() ?? [:]
            } catch {
                assert(false)
            }
            if let jsons = data["gifts"] as? [Dictionary<String,Any>] {
                return jsons.kj.modelArray(GiftEntity.self)
            }
        }
        return []
    }
}

//MARK: - When you called `self.roomView.addActionHandler(actionHandler: self)`.You'll receive chatroom view's click action events callback.
extension UIWithBusinessViewController : ChatroomViewActionEventsDelegate {
    func onMessageBarrageClicked(message: ChatroomUIKit.ChatMessage) {
        //Statistical data
    }
    
    func onMessageListBarrageLongPressed(message: ChatroomUIKit.ChatMessage) {
        //Statistical data
    }
    
    func onKeyboardRaiseClicked() {
        //Statistical data
    }
    
    func onExtensionBottomItemClicked(item: ChatroomUIKit.ChatBottomItemProtocol) {
        if item.type == 2 {
            DialogManager.shared.showGiftsDialog(titles: ["Gifts","1231232"], gifts: [self.gift1,self.gift2])
        }
    }
    
    
}
//MARK: - When you called `ChatroomUIKitClient.shared.registerRoomEventsListener(listener: self)`.You'll implement these method.
extension UIWithBusinessViewController: RoomEventsListener {
    func onReceiveMessage(message: ChatroomUIKit.ChatMessage) {
        //Received new message
    }
    
    func onUserLeave(roomId: String, userId: String) {
        //Statistical data
        self.showToast(toast: "\(ChatroomContext.shared?.usersMap?[userId]?.nickName ?? userId) was left.", duration: 3)
    }
    
    
    func onSocketConnectionStateChanged(state: ChatroomUIKit.ConnectionState) {
        self.showToast(toast: "Socket connection state change to \(state.rawValue).", duration: 3)
    }
    
    func onUserTokenDidExpired() {
        self.showToast(toast: "User chat token was expired.", duration: 3)
        //SDK will auto enter current chatroom of `ChatroomContext` on reconnect success.
        ChatroomUIKitClient.shared.login(user: ExampleRequiredConfig.YourAppUser(), token: ExampleRequiredConfig.chatToken) { [weak self] error in
            if error != nil {
                self?.showToast(toast: "User chat token was expired.Login again error:\(error?.errorDescription ?? "")", duration: 3)
            }
        }
        //MARK: - Warning note
        //When the App is reopened, you need to go through the logic of SDK initialization and login creation, ChatroomView addition, etc. again.
    }
    
    func onUserTokenWillExpired() {
        ChatroomUIKitClient.shared.refreshToken(token: ExampleRequiredConfig.chatToken)
    }
    
    func onUserLoginOtherDevice(device: String) {
        self.showToast(toast: "User login on other device", duration: 3)
    }
    
    func onUserUnmuted(roomId: String, userId: String, operatorId: String) {
        self.showToast(toast: "\(ChatroomContext.shared?.usersMap?[userId]?.nickName ?? userId) was unmuted.", duration: 3)
    }
    
    func onUserMuted(roomId: String, userId: String, operatorId: String) {
        self.showToast(toast: "\(ChatroomContext.shared?.usersMap?[userId]?.nickName ?? userId) was muted.", duration: 3)
    }
    
    func onUserJoined(roomId: String, user: ChatroomUIKit.UserInfoProtocol) {
        
    }
    
    func onUserBeKicked(roomId: String, reason: ChatroomUIKit.ChatroomBeKickedReason) {
        self.showToast(toast: "You was kicked.", duration: 3)
    }
    
    func onReceiveGlobalNotify(message: ChatroomUIKit.ChatMessage) {
        
    }
    
    func onAnnouncementUpdate(roomId: String, announcement: String) {
        //toast or alert notify participants.
        self.showToast(toast: "The chat room announcement is updated to \(announcement)", duration: 5)
    }
    
    func onErrorOccur(error: ChatroomUIKit.ChatError, type: ChatroomUIKit.RoomEventsError) {
        //you can catch error then handle.
        self.showToast(toast: "RoomEventsError occur \(error.errorDescription ?? "")", duration: 3)
    }
    
    
}
