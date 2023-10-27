//
//  Appearance.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

/// An object containing visual configurations for the whole application.
@objcMembers final public class Appearance: NSObject {
        
    /// You can change the width of a single option with ``PageContainerTitleBar`` in the popup container by setting the current property.
    public static var pageContainerTitleBarItemWidth: CGFloat = (ScreenWidth-32)/2.0
    
    /// The size of ``PageContainersDialogController`` constraints.
    public static var pageContainerConstraintsSize = CGSize(width: ScreenWidth, height: ScreenHeight*(3.0/5.0))
    
    /// The size of constraints of the gift page controller.``DialogContainerViewController``
    public static var giftDialogContainerConstraintsSize = CGSize(width: ScreenWidth, height: ScreenHeight/2.0)
    
    /// The size of alert container constraints.``AlertViewController``
    public static var alertContainerConstraintsSize = CGSize(width: ScreenWidth-40, height: ScreenHeight/3.0)
    
    /// The corner radius of the alert view.``AlertView``
    public static var alertCornerRadius: CornerRadius = .medium
    
    /// You can change the overall cell layout style of the barrage area by setting the current properties.``ChatBarrageCellStyle``
    public static var barrageCellStyle: ChatBarrageCellStyle = .all
    
    /// You can change the hue of the base color, and then change the thirteen UIColor objects of the related color series. The UI components that use the relevant color series in the chat room UIKit will also change accordingly. The default value is 203/360.0.
    public static var primaryHue: CGFloat = 203/360.0
    
    /// You can change the primary hue. The default value is 203/360.0.
    /// After the primary hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the chat room UIKit will also change accordingly.
    public static var secondaryHue: CGFloat = 155/360.0
    
    /// You can change the secondary hue. The default value is 155/360.0.
    /// After the secondary hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the chat room UIKit will also change accordingly.
    public static var errorHue: CGFloat = 350/360.0
    
    /// You can change the neutral hue. The default value is 203/360.0.
    /// After the neutral hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the chat room UIKit will also change accordingly.
    public static var neutralHue: CGFloat = 203/360.0
    
    /// You can change the neutral special hue. The default value is 220/360.0.
    /// After the neutral special hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the relevant color series in the chat room UIKit will also change accordingly.
    public static var neutralSpecialHue: CGFloat = 220/360.0
    
    /// Replace the emoji resource.``ChatEmojiConvertor``
    /// - Parameters:
    ///   Emoji map in key-value format, where the key can only be any of the following and value is a UIImage instance.
    ///   `["U+1F600", "U+1F604", "U+1F609", "U+1F62E", "U+1F92A", "U+1F60E", "U+1F971", "U+1F974", "U+263A", "U+1F641", "U+1F62D", "U+1F610", "U+1F607", "U+1F62C", "U+1F913", "U+1F633", "U+1F973", "U+1F620", "U+1F644", "U+1F910", "U+1F97A", "U+1F928", "U+1F62B", "U+1F637", "U+1F912", "U+1F631", "U+1F618", "U+1F60D", "U+1F922", "U+1F47F", "U+1F92C", "U+1F621", "U+1F44D", "U+1F44E", "U+1F44F", "U+1F64C", "U+1F91D", "U+1F64F", "U+2764", "U+1F494", "U+1F495", "U+1F4A9", "U+1F48B", "U+2600", "U+1F31C", "U+1F308", "U+2B50", "U+1F31F", "U+1F389", "U+1F490", "U+1F382", "U+1F381"]`
    public static var emojiMap: Dictionary<String,UIImage> = Dictionary<String,UIImage>()
    
    /// The mirror type of the language code of LanguageType.``LanguageType``
    public static var targetLanguage: LanguageType = .English
    
