//
//  ReportOptionCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/12.
//

import UIKit

@objc open class ReportOptionCell: UITableViewCell {
    
    public private(set) var normalImage = UIImage(named: "unselect", in: .chatroomBundle, with: nil)
    
    public private(set) var selectImage = UIImage(named: "select", in: .chatroomBundle, with: nil)
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: 16, y: (self.contentView.frame.height-22)/2.0, width: self.contentView.frame.width-72, height: 22)).textColor(UIColor.theme.neutralColor1).font(UIFont.theme.labelLarge).backgroundColor(.clear)
    }()
    
    lazy var stateView: UIImageView = {
        UIImageView(frame: CGRect(x: self.contentView.frame.width-44, y: (self.contentView.frame.height-32)/2.0, width: 32, height: 32)).backgroundColor(.clear)
    }()
    
    @objc public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubViews([self.content,self.stateView])
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.content.frame = CGRect(x: 16, y: (self.contentView.frame.height-22)/2.0, width: self.contentView.frame.width-72, height: 22)
        self.stateView.frame = CGRect(x: self.contentView.frame.width-44, y: (self.contentView.frame.height-32)/2.0, width: 32, height: 32)
    }
    
    /// Refresh report option select state.
    /// - Parameters:
    ///   - select: Whether select or not.
    ///   - title: title
    @objc(refreshWithSelected:title:)
    public func refresh(select: Bool ,title: String) {
        self.stateView.image(select ? self.selectImage:self.normalImage)
        self.content.text = title
    }
}

extension ReportOptionCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.content.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        self.selectImage = style == .dark ? self.selectImage?.withTintColor(UIColor.theme.primaryColor6, renderingMode: .automatic):self.selectImage
        self.normalImage = style == .dark ? self.normalImage?.withTintColor(UIColor.theme.neutralColor8, renderingMode: .automatic):self.normalImage
    }
    
    
}
