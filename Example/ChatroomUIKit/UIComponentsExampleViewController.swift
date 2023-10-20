//
//  ViewController.swift
//  ChatroomUIKit
//
//  Created by zjc19891106 on 08/30/2023.
//  Copyright (c) 2023 zjc19891106. All rights reserved.
//

import UIKit
import ChatroomUIKit

final class UIComponentsExampleViewController: UIViewController {
    
    var style: ThemeStyle = .light
    
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage(named: "background_light"))
    }()
    
    lazy var giftBarrages: GiftsBarrageList = {
        GiftsBarrageList(frame: CGRect(x: 10, y: 400, width: self.view.frame.width-100, height: Appearance.giftBarrageRowHeight*2),source:nil)
    }()
    
    lazy var barrageList: ChatBarrageList = {
        ChatBarrageList(frame: CGRect(x: 0, y: 500, width: self.view.frame.width-50, height: 200))
    }()
    
    lazy var bottomBar: ChatBottomFunctionBar = {
        ChatBottomFunctionBar(frame: CGRect(x: 0, y: self.view.frame.height-54-BottomBarHeight, width: self.view.frame.width, height: 54), datas: self.bottomBarDatas())
    }()
    
    lazy var inputBar: ChatInputBar = {
        ChatInputBar(frame: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: 52),text: nil,placeHolder: "Input words.")
    }()
    
    lazy var gift1: GiftsViewController = {
        GiftsViewController(gifts: self.gifts())
    }()
    
    lazy var gift2: GiftsViewController = {
        GiftsViewController(gifts: self.gifts())
    }()
    
    /// Global notify container
    lazy var carouselTextView: HorizontalTextCarousel = {
        HorizontalTextCarousel(originPoint: CGPoint(x: 20, y: 85), width: self.view.frame.width-40, font: .systemFont(ofSize: 16, weight: .semibold), textColor: UIColor.theme.neutralColor98).cornerRadius(.large).backgroundColor(UIColor.theme.primaryColor6)
    }()
    
    /// Switch theme
    private lazy var modeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Light","Dark"])
        segment.frame = CGRect(x: 100, y: 170, width: 96, height: 46)
        segment.setImage(UIImage(named: "sun"), forSegmentAt: 0)
        segment.setImage(UIImage(named: "moon"), forSegmentAt: 1)
        segment.tintColor = UIColor(0x009EFF)
        segment.tag = 12
        segment.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        segment.selectedSegmentIndex = self.style == .light ? 0:1
        
        segment.selectedSegmentTintColor = UIColor(0x009EFF)
        segment.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 18, weight: .medium)], for: .selected)
        segment.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16, weight: .regular)], for: .normal)
        segment.addTarget(self, action: #selector(switchTheme(sender:)), for: .valueChanged)
        return segment
    }()
    
    /// Switch show or hidden global notify icon.
    private lazy var speakerSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Light","Dark"])
        segment.frame = CGRect(x: 100, y: self.modeSegment.frame.maxY+5, width: 96, height: 46)
        segment.setImage(UIImage(systemName: "speaker.wave.3")?.withTintColor(.white), forSegmentAt: 0)
        segment.setImage(UIImage(systemName: "speaker.slash")?.withTintColor(.white), forSegmentAt: 1)
        segment.tintColor = UIColor(0x009EFF)
        segment.tag = 12
        segment.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        segment.selectedSegmentIndex = self.carouselTextView.voiceIcon.isHidden ? 1:0
        
        segment.selectedSegmentTintColor = UIColor(0x009EFF)
        segment.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 18, weight: .medium)], for: .selected)
        segment.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16, weight: .regular)], for: .normal)
        segment.addTarget(self, action: #selector(switchSpeakerIcon(sender:)), for: .valueChanged)
        return segment
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let user = User()
        user.nickName = "Jack"
        user.avatarURL = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_1.png"
        user.identify = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_2.png"
        user.userId = "12323123123"
        ChatroomContext.shared?.currentUser = user
        self.view.addSubview(self.background)
        self.view.addSubview(self.giftBarrages)
        self.view.addSubview(self.barrageList)
        self.view.addSubview(self.bottomBar)
        self.view.addSubview(self.inputBar)
        self.view.addSubview(self.carouselTextView)
        self.view.addSubview(self.modeSegment)
        self.view.addSubview(self.speakerSegment)
        
        self.bottomBar.addActionHandler(actionHandler: self)
        self.inputBar.sendClosure = { [weak self] in
            guard let `self` = self else { return }
            self.barrageList.showNewMessage(message: self.startMessage($0),gift: nil)
        }
        
        //View global notify
        let button = UIButton(type: .custom).frame(CGRect(x: 100, y: 140, width: 150, height: 20)).textColor(.white, .normal).backgroundColor(UIColor.theme.primaryColor6).cornerRadius(.extraSmall).title("Add Global Notify", .normal).addTargetFor(self, action: #selector(addCarouselTask), for: .touchUpInside)
        self.view.addSubview(button)
        self.carouselTextView.alpha = 0
        
        // Switch ChatBarrageCellStyle
        let switchCellStyle = UIButton(type: .custom).frame(CGRect(x: 100, y: self.speakerSegment.frame.maxY+5, width: 150, height: 40)).textColor(.white, .normal).backgroundColor(UIColor.theme.primaryColor6).cornerRadius(.small).title(".all", .normal).title("Long Presse Switch", .normal).font(.systemFont(ofSize: 16, weight: .semibold))
        switchCellStyle.addInteraction(UIContextMenuInteraction(delegate: self))
        self.view.addSubview(switchCellStyle)
        
        
    }

    
}

