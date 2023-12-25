//
//  MessageInputBar.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/4.
//

import UIKit

@objcMembers open class MessageInputBar: UIView {
    
    /// The height of the keyboard.
    public private(set) var keyboardHeight = CGFloat(0)

    /// The raw height of the input bar.
    public private(set)var rawHeight: CGFloat = 0

    /// The raw height of the text input area.
    public private(set) var rawTextHeight: CGFloat = 0

    /// The raw frame of the input bar.
    public private(set) var rawFrame: CGRect = .zero

    /// A closure to be called when the user taps the send button.
    public var sendClosure: ((String) -> Void)?

    /// A closure to be called when the user toggles the emoji keyboard.
    public var changeEmojiClosure: ((Bool) -> Void)?
    
    public private(set) lazy var rightView: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-84, y: self.inputField.frame.maxY-32, width: 30, height: 30)).addTargetFor(self, action: #selector(changeToEmoji), for: .touchUpInside).backgroundColor(.clear)
    }()
    
    public private(set) lazy var inputField: PlaceHolderTextView = {
        PlaceHolderTextView(frame: CGRect(x: 12, y: 8, width: self.frame.width-111, height: 36)).delegate(self).font(UIFont.theme.bodyLarge).backgroundColor(.clear).backgroundColor(UIColor.theme.neutralColor95).delegate(self)
    }()
    
    public private(set) lazy var send: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width - 42, y: self.inputField.frame.maxY-32, width: 30, height: 30)).backgroundColor(.clear).image(UIImage(named: "airplane", in: .chatroomBundle, with: nil), .normal).addTargetFor(self, action: #selector(sendMessage), for: .touchUpInside)
    }()
    
    private var limitCount: Int {
        var count = 30
        if NSLocale.preferredLanguages.first!.hasPrefix("en") {
            count = 50
        }
        return count
    }
        
    
    public private(set) var emoji: ChatEmojiView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// MessageInputBar init method
    /// - Parameters:
    ///   - frame: CGRect
    ///   - text: `String` value
    ///   - placeHolder: `String` value
    @objc(initWithFrame:text:placeHolder:)
    required public init(frame: CGRect,text: String? = nil,placeHolder: String? = nil) {
        super.init(frame: frame)
        self.rawHeight = frame.height
        self.rawTextHeight = self.rawHeight-16
        self.rawFrame = frame
        self.addSubViews([self.inputField, self.rightView,self.send])
        self.rightView.setImage(UIImage(named: "emojiKeyboard", in: Bundle.chatroomBundle, with: nil)?.withTintColor(UIColor.theme.neutralColor3), for: .normal)
        self.rightView.setImage(UIImage(named: "textKeyboard", in: Bundle.chatroomBundle, with: nil)?.withTintColor(UIColor.theme.neutralColor3), for: .selected)
        
        self.inputField.cornerRadius(Appearance.inputBarCorner)
        self.inputField.placeHolder = Appearance.inputPlaceHolder.chatroom.localize
        self.inputField.contentInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        self.inputField.tintColor = UIColor.theme.primaryColor5
        self.inputField.placeHolderColor = UIColor.theme.neutralColor6
        self.inputField.textColor = UIColor.theme.neutralColor1
        self.inputField.font = UIFont.theme.bodyLarge
        if text != nil {
            self.inputField.text = text
        }
        if placeHolder != nil {
            self.inputField.placeHolder = placeHolder ?? "Aa"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        
        
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        inputField.removeFromSuperview()
        emoji?.removeFromSuperview()
        emoji = nil
        consoleLogInfo("\(self.swiftClassName ?? "") deinit", type: .debug)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}

extension MessageInputBar: UITextViewDelegate {
    
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.font = UIFont.theme.bodyLarge
        if text == "\n" {
            self.sendMessage()
            return false
        } else {
            if textView.text.isEmpty {
                self.recoverInputState()
            } else {
                self.updateHeight()
            }
            return true
        }
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedRange.length > 0 {
            self.rightView.isSelected = false
        }
    }
    
    
    /// Update subviews height on text input content changed.
    private func updateHeight() {
        let textHeight = self.inputField.sizeThatFits(CGSize(width: self.inputField.frame.width, height: 9999)).height
        if textHeight >= self.rawTextHeight {
            let increment = textHeight - self.rawTextHeight
            self.rawTextHeight += increment
            self.rawHeight = self.rawTextHeight + 16
            if textHeight > Appearance.maxInputHeight {
                self.frame = CGRect(x: 0, y: ScreenHeight - (Appearance.maxInputHeight+16) - self.keyboardHeight, width: self.frame.width, height: Appearance.maxInputHeight+16)
                self.inputField.frame = CGRect(x: 12, y: 8, width: self.frame.width-111, height: Appearance.maxInputHeight)
            } else {
                self.frame = CGRect(x: 0, y: ScreenHeight - self.rawHeight - self.keyboardHeight, width: self.frame.width, height: self.rawHeight)
                self.inputField.frame = CGRect(x: 12, y: 8, width: self.frame.width-111, height: self.rawTextHeight)
            }
            
            self.rightView.frame = CGRect(x: self.frame.width-84, y: self.inputField.frame.maxY-32, width: 30, height: 30)
            self.send.frame = CGRect(x: self.frame.width - 42, y: self.inputField.frame.maxY-32, width: 30, height: 30)
            self.emoji?.frame = CGRect(x: 0, y: self.inputField.frame.maxY+8, width: self.frame.width, height: self.keyboardHeight)
            self.emoji?.backgroundColor(self.backgroundColor ?? UIColor.theme.neutralColor98)
        }
    }
    
    /**
     This function is called when the user taps on the send button in the chat input bar. It hides the input bar, deselects the right view, and sends the message if the input field is not empty. It also resets the input field and the frame of the input bar to their original values.
     */
    @objc func sendMessage() {
        self.hiddenInputBar()
        self.rightView.isSelected = false
        if !self.inputField.attributedText.toString().isEmpty {
            self.sendClosure?(self.inputField.attributedText.toString().trimmingCharacters(in: .whitespacesAndNewlines))
        }
        self.inputField.text = nil
        self.inputField.attributedText = nil
        self.frame = self.rawFrame
        self.recoverInputState()
    }
    
    private func recoverInputState() {
        self.rawHeight = self.rawFrame.height
        self.rawTextHeight = self.rawHeight-16
        self.inputField.frame = CGRect(x: 12, y: 8, width: self.frame.width-111, height: self.rawTextHeight)
        self.rightView.frame = CGRect(x: self.frame.width-84, y: self.inputField.frame.maxY-32, width: 30, height: 30)
        self.send.frame = CGRect(x: self.frame.width - 42, y: self.inputField.frame.maxY-32, width: 30, height: 30)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in subviews.reversed() {
            if view.isKind(of: type(of: view)),view.frame.contains(point){
                let childPoint = self.convert(point, to: view)
                let childView = view.hitTest(childPoint, with: event)
                return childView
            }
        }
        self.hiddenInputBar()
        return super.hitTest(point, with: event)
    }

    /// This function is called when the user taps on the emoji button in the chat input bar. It toggles the selected state of the right view and calls the `changeEmojiClosure` closure with the new selected state. If the right view is selected, it resigns the first responder status of the input field. Otherwise, it becomes the first responder.
    @objc func changeToEmoji() {
        self.rightView.isSelected = !self.rightView.isSelected
        self.changeEmojiClosure?(self.rightView.isSelected)
        if self.rightView.isSelected {
            self.inputField.resignFirstResponder()
        } else {
            self.inputField.becomeFirstResponder()
        }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if !self.inputField.isFirstResponder {
            return
        }
        let frame = notification.chatroom.keyboardEndFrame
        let duration = notification.chatroom.keyboardAnimationDuration
        self.keyboardHeight = frame!.height
        UIView.animate(withDuration: duration!) {
            self.frame = CGRect(x: 0, y: ScreenHeight - self.rawFrame.height - frame!.height, width: self.frame.width, height: self.rawFrame.height)
        }
        self.updateHeight()
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        let frame = notification.chatroom.keyboardEndFrame
        let duration = notification.chatroom.keyboardAnimationDuration
        self.keyboardHeight = frame!.height
        self.frame = CGRect(x: 0, y: self.frame.origin.y, width: self.frame.width, height: self.keyboardHeight + 60)
        if self.emoji == nil {
            let emoji = ChatEmojiView(frame: CGRect(x: 0, y: self.inputField.frame.maxY+8, width: self.frame.width, height: self.keyboardHeight)).tag(124)
            self.emoji = emoji
            self.addSubview(emoji)
        }
        self.updateHeight()
        self.emoji?.emojiClosure = { [weak self] in
            guard let self = self else { return }
            self.emoji?.deleteEmoji.isEnabled = true
            self.emoji?.deleteEmoji.isUserInteractionEnabled = true
            self.inputField.attributedText = self.convertText(text: self.inputField.attributedText, key: $0)
            self.updateHeight()
        }
        self.emoji?.deleteClosure = { [weak self] in
            if self?.inputField.text?.count ?? 0 > 0 {
                self?.inputField.deleteBackward()
                self?.emoji?.deleteEmoji.isEnabled = true
                self?.emoji?.deleteEmoji.isUserInteractionEnabled = true
            } else {
                self?.emoji?.deleteEmoji.isEnabled = false
                self?.emoji?.deleteEmoji.isUserInteractionEnabled = false
            }
            self?.updateHeight()
        }
        self.emoji?.isHidden = true
        UIView.animate(withDuration: duration!) {
            self.emoji?.isHidden = false
        }
    }
    
    @objc public func hiddenInputBar() {
        self.inputField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: 0, y: ScreenHeight, width: self.frame.width, height: self.keyboardHeight + 60)
        }
        self.rightView.isSelected = false
    }
    
    /// Raise input bar
    @objc public func show() {
        self.inputField.becomeFirstResponder()
    }
    
    /// Hidden input bar
    @objc public func hiddenInput() {
        self.hiddenInputBar()
    }

    /**
     Converts the given attributed string to include an emoji image attachment with the specified key.

     - Parameters:
        - text: The attributed string to convert.
        - key: The key of the emoji image to use.

     - Returns: The converted attributed string with the emoji image attachment.
     */
    func convertText(text: NSAttributedString?, key: String) -> NSAttributedString {
        let attribute = NSMutableAttributedString(attributedString: text!)
        attribute.addAttributes([.foregroundColor:Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1,.font:UIFont.theme.bodyLarge], range: NSMakeRange(0, attribute.length))
        let attachment = NSTextAttachment()
        attachment.image = ChatEmojiConvertor.shared.emojiMap.isEmpty ? UIImage(named: key, in: .chatroomBundle, with: nil):ChatEmojiConvertor.shared.emojiMap[key]
        attachment.bounds = CGRect(x: 0, y: -3.5, width: 18, height: 18)
        let imageText = NSMutableAttributedString(attachment: attachment)
        if #available(iOS 11.0, *) {
            imageText.addAttributes([.accessibilityTextCustom: key], range: NSMakeRange(0, imageText.length))
        } else {
            assert(false,"failed add accessibility custom text!")
        }
        attribute.append(imageText)
        return attribute
    }
    
    public func dismissKeyboard() {
        self.inputField.resignFirstResponder()
    }
}

