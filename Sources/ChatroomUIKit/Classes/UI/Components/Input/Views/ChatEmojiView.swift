//
//  ChatEmojiView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import UIKit

@objcMembers open class ChatEmojiView: UIView {
        
    @objc public var deleteClosure: (() -> Void)?

    @objc public var emojiClosure: ((String) -> Void)?

    public lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (ScreenWidth - 20 - 60) / 7.0, height: (ScreenWidth - 20 - 60) / 7.0)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }()

    public lazy var emojiList: UICollectionView = {
        UICollectionView(frame: CGRect(x: 0, y: 10, width: ScreenWidth, height: self.frame.height - 10), collectionViewLayout: self.flowLayout).registerCell(ChatEmojiCell.self, forCellReuseIdentifier: "ChatEmojiCell").dataSource(self).delegate(self).backgroundColor(.clear)
    }()

    public lazy var separaLine: UIView = {
        UIView(frame: CGRect(x: 0, y: 10, width: ScreenWidth, height: 1)).backgroundColor(.clear)
    }()

    public lazy var deleteEmoji: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width - 48, y: self.frame.height - 56, width: 36, height: 36)).addTargetFor(self, action: #selector(deleteAction), for: .touchUpInside).isEnabled(false).isUserInteractionEnabled(false).cornerRadius(.large).backgroundColor(.clear)
    }()

    @objc required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.emojiList, self.deleteEmoji, self.separaLine])
        self.deleteEmoji.setImage(UIImage(named: "delete_emoji_light", in: .chatroomBundle, with: nil), for: .normal)
        
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func deleteAction() {
        self.deleteClosure?()
    }
}

extension ChatEmojiView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ChatEmojiConvertor.shared.emojis.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatEmojiCell", for: indexPath) as? ChatEmojiCell
        cell?.icon.image = ChatEmojiConvertor.shared.emojiMap.isEmpty ? UIImage(named: ChatEmojiConvertor.shared.emojis[indexPath.row], in: .chatroomBundle, with: nil):ChatEmojiConvertor.shared.emojiMap[ChatEmojiConvertor.shared.emojis[indexPath.row]]
        return cell ?? ChatEmojiCell()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.emojiClosure?(ChatEmojiConvertor.shared.emojis[indexPath.row])
    }
}

extension ChatEmojiView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.deleteEmoji.setImage(UIImage(named: style == .dark ? "delete_emoji_dark":"delete_emoji_light", in: .chatroomBundle, with: nil), for: .normal)
    }
    
    public func switchHues() {
        self.switchTheme(style: .light)
    }
}

open class ChatEmojiCell: UICollectionViewCell {
    lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: 7, y: 7, width: self.contentView.frame.width - 14, height: self.contentView.frame.height - 14)).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.icon)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.icon.frame = CGRect(x: 7, y: 7, width: contentView.frame.width - 14, height: contentView.frame.height - 14)
    }
}


