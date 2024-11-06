//
//  PinMessageCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 10/31/24.
//

import UIKit

@objcMembers open class PinMessageCell: UITableViewCell {
//    
//    
//    
//    required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.contentView.backgroundColor = .clear
//        self.backgroundColor = .clear
////        self.contentView.addSubViews([self.pinIdentity, self.avatar, self.content])
//        self.addSubview(self.pinIdentity)
//        self.addSubview(self.avatar)
//        self.addSubview(self.content)
//        self.bringSubviewToFront(self.pinIdentity)
//        self.bringSubviewToFront(self.avatar)
//        Theme.registerSwitchThemeViews(view: self)
//        self.switchTheme(style: Theme.style)
//    }
//    
//    required public init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        self.pinIdentity.frame = CGRect(x: 8, y: 10, width: 18, height: 18)
//        self.avatar.frame = CGRect(x: self.pinIdentity.frame.maxX+4, y: 10, width: 18, height: 18)
//    }
//    
//    @objc open func refresh(with entity: ChatEntity,expand: Bool = false) {
//        self.avatar.image(with: entity.message.user?.avatarURL ?? "", placeHolder: Appearance.avatarPlaceHolder)
//        self.content.numberOfLines(expand ? 0 : 2)
//        self.content.attributedText = entity.pinAttributeText
//        self.content.frame = CGRect(x: 8, y: 4, width: entity.pinWidth, height: entity.pinHeight)
//    }
}

extension PinMessageCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
//        self.container.backgroundColor(style == .dark ? UIColor.theme.barrageLightColor2:UIColor.theme.barrageDarkColor1)
    }
    
}