extension MessageInputBar: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.rightView.setImage(UIImage(named: "emojiKeyboard", in: .chatroomBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3, renderingMode: .automatic), for: .normal)
        self.rightView.setImage(UIImage(named: "textKeyboard", in: .chatroomBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3, renderingMode: .automatic), for: .selected)
        var image = UIImage(named: "airplane", in: .chatroomBundle, with: nil)
        if style == .dark {
            image = image?.withTintColor(UIColor.theme.primaryColor6)
        }
        self.send.setImage(image, for: .normal)
        self.viewWithTag(124)?.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.inputField.backgroundColor(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95)
        self.inputField.tintColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
        self.inputField.placeHolderColor = style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor6
        self.inputField.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.emoji?.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
    
}

public extension NSAttributedString {
    /**
     Converts the attributed string to a plain string by replacing any custom accessibility text with its corresponding value.

     - Returns: A plain string representation of the attributed string.
     */
    func toString() -> String {
        let result = NSMutableAttributedString(attributedString: self)
        var replaceList: [(NSRange, String)] = []
        if #available(iOS 11.0, *) {
            result.enumerateAttribute(.accessibilityTextCustom, in: NSRange(location: 0, length: result.length), using: { value, range, _ in
                if let value = value as? String {
                    for i in range.location..<range.location + range.length {
                        replaceList.append((NSRange(location: i, length: 1), value))
                    }
                }
            })
        } else {
            assert(false,"failed add replace custom text!")
        }
        for i in replaceList.reversed() {
            result.replaceCharacters(in: i.0, with: i.1)
        }
        return result.string
    }
}

