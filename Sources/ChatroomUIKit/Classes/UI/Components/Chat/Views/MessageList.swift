//
//  MessageList.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/5.
//

import UIKit

var chatViewWidth: CGFloat = 0

/// MessageList's Drive.
@objc public protocol IMessageListDrive: NSObjectProtocol {
    
    /// When you receive or will send a message.
    /// - Parameter message: ``ChatMessage``
    ///   - gift: ``GiftEntityProtocol``
    @objc(showWithNewMessage:gift:)
    func showNewMessage(message: ChatMessage,gift: GiftEntityProtocol?)
    
    /// When you want modify or translate a message.
    /// - Parameter message: ``ChatMessage``
    @objc(refreshWithMessage:)
    func refreshMessage(message: ChatMessage)
    
    /// When you want delete message.
    /// - Parameter message: ``ChatMessage``
    @objc(removeWithMessage:)
    func removeMessage(message: ChatMessage)
    
    /// Clean data source.
    func cleanMessages()
}

/// MessageList action events handler.
@objc public protocol MessageListActionEventsHandler: NSObjectProtocol {
    
    /// The method called on message  long pressed.
    /// - Parameter message: ``ChatMessage``
    func onMessageLongPressed(message: ChatMessage)
    
    /// The method called on message  clicked.
    /// - Parameter message: ``ChatMessage``
    func onMessageClicked(message: ChatMessage)
}

@objcMembers open class MessageList: UIView {
    
    lazy private var eventHandlers: NSHashTable<MessageListActionEventsHandler> = NSHashTable<MessageListActionEventsHandler>.weakObjects()
    
    /// Add UI actions handler.
    /// - Parameter actionHandler: ``MessageListActionEventsHandler``
    public func addActionHandler(actionHandler: MessageListActionEventsHandler) {
        if self.eventHandlers.contains(actionHandler) {
            return
        }
        self.eventHandlers.add(actionHandler)
    }
    
    /// Remove UI action handler.
    /// - Parameter actionHandler: ``MessageListActionEventsHandler``
    public func removeEventHandler(actionHandler: MessageListActionEventsHandler) {
        self.eventHandlers.remove(actionHandler)
    }

    private var lastOffsetY = CGFloat(0)

    private var cellOffset = CGFloat(0)
    
    private var hover = false
    
    private var moreMessagesCount = 0  {
        willSet {
            self.moreMessages.isHidden = newValue <= 0
        }
    }

    public var messages: [ChatEntity]? = [ChatEntity]()

    public lazy var chatView: UITableView = {
        UITableView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), style: .plain).delegate(self).dataSource(self).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).showsVerticalScrollIndicator(false).isUserInteractionEnabled(true)
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        CAGradientLayer().startPoint(CGPoint(x: 0, y: 0)).endPoint(CGPoint(x: 0, y: 0.1)).colors([UIColor.clear.withAlphaComponent(0).cgColor, UIColor.clear.withAlphaComponent(1).cgColor]).locations([NSNumber(0), NSNumber(1)]).rasterizationScale(UIScreen.main.scale).frame(self.blurView.frame)
    }()

    private lazy var blurView: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: chatViewWidth, height: self.frame.height)).backgroundColor(.clear).isUserInteractionEnabled(true)
    }()
    
    lazy var moreMessages: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 20, y: self.chatView.frame.maxY-28, width: 180, height: 26)).cornerRadius(.large).font(UIFont.theme.labelMedium).title("    \(self.moreMessagesCount) "+"new messages".chatroom.localize, .normal).addTargetFor(self, action: #selector(scrollTableViewToBottom), for: .touchUpInside)
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        chatViewWidth = frame.width
        self.addSubViews([self.blurView])
        self.blurView.layer.mask = self.gradientLayer
        self.blurView.addSubview(self.chatView)
        self.chatView.addSubview(self.moreMessages)
        self.moreMessages.isHidden = true
        self.chatView.bounces = false
        self.chatView.allowsSelection = false
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGesture(gesture:)))
        longGesture.minimumPressDuration = 0.5
        self.chatView.addGestureRecognizer(longGesture)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        consoleLogInfo("deinit \(self.swiftClassName ?? "")", type: .debug)
    }

}

extension MessageList:UITableViewDelegate, UITableViewDataSource {
    
