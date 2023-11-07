//
//  SearchTableViewController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/15.
//

import UIKit

@objc public class SearchParticipantsViewController: UITableViewController,UISearchResultsUpdating {
        
    public private(set) lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Search".chatroom.localize
        search.obscuresBackgroundDuringPresentation = false
        return search
    }()
    
    public private(set) var rawSources = [UserInfoProtocol]() {
        didSet {
            DispatchQueue.main.async {
                if self.rawSources.count <= 0  {
                    self.tableView.backgroundView = self.empty
                } else {
                    self.tableView.backgroundView = nil
                }
            }
        }
    }
    
    public private(set) var searchResults = [UserInfoProtocol]() {
        didSet {
            DispatchQueue.main.async {
                if self.searchController.isActive {
                    if self.searchResults.count <= 0 {
                        self.tableView.backgroundView = self.empty
                    } else {
                        self.tableView.backgroundView = nil
                    }
                }
            }
        }
    }
    
    public private(set) var action: ((UserInfoProtocol) -> Void)?
    
    public private(set) lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height),emptyImage: UIImage(named: "empty",in: .chatroomBundle, with: nil))
    }()
    
    
    /// `SearchViewController` init method.
    /// - Parameters:
    ///   - rawSources: Data source
    ///   - cellExtensionAction: `...` action on click.
    ///   - didSelect: Cell did select callback.
    @objc public required convenience init(rawSources: [UserInfoProtocol],cellExtensionAction: @escaping ((UserInfoProtocol) -> Void),didSelect: @escaping ((UserInfoProtocol) -> Void)) {
        self.init()
        self.action = cellExtensionAction
        self.rawSources = rawSources
        self.searchResults = rawSources
        Theme.registerSwitchThemeViews(view: self)
    }
    
    /// Remove a user.
    /// - Parameter userId: user id
    @objc public func removeUser(userId: String) {
        if self.searchController.isActive {
            self.searchResults.removeAll { $0.userId == userId }
        } else {
            self.rawSources.removeAll { $0.userId == userId }
        }
        self.tableView.reloadData()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.tableView.rowHeight = Appearance.participantsRowHeight
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.register(ChatroomParticipantsCell.self, forCellReuseIdentifier: "ChatroomParticipantsCellSearchResultCell")
        _ = self.searchController.publisher(for: \.isActive).sink { [weak self] status in
            if !status {
                self?.searchResults.removeAll()
            }
        }
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ChatroomUIKitKickUserSuccess"), object: self, queue: .main) { [weak self] notify in
            if let userId = notify.object as? String {
                self?.rawSources.removeAll { $0.userId == userId }
                self?.searchResults.removeAll { $0.userId == userId }
                self?.tableView.reloadData()
            }
        }
    }
    
    deinit {
        consoleLogInfo("deinit \(self.swiftClassName ?? "")", type: .debug)
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
        
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive {
            return self.searchResults.count
        }
        return self.rawSources.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ChatroomParticipantsCellSearchResultCell", for: indexPath) as? ChatroomParticipantsCell
        if cell == nil {
            cell = ChatroomParticipantsCell(style: .default, reuseIdentifier: "ChatroomParticipantsCellSearchResultCell")
        }
        if self.searchController.isActive {
            if let item = self.searchResults[safe: indexPath.row] {
                cell?.refresh(user: item)
            }
        } else {
            if let item = self.rawSources[safe: indexPath.row] {
                cell?.refresh(user: item)
            }
        }
        cell?.more.isHidden = !(ChatroomContext.shared?.owner ?? false)
        cell?.moreClosure = { [weak self] in
            self?.action?($0)
        }
        cell?.selectionStyle = .none
        return cell ?? ChatroomParticipantsCell()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.searchController.isActive {
            if let item = self.searchResults[safe: indexPath.row] {
                self.action?(item)
            }
        } else {
            if let item = self.rawSources[safe: indexPath.row] {
                self.action?(item)
            }
        }
        
    }
    
    public func updateSearchResults(for searchController: UISearchController) { searchController.searchResultsController?.view.isHidden = false
        if let searchText = searchController.searchBar.text {
            self.searchResults = self.rawSources.filter({ user in
                (user.nickName as NSString).range(of: searchText).location != NSNotFound && (user.nickName as NSString).range(of: searchText).length >= 0
            })
        }
        self.tableView.reloadData()
    }
    
}


extension SearchParticipantsViewController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.searchController.searchBar.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.searchController.searchBar.barStyle = style == .dark ? .black:.default
        self.tableView.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.tableView.reloadData()
    }
    
    
}
