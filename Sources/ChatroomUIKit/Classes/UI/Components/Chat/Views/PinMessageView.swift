//
//  PinMessageView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 10/31/24.
//

import UIKit

let pinMessageViewWidth: CGFloat = ScreenWidth - 54 - 26 - 8

@objc public protocol IPinMessageViewDriver: AnyObject {
    func showNewMessage(message: ChatMessage, gift: (any GiftEntityProtocol)?)
    func removeMessage(message: ChatMessage)
    func showPinMessages(messages: [ChatMessage])
}

@objc public protocol PinMessageViewDelegate: AnyObject {
    func pinMessageViewDidLongPress(entity: ChatEntity)
}

open class PinMessageView: UIView,IPinMessageViewDriver {
    
    lazy private var eventHandlers: NSHashTable<PinMessageViewDelegate> = NSHashTable<PinMessageViewDelegate>.weakObjects()
    
    /// Add UI actions handler.
    /// - Parameter actionHandler: ``PinMessageViewDelegate``
    public func addActionHandler(actionHandler: PinMessageViewDelegate) {
        if self.eventHandlers.contains(actionHandler) {
            return
        }
        self.eventHandlers.add(actionHandler)
    }
    
    /// Remove UI action handler.
    /// - Parameter actionHandler: ``PinMessageViewDelegate``
    public func removeEventHandler(actionHandler: PinMessageViewDelegate) {
        self.eventHandlers.remove(actionHandler)
    }
    
    @MainActor var expandable: Bool = false {
        didSet {
            self.expandButton.isHidden = !self.expandable
        }
    }
    
    public var axisMaxYChanged: ((CGFloat)->Void)?
    
    private var showHeight: CGFloat = 0.0
    
    public private(set) var messages: [ChatEntity] = [ChatEntity]()
    
    public private(set) var entity = ChatEntity()
    
    public private(set) lazy var pinIdentity: ImageView = {
        ImageView(frame: .zero).backgroundColor(.clear).cornerRadius(Appearance.avatarRadius).image(UIImage(named: "pin", in: .chatroomBundle, with: nil))
    }()
    
    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: .zero).backgroundColor(.clear).cornerRadius(Appearance.avatarRadius)
    }()
    
    lazy var contentScroll: UITextView = {
        UITextView(frame: .zero).backgroundColor(.clear)
    }()
    
    public private(set) lazy var expandButton: UIButton = {
        UIButton(type: .custom).frame(.zero).backgroundColor(.clear).image(UIImage(named: "chevron_down", in: .chatroomBundle, with: nil), .normal).image(UIImage(named: "chevron_up", in: .chatroomBundle, with: nil), .selected).addTargetFor(self, action: #selector(expandAction), for: .touchUpInside)
    }()
    
    private var contentTrailingConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setup() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandAction)))
        self.addSubview(self.contentScroll)
        self.contentScroll.textContainerInset = .zero
        self.contentScroll.contentInset = .zero
        // 移除行片段的内边距
        self.contentScroll.textContainer.lineFragmentPadding = 0
        self.contentScroll.layoutManager.allowsNonContiguousLayout = false
        self.contentScroll.adjustsFontForContentSizeCategory = true
        self.contentScroll.bounces = false
        self.contentScroll.contentInsetAdjustmentBehavior = .never
        self.contentScroll.addSubViews([self.pinIdentity, self.avatar])
        self.pinIdentity.translatesAutoresizingMaskIntoConstraints = false
        self.avatar.translatesAutoresizingMaskIntoConstraints = false
        self.contentScroll.translatesAutoresizingMaskIntoConstraints = false
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGesture(gesture:)))
        self.contentScroll.bringSubviewToFront(self.pinIdentity)
        self.contentScroll.bringSubviewToFront(self.avatar)
        self.addGestureRecognizer(longGesture)
        self.addSubview(self.expandButton)