    /// ActionSheet data source of the message being long pressed.``ActionSheetItemProtocol``
    public static var defaultMessageActions: [ActionSheetItemProtocol] = [ActionSheetItem(title: "barrage_long_press_menu_translate".chatroom.localize, type: .normal,tag: "Translate"),ActionSheetItem(title: "barrage_long_press_menu_delete".chatroom.localize, type: .normal,tag: "Delete"),ActionSheetItem(title: "barrage_long_press_menu_mute".chatroom.localize, type: .normal,tag: "Mute"),ActionSheetItem(title: "barrage_long_press_menu_report".chatroom.localize, type: .destructive,tag: "Report")]
    
    /// ActionSheet data source of the member list cell on click ``...``.
    public static var defaultOperationUserActions: [ActionSheetItemProtocol] = [ActionSheetItem(title: "barrage_long_press_menu_mute".chatroom.localize, type: .normal,tag: "Mute"),ActionSheetItem(title: "participant_list_button_click_menu_remove".chatroom.localize, type: .destructive,tag: "Remove")]
    
    /// ActionSheet data source of the mute member list cell on click ``...``.
    public static var defaultOperationMuteUserActions: [ActionSheetItemProtocol] = [ActionSheetItem(title: "barrage_long_press_menu_unmute".chatroom.localize, type: .normal,tag: "unMute"),ActionSheetItem(title: "participant_list_button_click_menu_remove".chatroom.localize, type: .destructive,tag: "Remove")]
    
    /// ActionSheet row height.
    public static var actionSheetRowHeight: CGFloat = 56
    
    /// The placeholder image of the gift image view of the gift list cell ``GiftEntityCell``.
    public static var giftPlaceHolder: UIImage? = UIImage(named: "sendgift", in: .chatroomBundle, with: nil)
    
    /// The default image of the gift price of the gift list cell ``GiftEntityCell``.
    public static var giftPriceIcon: UIImage? = UIImage(named: "dollar", in: .chatroomBundle, with: nil)
    
    /// The placeholder image of the avatar image view of ``ChatBarrageCell``.
    public static var avatarPlaceHolder: UIImage? = UIImage(named: "default_avatar", in: .chatroomBundle, with: nil)
    
    /// The default icon of ``HorizontalTextCarousel``.
    public static var notifyMessageIcon: UIImage? = UIImage(named: "speaker", in: .chatroomBundle, with: nil)
    
    /// The origin point of the global notification message.
    public static var notifyMessageOriginPoint: CGPoint = CGPoint(x: 20, y: NavigationHeight+10)
        
    /// The placeholder image of the user-level image view of ``ChatBarrageCell``.
    public static var identityPlaceHolder: UIImage? = UIImage(named: "achievement", in: .chatroomBundle, with: nil)
    
    /// The height limit of the input box in ``ChatInputBar``.
    public static var maxInputHeight: CGFloat = 88
    
    /// The placeholder text in ``ChatInputBar``.
    public static var inputPlaceHolder = "Aa"
    
    /// The corner radius of ``ChatInputBar``.
    public static var inputBarCorner: CornerRadius = .medium
    
    /// The corner radius of the avatar image view of ``ChatInputBar``.
    public static var avatarRadius: CornerRadius = .large
    
    /// The default height of ``ChatBarrageCell``.
    public static var giftBarrageRowHeight: CGFloat = 58
    
    /// The label for message reporting types.
    public static var reportTags: [String] = ["violation_reason_1".chatroom.localize,"violation_reason_2".chatroom.localize,"violation_reason_3".chatroom.localize,"violation_reason_4".chatroom.localize,"violation_reason_5".chatroom.localize,"violation_reason_6".chatroom.localize,"violation_reason_7".chatroom.localize,"violation_reason_8".chatroom.localize,"violation_reason_9".chatroom.localize]
    
    /// The row height of the member cell.
    public static var participantsRowHeight: CGFloat = 62
    
    /// The number of chat room members that you expect to get on each page.
    public static var participantsPageSize: UInt = 10
    
    /// The number of  mute list page size.
    public static var mutePageSize: UInt = 200
}
