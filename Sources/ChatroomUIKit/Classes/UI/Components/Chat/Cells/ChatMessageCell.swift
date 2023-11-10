//
//  ChatMessageCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/5.
//

import UIKit


/**
 A UITableViewCell subclass used to display chat messages as a content display style of the cell.
 
 This cell contains a container view, a time label, a user identity image view, an avatar image view, and a content label. The appearance of these subviews can be customized by setting the ``ChatMessageDisplayContentStyle`` of the cell.
 
 Use the ``refresh(chat:)`` method to update the content of the cell with a ``ChatEntity`` object.
 */
@objcMembers open class ChatMessageCell: UITableViewCell {
    
    public private(set) var style: ChatMessageDisplayContentStyle = Appearance.messageDisplayStyle
    
    lazy var container: UIView = {
        UIView(frame: CGRect(x: 15, y: 6, width: self.contentView.frame.width - 30, height: self.frame.height - 6)).backgroundColor( UIColor.theme.barrageLightColor2).cornerRadius(.small)
    }()
    
    lazy var time: UILabel = {
        UILabel(frame: CGRect(x: 8, y: 10, width: 40, height: 18)).font(UIFont.theme.bodyMedium).textColor(UIColor.theme.secondaryColor8).textAlignment(.center).backgroundColor(.clear)
    }()
    
    lazy var identity: ImageView = {
        var originX = 6
        switch self.style {
        case .all,.hideAvatar:
            originX += Int(self.time.frame.maxX)
        default:
            originX = originX
            break
        }
        return ImageView(frame: CGRect(x: originX, y: 10, width: 18, height: 18)).backgroundColor(.clear).cornerRadius(Appearance.avatarRadius)
    }()
    
    lazy var avatar: ImageView = {
        var originX = 6
        switch self.style {
        case .all,.hideTime:
            originX += Int(self.identity.frame.maxX)
        case .hideUserIdentity:
            originX += Int(self.time.frame.maxX)
        case .hideTimeAndUserIdentity:
            originX = originX
        default:
            break
        }
        return ImageView(frame: CGRect(x: originX, y: 10, width: 18, height: 18)).backgroundColor(.clear).cornerRadius(Appearance.avatarRadius)
    }()
    
    lazy var content: UILabel = {
        return UILabel(frame: CGRect(x: 10, y: 7, width: self.container.frame.width - 20, height: self.container.frame.height - 18)).backgroundColor(.clear).numberOfLines(0).lineBreakMode(.byWordWrapping)
    }()
    
    lazy var giftIcon: ImageView = {
        ImageView(frame: CGRect(x: self.content.frame.width-22, y: self.content.frame.height-10, width: 18, height: 18)).backgroundColor(.clear)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    /// ChatBarrageCell init method
    /// - Parameters:
    ///   - displayStyle: ``ChatMessageDisplayContentStyle``
    ///   - reuseIdentifier: reuse identifier
    @objc required public convenience init(displayStyle: ChatMessageDisplayContentStyle, reuseIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.style = displayStyle
        self.contentView.addSubview(self.container)
        switch displayStyle {
        case .all:
            self.container.addSubViews([self.time,self.identity,self.avatar,self.content])
        case .hideTime:
            self.container.addSubViews([self.identity,self.avatar,self.content])
        case .hideUserIdentity:
            self.container.addSubViews([self.time,self.avatar,self.content])
        case .hideAvatar:
            self.container.addSubViews([self.time,self.identity,self.content])
        case .hideTimeAndUserIdentity:
            self.container.addSubViews([self.avatar,self.content])
        case .hideTimeAndAvatar:
            self.container.addSubViews([self.identity,self.content])
        case .hideUserIdentityAndAvatar:
            self.container.addSubViews([self.time,self.content])
        case .hideTimeAndUserIdentityAndAvatar:
            self.container.addSubview(self.content)
        default:
            break
        }
        self.container.addSubview(self.giftIcon)
        self.giftIcon.isHidden = true
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Refresh the entity that renders the chat barrage, which contains height, width and rich text cache.
    /// - Parameter chat: ``ChatEntity``
    @objc public func refresh(chat: ChatEntity) {
        self.time.text = chat.showTime
        self.identity.image(with: chat.message.user?.identity ?? "", placeHolder: Appearance.identityPlaceHolder)
        self.avatar.image(with: chat.message.user?.avatarURL ?? "", placeHolder: Appearance.avatarPlaceHolder)
        self.content.attributedText = chat.attributeText
        self.container.frame = CGRect(x: 15, y: 6, width: chat.width + 30, height: chat.height - 6)
        self.content.preferredMaxLayoutWidth =  self.container.frame.width - 24
        self.content.frame = CGRect(x: self.content.frame.minX, y: self.content.frame.minY, width:  self.container.frame.width - 24, height:  self.container.frame.height - 16)
        self.giftIcon.frame = CGRect(x: self.content.frame.width-16, y: (self.container.frame.height-18)/2.0, width: 18, height: 18)
        self.giftIcon.isHidden = chat.gift == nil
        if let item = chat.gift {
            self.giftIcon.image(with: item.giftIcon, placeHolder: Appearance.giftPlaceHolder)
        }
    }
}


extension ChatMessageCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.container.backgroundColor(style == .dark ? UIColor.theme.barrageLightColor2:UIColor.theme.barrageDarkColor1)
    }
    
}


fileprivate let gift_tail_indent: CGFloat = 26

/// An enumeration that represents the different styles of a chat  cell.Time,level and avatar can be hidden
@objc public enum ChatMessageDisplayContentStyle: UInt {
    case all = 1
    case hideTime
    case hideAvatar
    case hideUserIdentity
    case hideTimeAndAvatar
    case hideTimeAndUserIdentity
    case hideUserIdentityAndAvatar
    case hideTimeAndUserIdentityAndAvatar
}

