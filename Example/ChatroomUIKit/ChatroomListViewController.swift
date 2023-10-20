//
//  ChatroomListViewController.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import ChatroomUIKit

final class ChatroomListViewController: UITableViewController {
    
    private var chatrooms = [ChatRoom]() {
        didSet {
            if self.chatrooms.count <= 0 {
                self.tableView.backgroundView = self.empty
            } else {
                self.tableView.backgroundView = nil
            }
        }
    }
    
    lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height),emptyImage: UIImage(named: "empty",in: .chatroomBundle, with: nil))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat Room List"
        self.tableView.registerCell(ChatroomCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.rowHeight = 60
        self.tableView.tableFooterView = UIView()
        ChatClient.shared().roomManager?.getChatroomsFromServer(withPage: 1, pageSize: 100, completion: { [weak self] result, error in
            if error == nil {
                self?.chatrooms.append(contentsOf: result?.list ?? [])
                self?.tableView.reloadDataSafe()
            } else {
                self?.showToast(toast: "get chatroom error:\(error?.errorDescription ?? "")", duration: 3)
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.chatrooms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? ChatroomCell
        if cell == nil {
            cell = ChatroomCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        }
        // Configure the cell...
        let chatroom = self.chatrooms[safe: indexPath.row]
        cell?.selectionStyle = .none
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = chatroom?.subject
        cell?.detailTextLabel?.text = chatroom?.chatroomId
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(UIWithBusinessViewController(chatroomId: self.chatrooms[indexPath.row].chatroomId ?? ""), animated: true)
    }
    
    deinit {
        ChatroomUIKitClient.shared.logout()
    }
    
}

final class ChatroomCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