//        self.expandButton.isHidden = true
        self.expandButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            self.contentScroll.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 8),
            self.contentScroll.topAnchor.constraint(equalTo: self.topAnchor,constant: 4),
            self.contentScroll.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -4),
            
            self.pinIdentity.leadingAnchor.constraint(equalTo: self.contentScroll.leadingAnchor,constant: 2),
            self.pinIdentity.topAnchor.constraint(equalTo: self.contentScroll.topAnchor,constant: 1),
            self.pinIdentity.widthAnchor.constraint(equalToConstant: 18),
            self.pinIdentity.heightAnchor.constraint(equalToConstant: 18),
            
            self.avatar.leadingAnchor.constraint(equalTo: self.pinIdentity.trailingAnchor,constant: 3),
            self.avatar.topAnchor.constraint(equalTo: self.contentScroll.topAnchor,constant: 1),
            self.avatar.widthAnchor.constraint(equalToConstant: 18),
            self.avatar.heightAnchor.constraint(equalToConstant: 18),
            
            self.expandButton.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -8),
            self.expandButton.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -7),
            self.expandButton.widthAnchor.constraint(equalToConstant: 12),
            self.expandButton.heightAnchor.constraint(equalToConstant: 12),
            
        ])
        self.contentTrailingConstraint =
        self.contentScroll.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -26)
        self.contentTrailingConstraint?.isActive = true
        self.contentScroll.textContainer.lineBreakMode = self.expandButton.isSelected ? .byWordWrapping : .byTruncatingTail
        self.avatar.cornerRadius(Appearance.avatarRadius)
        self.contentScroll.isEditable = false
        self.contentScroll.isSelectable = false
    }
    
    @objc func longGesture(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began,ChatroomContext.shared?.owner ?? false {
            for handler in self.eventHandlers.allObjects {
                handler.pinMessageViewDidLongPress(entity: self.entity)
            }
        }
    }
    
    @objc func expandAction() {
        if !self.expandable {
            return
        }
        self.expandButton.isSelected.toggle()
        self.contentScroll.textContainer.lineBreakMode = self.expandButton.isSelected ? .byWordWrapping : .byTruncatingTail
        var itemWidth:CGFloat = 0
        var itemHeight:CGFloat = 0
        if let message = self.messages.last {
            itemWidth = message.pinWidth
            itemHeight = message.pinHeight
            if !self.expandButton.isSelected {
                self.contentScroll.isScrollEnabled = false
                if itemHeight > 44 {
                    itemWidth += 30
                    self.expandable = true
                    itemHeight = 48
                } else {
                    self.expandable = false
                }
            } else {
                if itemHeight > 98 {
                    self.contentScroll.isScrollEnabled = true
                    itemHeight = 98
                    self.contentScroll.indicatorStyle = .white
                } else {
                    self.contentScroll.isScrollEnabled = false
                    self.contentScroll.contentSize = CGSize(width: itemWidth, height: itemHeight)
                }
                if itemHeight > 44 {
                    itemWidth += 32
                }
            }
        }
        UIView.animate(withDuration: 0.22) {
            self.isHidden = false
            self.frame = CGRect(x: self.frame.origin.x, y: NavigationHeight+20, width: itemWidth, height: itemHeight)
            self.axisMaxYChanged?(self.frame.height+NavigationHeight+20)
        } completion: { _ in
        }
    }
    
    open func convertMessageToRender(message: ChatMessage,gift: GiftEntityProtocol?) -> ChatEntity {
        let entity = ComponentsRegister.shared.MessageEntity.init()
        entity.message = message
        entity.gift = gift
        entity.pinAttributeText = entity.pinAttributeText
        entity.pinWidth = entity.pinWidth
        entity.pinHeight = entity.pinHeight
        return entity
    }
    
    
    
    open func showNewMessage(message: ChatMessage, gift: (any GiftEntityProtocol)?) {
        self.expandButton.isSelected = false
        self.messages.append(self.convertMessageToRender(message: message, gift: gift))
        var itemWidth:CGFloat = 0
        var itemHeight:CGFloat = 0
        if let message = self.messages.last {
            self.entity = message
            itemWidth = message.pinWidth
            itemHeight = message.pinHeight
            if itemHeight > 98 {
                itemHeight = 98
            }
            if !self.expandButton.isSelected {
                if itemHeight > 44 {
                    itemWidth += 32
                    self.expandable = true
                    itemHeight = 46
                    self.contentTrailingConstraint.constant = -26
                    
                } else {
                    self.contentTrailingConstraint.constant = -8
                    self.expandable = false
                    if Int(itemHeight) <= 26 {
                        itemWidth += 16
                    }
                }
                
            }
            self.avatar.image(with: message.message.user?.avatarURL ?? "", placeHolder: Appearance.avatarPlaceHolder)
            self.avatar.cornerRadius(9)
            self.contentScroll.textContainer.lineBreakMode = self.expandButton.isSelected ? .byWordWrapping : .byTruncatingTail
            self.contentScroll.attributedText = message.pinAttributeText
        }
        self.isHidden = false
        UIView.animate(withDuration: 0.22,delay: 0.2) {
            self.frame = CGRect(x: self.frame.origin.x, y: NavigationHeight+20, width: itemWidth, height: itemHeight)
            self.axisMaxYChanged?(self.frame.height+NavigationHeight+20)
        } completion: { _ in
        }
    }
    
    @objc open func pinParaStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 48
        paragraphStyle.lineHeightMultiple = 1.08
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineSpacing = 0
        return paragraphStyle
    }
    
    public func showPinMessages(messages: [ChatMessage]) {
        self.messages.removeAll()
        for message in messages.reversed() {
            self.messages.append(self.convertMessageToRender(message: message, gift: nil))
        }
        if let first = self.messages.last {
            self.showNewMessage(message: first.message, gift: nil)
        }
    }
    
    open func removeMessage(message: ChatMessage) {
        self.messages.removeAll { $0.message.messageId == message.messageId }
        if self.messages.count <= 0 {
            UIView.animate(withDuration: 0.22) {
                self.frame = CGRect(x: self.frame.origin.x, y: NavigationHeight+20, width: 0, height: 0)
                self.axisMaxYChanged?(self.frame.height+NavigationHeight+20)
            } completion: { _ in
                self.isHidden = true
            }
        } else {
            if let lastMessage = self.messages.last {
                self.showNewMessage(message: lastMessage.message, gift: lastMessage.gift)
            }
        }
    }
}

