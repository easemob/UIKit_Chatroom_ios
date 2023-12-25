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
        search.searchBar.showsCancelButton = true
        search.searchBar.delegate = self
        if let cancelButton = search.searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.setTitle("barrage_long_press_menu_cancel".chatroom.localize, for: .normal)
        }
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
    @objc(initWithRawSources:cellExtensionAction:didSelect:)
    public required init(rawSources: [UserInfoProtocol],cellExtensionAction: @escaping ((UserInfoProtocol) -> Void),didSelect: @escaping ((UserInfoProtocol) -> Void)) {
        self.action = cellExtensionAction
        self.rawSources = rawSources
        self.searchResults = rawSources
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Remove a user.
    /// - Parameter userId: user id
    @objc(removeUserWithId:)
    public func removeUser(userId: String) {
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
        cell?.more.isHidden = ((self.searchController.isActive ? self.searchResults:self.rawSources)[indexPath.row].userId == ChatroomContext.shared?.ownerId ?? "") ? true: !(ChatroomContext.shared?.owner ?? false)
        cell?.moreClosure = { [weak self] in
            self?.action?($0)
        }
        cell?.selectionStyle = .none
        return cell ?? ChatroomParticipantsCell()
    }
    
//    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if self.searchController.isActive {
//            if let item = self.searchResults[safe: indexPath.row] {
//                self.action?(item)
//            }
//        } else {
//            if let item = self.rawSources[safe: indexPath.row] {
//                self.action?(item)
//            }
//        }
//        
//    }
    
    public func updateSearchResults(for searchController: UISearchController) { searchController.searchResultsController?.view.isHidden = false
        if let searchText = searchController.searchBar.text {
            self.searchResults = self.rawSources.filter({ user in
                (user.nickname as NSString).range(of: searchText).location != NSNotFound && (user.nickname as NSString).range(of: searchText).length >= 0
            })
        }
        self.tableView.reloadData()
    }
    
}

extension SearchParticipantsViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.showsCancelButton = true
//        searchBar.setShowsCancelButton(true, animated: true)
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.setTitle("barrage_long_press_menu_cancel".chatroom.localize, for: .normal)
        }
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true)
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