extension UIComponentsExampleViewController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            let action1 = UIAction(title: ".all", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.barrageCellStyle = .all
                self.barrageList.messages?.removeAll()
                self.barrageList.chatView.reloadData()
            }
            let action2 = UIAction(title: ".hideTime", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.barrageCellStyle = .hideTime
                self.barrageList.messages?.removeAll()
                self.barrageList.chatView.reloadData()
            }
            let action3 = UIAction(title: ".hideUserIdentity", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.barrageCellStyle = .hideUserIdentity
                self.barrageList.messages?.removeAll()
                self.barrageList.chatView.reloadData()
            }
            let action4 = UIAction(title: ".hideAvatar", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.barrageCellStyle = .hideAvatar
                self.barrageList.messages?.removeAll()
                self.barrageList.chatView.reloadData()
            }
            let action5 = UIAction(title: ".hideTimeAndUserIdentity", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.barrageCellStyle = .hideTimeAndUserIdentity
                self.barrageList.messages?.removeAll()
                self.barrageList.chatView.reloadData()
            }
            let action6 = UIAction(title: ".hideTimeAndAvatar", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.barrageCellStyle = .hideTimeAndAvatar
                self.barrageList.messages?.removeAll()
                self.barrageList.chatView.reloadData()
            }
            let action7 = UIAction(title: ".hideUserIdentityAndAvatar", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.barrageCellStyle = .hideUserIdentityAndAvatar
                self.barrageList.messages?.removeAll()
                self.barrageList.chatView.reloadData()
            }
            let action8 = UIAction(title: ".hideTimeAndUserIdentityAndAvatar", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.barrageCellStyle = .hideTimeAndUserIdentityAndAvatar
                self.barrageList.messages?.removeAll()
                self.barrageList.chatView.reloadData()
            }
            let menu = UIMenu(title: "", children: [action1, action2, action3, action4, action5, action6,action7, action8])
            
            return menu
        }
    }
}

extension UIComponentsExampleViewController: ChatBottomFunctionBarActionEvents,GiftsViewActionEventsDelegate {
    func onGiftSendClick(item: ChatroomUIKit.GiftEntityProtocol) {
        let gift = item
        gift.sendUser = ChatroomContext.shared?.currentUser
        self.giftBarrages.gifts.append(item)
    }
    
    func onGiftSelected(item: ChatroomUIKit.GiftEntityProtocol) {
        
    }
    
    func onBottomItemClicked(item: ChatroomUIKit.ChatBottomItemProtocol) {
        switch item.type {
        case 2:
            DialogManager.shared.showGiftsDialog(titles: ["Gifts","1231232"], gifts: [self.gift1,self.gift2])
            self.gift1.giftsView.addActionHandler(actionHandler: self)
        default:
            break
        }
    }
    
    func onKeyboardWillWakeup() {
        self.inputBar.show()
    }
    
    
}

extension UIComponentsExampleViewController {
    
    @objc func addCarouselTask() {
        self.carouselTextView.addTask(text: ["123123adadsasjdaklsdjaskldjakdjakldsjkadjkasldjalksjdlkjasdklsajdl","99999999999999999999999999999999","66666666666666666666666666666"].randomElement()!)
    }
    
    @objc func switchTheme(sender: UISegmentedControl) {
        self.style = ThemeStyle(rawValue: UInt(sender.selectedSegmentIndex)) ?? .light
        Theme.switchTheme(style: self.style)
        self.background.image = Theme.style == .dark ? UIImage(named: "background_dark"):UIImage(named: "background_light")
//        Theme.switchHues()
    }
    
    @objc func switchSpeakerIcon(sender: UISegmentedControl) {
        self.carouselTextView.voiceIcon.isHidden = sender.selectedSegmentIndex == 1
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
    
    @objc func startMessage(_ text: String?) -> ChatMessage {
        let user = ChatroomContext.shared?.currentUser as? User
        return ChatMessage(conversationID: "test", from: "12323123123", to: "test",body: ChatTextMessageBody(text: text == nil ? "Welcome":text), ext: user?.kj.JSONObject())
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

final class ChatBottomItem:NSObject, ChatBottomItemProtocol {
    
    var action: ((ChatroomUIKit.ChatBottomItemProtocol) -> Void)?
    
    var showRedDot: Bool = false
    
    var selected: Bool = false
    
    var selectedImage: UIImage?
    
    var normalImage: UIImage?
    
    var type: Int = 0
   
}


