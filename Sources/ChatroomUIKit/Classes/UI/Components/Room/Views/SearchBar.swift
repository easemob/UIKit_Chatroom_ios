//
//  SearchBar.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/15.
//

import UIKit


/// SearchBar action events
@objc public protocol SearchBarActionEvents: NSObjectProtocol {
    func onSearchBarClicked()
}

@objc open class SearchBar: UIView {
    
    lazy private var eventHandlers: NSHashTable<SearchBarActionEvents> = NSHashTable<SearchBarActionEvents>.weakObjects()
    
    @objc public func addActionHandler(handler: SearchBarActionEvents) {
        if self.eventHandlers.contains(handler) {
            return
        }
        self.eventHandlers.add(handler)
    }
    
    public func removeEventHandler(actionHandler: SearchBarActionEvents) {
        self.eventHandlers.remove(actionHandler)
    }
    
    lazy var searchField: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 16, y: 4, width: self.frame.width-32, height: self.frame.height-8)).backgroundColor(UIColor.theme.neutralColor95).textColor(UIColor.theme.neutralColor6, .normal).cornerRadius(.large).title("Search".chatroom.localize, .normal).image(UIImage(named: "search", in: .chatroomBundle, with: nil), .normal).addTargetFor(self, action: #selector(clickSearch), for: .touchUpInside)
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.searchField)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func clickSearch() {
        for handler in self.eventHandlers.allObjects {
            handler.onSearchBarClicked()
        }
    }
}

extension SearchBar: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        let raw = UIImage(named: "search", in: .chatroomBundle, with: nil)
        let image = style == .dark ? raw?.withTintColor(UIColor.theme.neutralColor4):raw
        self.searchField.backgroundColor(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95).textColor(style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor6, .normal).image(image, .normal)
    }
    
}
