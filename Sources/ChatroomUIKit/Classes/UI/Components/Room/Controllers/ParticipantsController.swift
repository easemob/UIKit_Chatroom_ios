//
//  ParticipantsController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/11.
//

import UIKit

/// Chatroom participants list
open class ParticipantsController: UITableViewController {
    
    public private(set) var roomService = RoomService(roomId: ChatroomContext.shared?.roomId ?? "")
    
    public private(set) var users = [UserInfoProtocol]() {
        didSet {
            DispatchQueue.main.async {
                if self.users.count <= 0 {
                    self.tableView.backgroundView = self.empty
                } else {
                    self.tableView.backgroundView = nil
                }
            }
        }
    }
    
    public private(set) var userClosure: ((UserInfoProtocol) -> Void)?
    
    public private(set) var fetchFinish = true
    
    public private(set) var muteTab = false
    
    private var search: SearchParticipantsViewController?
    
    lazy var loadingView: LoadingView = {
        LoadingView(frame: CGRect(x: Appearance.pageContainerConstraintsSize.width/2.0-50, y: Appearance.pageContainerConstraintsSize.height/2.0-70, width: 100, height: 100))
    }()
    
    lazy var searchField: SearchBar = {
        SearchBar(frame: CGRect(x: 0, y: 0, width: Appearance.pageContainerConstraintsSize.width, height: 44))
    }()
    
    lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height),emptyImage: UIImage(named: "empty",in: .chatroomBundle, with: nil))
    }()
    
    /// ParticipantsController init method.
    /// - Parameters:
    ///   - muteTab: `Bool` value,Indicate that is member list or mute list
    ///   - moreClosure: Callback,when click more.
    @objc required public convenience init(muteTab:Bool = false,moreClosure: @escaping (UserInfoProtocol) -> Void) {
        self.init()
        self.muteTab = muteTab
        self.userClosure = moreClosure
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableHeaderView = self.searchField
        self.tableView.registerCell(ComponentsRegister.shared.ChatroomParticipantCell, forCellReuseIdentifier: "ChatroomParticipantsCell")
        self.tableView.rowHeight = Appearance.participantsRowHeight
        self.tableView.separatorColor(UIColor.theme.neutralColor9)
        self.tableView.tableFooterView(UIView())
        self.searchField.addActionHandler(handler: self)
        self.tableView.addSubview(self.loadingView)
        Theme.registerSwitchThemeViews(view: self)
        // Uncomment the following line to preserve selection between presentations
        self.fetchFinish = false
        self.fetchUsers()
    }
    
    deinit {
        consoleLogInfo("deinit \(self.swiftClassName ?? "")", type: .debug)
    }
    
    func fetchUsers() {
        self.loadingView.startAnimating()
        if self.muteTab {
            self.roomService.fetchMuteUsers(pageSize: Appearance.mutePageSize) { [weak self] datas, error in
                DispatchQueue.main.async {
                    self?.loadingView.stopAnimating()
                    self?.fetchFinish = true
                    if error == nil {
                        self?.users.append(contentsOf: datas ?? [])
                        self?.tableView.reloadData()
                    }
                    if let eventsListeners =  self?.roomService.eventsListener.allObjects {
                        for listener in eventsListeners {
                            listener.onEventResultChanged(error: error, type: .fetchMutes)
                        }
                    }
                }
            }
        } else {
            self.roomService.fetchParticipants(pageSize: Appearance.participantsPageSize) { [weak self] datas, error in
                DispatchQueue.main.async {
                    self?.loadingView.stopAnimating()
                    self?.fetchFinish = true
                    if error == nil {
                        self?.users.append(contentsOf: datas ?? [])
                        if self?.users.first?.userId != ChatroomContext.shared?.ownerId {
                            self?.roomService.fetchThenCacheUserInfosOnEndScroll(unknownUserIds: [ChatroomContext.shared?.ownerId ?? ""]) { users, error in
                                if error == nil,let owner = users?.first {
                                    DispatchQueue.main.async {
                                        self?.users.insert(owner, at: 0)
                                        self?.tableView.reloadData()
                                    }
                                }
                            }
                        }
                        self?.tableView.reloadData()
                    }
                    if let eventsListeners =  self?.roomService.eventsListener.allObjects {
                        for listener in eventsListeners {
                            listener.onEventResultChanged(error: error, type: .fetchParticipants)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatroomParticipantCell, reuseIdentifier: "ChatroomParticipantsCell")
        if cell == nil {
            cell = ComponentsRegister.shared.ChatroomParticipantCell.init(style: .default, reuseIdentifier: "ChatroomParticipantsCell")
        }
        // Configure the cell...
        if let user = self.users[safe: indexPath.row] {
            cell?.refresh(user: user,hiddenUserIdentity: Appearance.barrageCellStyle == .hideUserIdentity)
        }
        cell?.more.isHidden = !(ChatroomContext.shared?.owner ?? false)
        cell?.moreClosure = { [weak self] user in
            self?.operationUser(user: user)
        }
        cell?.selectionStyle = .none
        return cell ?? ChatroomParticipantsCell()
    }
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !self.muteTab {
            if UInt(self.users.count)%Appearance.participantsPageSize == 0,self.users.count - 2 == indexPath.row,self.fetchFinish {
                self.fetchFinish = false
                self.fetchUsers()
            }
        }
    }
    
    private func filterItems(user: UserInfoProtocol) {
        if let map = ChatroomContext.shared?.muteMap {
            let mute = map[user.userId] ?? false
            if mute {
                if let index = Appearance.defaultOperationUserActions.firstIndex(where: { $0.tag == "Mute"
                }) {
                    Appearance.defaultOperationUserActions[index] = ActionSheetItem(title: "barrage_long_press_menu_unmute".chatroom.localize, type: .normal,tag: "unMute")
                }
            } else {
                if let index = Appearance.defaultOperationUserActions.firstIndex(where: { $0.tag == "unMute"
                }) {
                    Appearance.defaultOperationUserActions[index] = ActionSheetItem(title: "barrage_long_press_menu_mute".chatroom.localize, type: .normal, tag: "Mute")
                }
            }
        }
    }
    
    private func operationUser(user: UserInfoProtocol) {
        self.filterItems(user: user)
        self.userClosure?(user)
    }
    
    private func removeUser(user: UserInfoProtocol) {
        self.search?.removeUser(userId: user.userId)
        self.users.removeAll { $0.userId == user.userId }
        self.tableView.reloadData()
    }
    
    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var unknownInfoIds = [String]()
        if let visiblePaths = tableView.indexPathsForVisibleRows {
            for indexPath in visiblePaths {
                if let nickName = self.users[safe: indexPath.row]?.nickName,nickName.isEmpty {
                    unknownInfoIds.append(self.users[safe: indexPath.row]?.userId ?? "")
                }
            }
        }
        
        if !unknownInfoIds.isEmpty {
            self.roomService.fetchThenCacheUserInfosOnEndScroll(unknownUserIds: unknownInfoIds) { [weak self] infos, error in
                if error == nil {
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: self?.tableView.indexPathsForVisibleRows ?? [], with: .none)
                    }
                } else {
                    consoleLogInfo("fetchThenCacheUserInfosOnEndScroll error:\(error?.errorDescription ?? "")", type: .error)
                }
            }
        }
    }
}

extension ParticipantsController: SearchBarActionEvents {
    
    public func onSearchBarClicked() {
        self.search = SearchParticipantsViewController(rawSources: self.rawSources()) { [weak self] user in
            if ChatroomContext.shared?.owner ?? false {
                self?.operationUser(user: user)
            }
        } didSelect: { user in
            
        }
        if let vc = self.search {
            self.present(vc, animated: true)
        }
    }
    
    private func rawSources() -> [UserInfoProtocol] {
        var sources = [UserInfoProtocol]()
        for user in self.users {
            sources.append(user)
        }
        return sources
    }
    
}

extension ParticipantsController: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.tableView.separatorColor(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9)
        self.tableView.backgroundColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
    }
    
}

