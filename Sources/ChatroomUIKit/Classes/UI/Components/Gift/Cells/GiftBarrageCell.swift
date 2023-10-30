//
//  GiftBarrageCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

/**
 A UITableViewCell subclass used to display a gift item in a barrage view.
 
 This cell contains the avatar, username, gift name, gift icon, and gift count of the gift item.
 */
@objcMembers open class GiftBarrageCell: UITableViewCell {

    var gift: GiftEntityProtocol?
    
    lazy var lightEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
    
    lazy var darkEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    
    lazy var container: UIView = {
        UIView(frame: CGRect(x: 0, y: 5, width: self.contentView.frame.width, height: self.contentView.frame.height - 10)).backgroundColor(UIColor.theme.barrageDarkColor1).isUserInteractionEnabled(false)
    }()
    
    lazy var blur: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: self.lightEffect)
        blurView.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height - 10)
        return blurView
    }()
    
    lazy var avatar: ImageView = ImageView(frame: CGRect(x: 5, y: 5, width: self.frame.width / 5.0, height: self.frame.width / 5.0)).contentMode(.scaleAspectFit)
    
    lazy var userName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX + 6, y: 8, width: self.frame.width / 5.0 * 2 - 12, height: 15)).font(UIFont.theme.headlineExtraSmall).textColor(UIColor.theme.neutralColor100)
    }()
    
    lazy var giftName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX + 6, y: self.userName.frame.maxY, width: self.frame.width / 5.0 * 2 - 12, height: 15)).font(UIFont.theme.bodySmall).textColor(UIColor.theme.neutralColor100)
    }()
    
    lazy var giftIcon: ImageView = {
        ImageView(frame: CGRect(x: self.frame.width / 5.0 * 3, y: 0, width: self.frame.width / 5.0, height: self.contentView.frame.height)).contentMode(.scaleAspectFit)
    }()
    
    lazy var giftNumbers: UILabel = {
        UILabel(frame: CGRect(x: self.frame.width / 5.0 * 4 + 8, y: 10, width: self.frame.width / 5.0 - 16, height: self.frame.height - 20)).font(UIFont.theme.giftNumberFont).textColor(UIColor.theme.neutralColor100)
    }()

    override required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.isUserInteractionEnabled = false
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.container)
        self.container.addSubViews([self.blur,self.avatar, self.userName, self.giftName, self.giftIcon, self.giftNumbers])
        
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.container.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        self.container.createGradient([], [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1)],[0,1])
        self.container.cornerRadius(self.container.frame.height/2.0)
        self.blur.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)
        self.avatar.frame = CGRect(x: 5, y: 5, width: self.container.frame.height - 10, height: self.container.frame.height - 10)
        self.avatar.cornerRadius(Appearance.avatarRadius)
        self.userName.frame = CGRect(x: self.avatar.frame.maxX + 6, y: self.container.frame.height/2.0 - 15, width: frame.width / 5.0 * 2 - 12, height: 15)
        self.giftName.frame = CGRect(x: self.avatar.frame.maxX + 6, y: self.container.frame.height/2.0 , width: frame.width / 5.0 * 2 - 12, height: 15)
        self.giftIcon.frame = CGRect(x: frame.width / 5.0 * 3, y: 0, width: self.container.frame.height, height: self.container.frame.height)
        self.giftNumbers.frame = CGRect(x: self.giftIcon.frame.maxX + 5, y: 5, width: self.container.frame.width - self.giftIcon.frame.maxX - 5, height: self.container.frame.height - 5)
    }
    
    /// Refresh view on receive gift.
    /// - Parameter item: ``GiftEntityProtocol``
    @objc open func refresh(item: GiftEntityProtocol) {
        if self.gift == nil {
            self.gift = item
        }
        if let avatarURL = item.sendUser?.avatarURL {
            self.avatar.image(with:avatarURL, placeHolder: UIImage(named: "", in: .chatroomBundle, with: nil))
        }
        
        self.userName.text = item.sendUser?.nickName
        self.giftName.text = "Sent ".chatroom.localize + (item.giftName)
        self.giftIcon.image(with: item.giftIcon, placeHolder: Appearance.giftPlaceHolder)
        self.giftNumbers.text = "X \(item.giftCount)"
    }


}


extension GiftBarrageCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.blur.effect = style == .dark ? self.darkEffect:self.lightEffect
        self.container.backgroundColor = style == .dark ? UIColor.theme.barrageLightColor2:UIColor.theme.barrageDarkColor1
    }
    
    
}