    @objc public func scrollTableViewToBottom() {
        if self.messages?.count ?? 0 > 1 {
            self.chatView.reloadData()
            let lastIndexPath = IndexPath(row: self.chatView.numberOfRows(inSection: 0) - 1, section: 0)
            if lastIndexPath.row >= 0 {
                self.chatView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messages?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.messages?[safe: indexPath.row]?.height ?? 60
        return height
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatsCell, reuseIdentifier: "ChatBarragesCell")
        if cell == nil {
            cell = ComponentsRegister.shared.ChatsCell.init(displayStyle: Appearance.messageDisplayStyle, reuseIdentifier: "ChatBarrageCell")
        }
        guard let entity = self.messages?[safe: indexPath.row] else { return ChatMessageCell() }
        cell?.refresh(chat: entity)
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.contentOffset.y - self.lastOffsetY < 0 {
            self.cellOffset -= cell.frame.height
        } else {
            self.cellOffset += cell.frame.height
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        for handler in self.eventHandlers.allObjects {
            if let message = self.messages?[safe: indexPath.row]?.message {
                handler.onMessageClicked(message: message)
            }
        }
    }
        
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.hover = true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = self.chatView.indexPathForRow(at: scrollView.contentOffset) ?? IndexPath(row: 0, section: 0)
        let cell = self.chatView.cellForRow(at: indexPath)
        let maxAlphaOffset = cell?.frame.height ?? 40
        let offsetY = scrollView.contentOffset.y
        let alpha = (maxAlphaOffset - (offsetY - self.cellOffset)) / maxAlphaOffset
        if offsetY - lastOffsetY > 0 {
            UIView.animate(withDuration: 0.3) {
                cell?.alpha = alpha
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                cell?.alpha = 1
            }
        }
        self.lastOffsetY = offsetY
        if self.lastOffsetY == 0 {
            self.cellOffset = 0
        }
        let contentHeight = scrollView.contentSize.height
        let tableHeight = scrollView.bounds.size.height
        
        if offsetY > contentHeight - tableHeight {
            self.hover = false
        }
        
        if indexPath.row - self.moreMessagesCount == 0 {
            self.moreMessagesCount = 0
        }
    }
    
    @objc func longGesture(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let touchPoint = gesture.location(in: self.chatView)
            if let indexPath = self.chatView.indexPathForRow(at: touchPoint),let _ = self.chatView.cellForRow(at: indexPath) as? ChatMessageCell {
                for handler in self.eventHandlers.allObjects {
                    if let message = self.messages?[safe: indexPath.row]?.message {
                        handler.onMessageLongPressed(message: message)
                    }
                }
            }
        }
    }

}

extension MessageList: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.moreMessages.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.moreMessages.textColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, .normal)
        self.moreMessages.image(UIImage(named: "more_messages", in: .chatroomBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5), .normal)
    }
}

extension MessageList: IMessageListDrive {
    public func cleanMessages() {
        self.messages?.removeAll()
        self.chatView.reloadData()
    }
    
    public func removeMessage(message: ChatMessage) {
        self.messages?.removeAll(where: { $0.message.messageId == message.messageId })
        self.chatView.reloadData()
    }
    
    public func refreshMessage(message: ChatMessage) {
        if let index = self.messages?.lastIndex(where: { $0.message.messageId == message.messageId }) {
            let entity = self.messages?[safe: index]
            self.messages?[index] = self.convertMessageToRender(message: message, gift: entity?.gift)
            self.chatView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
    
    public func showNewMessage(message: ChatMessage,gift: GiftEntityProtocol?) {
        self.messages?.append(self.convertMessageToRender(message: message, gift: gift))
        if message.from == ChatClient.shared().currentUsername {
            self.moreMessagesCount = 0
            self.chatView.reloadDataSafe()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.scrollTableViewToBottom()
            }
        } else {
            if !self.hover {
                self.moreMessagesCount = 0
                self.chatView.reloadDataSafe()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.scrollTableViewToBottom()
                }
            } else {
                self.moreMessagesCount += 1
                var count = "\(self.moreMessagesCount)"
                if self.moreMessagesCount > 99 {
                    count = "99+ "
                }
                self.moreMessages.setTitle("  \(count) "+"new messages".chatroom.localize, for: .normal)
            }
        }
    }
    
    private func convertMessageToRender(message: ChatMessage,gift: GiftEntityProtocol?) -> ChatEntity {
        let entity = ChatEntity()
        entity.message = message
        entity.gift = gift
        entity.attributeText = entity.attributeText
        entity.width = entity.width
        entity.height = entity.height
        return entity
    }
}

extension UITableView {
    /// Dequeues a UICollectionView Cell with a generic type and indexPath
    /// - Parameters:
    ///   - type: A generic cell type
    ///   - indexPath: The indexPath of the row in the UICollectionView
    /// - Returns: A Cell from the type passed through
    func dequeueReusableCell<Cell: UITableViewCell>(with type: Cell.Type, reuseIdentifier: String) -> Cell? {
        dequeueReusableCell(withIdentifier: reuseIdentifier) as? Cell
    }
    
    @objc public func reloadDataSafe() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