/// A class that represents a chat entity, which includes a message, a timestamp, attributed text, height, and width.
@objc open class ChatEntity: NSObject {
    
    /// The message associated with the chat entity.
    lazy public var message: ChatMessage = ChatMessage()
    
    /// The time at which the message was sent, formatted as "HH:mm".
    lazy public var showTime: String = {
        let date = Date(timeIntervalSince1970: Double(self.message.timestamp)/1000)
        return date.chatroom.dateString("HH:mm")
    }()
    
    /// The attributed text of the message, including the user's nickname, message text, and emojis.
    lazy public var attributeText: NSAttributedString = self.convertAttribute()
        
    /// The height of the chat entity, calculated based on the attributed text and the width of the chat view.
    lazy public var height: CGFloat =  UILabel().numberOfLines(0).attributedText(self.attributeText).sizeThatFits(CGSize(width: chatViewWidth - 54, height: 9999)).height + 26
    
    /// The width of the chat entity, calculated based on the attributed text and the width of the chat view.
    lazy public var width: CGFloat = (self.gift == nil ? UILabel().numberOfLines(0).attributedText(self.attributeText).sizeThatFits(CGSize(width: chatViewWidth - 54, height: 18)).width:self.attributeText.size().width+self.firstLineHeadIndent())+(self.gift != nil ? gift_tail_indent:0)
    
    /// Chat cell display gift info.Need to set it.``GiftEntityProtocol``
    lazy public var gift: GiftEntityProtocol? = nil
    
    /// Converts the message text into an attributed string, including the user's nickname, message text, and emojis.
    func convertAttribute() -> NSAttributedString {
        let userId = self.message.user?.userId ?? ""
        var text = NSMutableAttributedString {
            AttributedText((self.message.user?.nickName ?? userId)).foregroundColor(Color.theme.primaryColor8).font(UIFont.theme.labelMedium).paragraphStyle(self.paragraphStyle())
        }
        if self.message.body.type == .custom,let body = self.message.body as? ChatCustomMessageBody {
            switch body.event {
            case chatroom_UIKit_gift:
                if let item = self.gift {
                    text.append(NSMutableAttributedString {
                        AttributedText(" "+item.giftName+" "+"× \(item.giftCount)").foregroundColor(Color.theme.neutralColor98).font(UIFont.theme.labelMedium).paragraphStyle(self.paragraphStyle())
                    })
                }
            case chatroom_UIKit_user_join:
                text.append(NSMutableAttributedString {
                    AttributedText(" "+"Joined".chatroom.localize).foregroundColor(Color.theme.secondaryColor7).font(UIFont.theme.labelMedium).paragraphStyle(self.paragraphStyle())
                })
            default:
                break
            }
            
        } else {
            if self.message.translation != nil,let translation = message.translation {
                text.append(NSAttributedString {
                    AttributedText(" : "+translation).foregroundColor(Color.theme.neutralColor98).font(UIFont.theme.bodyMedium).paragraphStyle(self.paragraphStyle())
                })
            } else {
                text.append(NSAttributedString {
                    AttributedText(" : "+self.message.text).foregroundColor(Color.theme.neutralColor98).font(UIFont.theme.bodyMedium).paragraphStyle(self.paragraphStyle())
                })
            }
            let string = text.string as NSString
            for symbol in ChatEmojiConvertor.shared.emojis {
                if string.range(of: symbol).location != NSNotFound {
                    let ranges = text.string.chatroom.rangesOfString(symbol)
                    text = ChatEmojiConvertor.shared.convertEmoji(input: text, ranges: ranges, symbol: symbol)
                    text.addAttribute(.paragraphStyle, value: self.paragraphStyle(), range: NSMakeRange(0, text.length))
                    text.addAttribute(.font, value: UIFont.theme.bodyMedium, range: NSMakeRange(0, text.length))
                }
            }
        }
        return text
    }
    
    /// Returns a paragraph style object with the first line head indent set based on the appearance of the chat cell.
    func paragraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = self.firstLineHeadIndent()
        paragraphStyle.lineHeightMultiple = 1.08
        paragraphStyle.alignment = .natural
        if self.gift != nil {
            paragraphStyle.tailIndent = self.lastLineHeadIndent()
        } else {
            paragraphStyle.tailIndent = 0
        }
        return paragraphStyle
    }
    
    /// Returns the distance of the first line head indent based on the appearance of the chat cell.
    func firstLineHeadIndent() -> CGFloat {
        var distance:CGFloat = 0
        switch Appearance.messageDisplayStyle {
        case .all: distance = 90
        case .hideTime: distance = 50
        case .hideUserIdentityAndAvatar: distance = 46
        case .hideTimeAndUserIdentityAndAvatar: distance = 8
        case .hideAvatar,.hideUserIdentity: distance = 68
        case .hideTimeAndUserIdentity,.hideTimeAndAvatar: distance = 24
        }
        return distance
    }
    
    /// Returns the distance of the last line head indent based on the appearance of the chat cell.
    func lastLineHeadIndent() -> CGFloat { gift_tail_indent }
}

public extension ChatMessage {
    
    /// ``UserInfoProtocol``
    var user: UserInfoProtocol? {
        ChatroomContext.shared?.usersMap?[self.from]
    }
    
    /// Content of the text message.
    var text: String {
        (self.body as? ChatTextMessageBody)?.text ?? ""
    }
    
    /// Translation of the text message.
    var translation: String? {
        (self.body as? ChatTextMessageBody)?.translations?[Appearance.messageTranslationLanguage.rawValue]
    }
}
