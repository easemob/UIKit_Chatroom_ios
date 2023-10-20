//
//  ReportOptionsController.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/12.
//

import UIKit

@objc open class ReportOptionsController: UIViewController {
    
    public private(set) var items: [Bool] = []
    
    public private(set) var reportMessage: ChatMessage = ChatMessage()
    
    public private(set) var selectIndex = 0
    
    private var reportClosure: ((ChatError?) -> Void)?
    
    lazy var optionsList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: Appearance.pageContainerConstraintsSize.height - 60 - 50 - BottomBarHeight), style: .grouped).separatorStyle(.none).rowHeight(54).tableFooterView(UIView()).delegate(self).dataSource(self).registerCell(ReportOptionCell.self, forCellReuseIdentifier: "ReportOptionCell").backgroundColor(.clear)
    }()
    
    lazy var cancel: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 16, y: Appearance.pageContainerConstraintsSize.height - 60 - 40  - BottomBarHeight, width: (self.view.frame.width-44)/2.0, height: 40)).layerProperties(UIColor.theme.neutralColor7, 1).textColor(UIColor.theme.neutralColor3, .normal).title("report_button_click_menu_button_cancel".chatroom.localize, .normal).font(UIFont.theme.headlineSmall).cornerRadius(.large).addTargetFor(self, action: #selector(cancelAction), for: .touchUpInside)
    }()
    
    lazy var confirm: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.cancel.frame.maxX+12, y: Appearance.pageContainerConstraintsSize.height - 60 - 40  - BottomBarHeight, width: (self.view.frame.width-44)/2.0, height: 40)).title("Report", .normal).textColor(UIColor.theme.neutralColor98, .normal).backgroundColor(UIColor.theme.primaryColor5).cornerRadius(.large).addTargetFor(self, action: #selector(report), for: .touchUpInside)
    }()
    
    /// Init method
    /// - Parameter message: Reported message.
    @objc public required convenience init(message: ChatMessage,completion: @escaping (ChatError?) -> Void) {
        self.init()
        self.reportClosure = completion
        self.reportMessage = message
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.items = Appearance.reportTags.map({ $0 == "Adult" })
        self.view.backgroundColor(.clear)
        self.view.addSubViews([self.optionsList,self.cancel,self.confirm])
        self.switchTheme(style: Theme.style)
    }

}

extension ReportOptionsController: UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Violation options".chatroom.localize
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Appearance.reportTags.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ReportOptionCell") as? ReportOptionCell
        if cell == nil {
            cell = ReportOptionCell(style: .default, reuseIdentifier: "ReportOptionCell")
        }
        cell?.selectionStyle = .none
        cell?.refresh(select: self.items[safe: indexPath.row] ?? false,title: Appearance.reportTags[safe: indexPath.row] ?? "")
        return cell ?? ReportOptionCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        self.items.removeAll()
        self.items = Array(repeating: false, count: Appearance.reportTags.count)
        self.items[indexPath.row] = true
        self.selectIndex = indexPath.row
        self.optionsList.reloadData()
    }
    
    @objc private func report() {
        ChatClient.shared().chatManager?.reportMessage(withId: self.reportMessage.messageId, tag: Appearance.reportTags[safe: self.selectIndex] ?? "", reason: "",completion: { [weak self] error in
            self?.reportClosure?(error)
        })
        
    }
    
    @objc private func cancelAction() {
        self.dismiss(animated: true)
    }
}

extension ReportOptionsController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.optionsList.reloadData()
    }
    
    public func switchHues() {
        self.switchTheme(style: .light)
    }
    
}
