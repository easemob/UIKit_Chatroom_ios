//
//  DialogManager.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit

@objc final public class DialogManager: NSObject {
    
    public static let shared = DialogManager()
    
    /// Shows the gift list page.
    /// - Parameters:
    ///   - titles: `[String]`
    ///   - gifts: ``GiftsViewController`` array.
    @objc public func showGiftsDialog(titles: [String],gifts: [GiftsViewController]) {
        let gift = PageContainersDialogController(pageTitles: titles, childControllers: gifts,constraintsSize: Appearance.giftDialogContainerConstraintsSize)
        
        UIViewController.currentController?.presentViewController(gift)
    }
    
    /// Shows the chat room member list page.
    /// - Parameters:
    ///   - moreClosure: Callback that occurs when you click `...` to perform operations on chat room members.
    ///   - muteMoreClosure: Callback that occurs when you click `...` to perform operations on muted chat room members.
    @objc public func showParticipantsDialog(moreClosure: @escaping (UserInfoProtocol) -> Void,muteMoreClosure: @escaping (UserInfoProtocol) -> Void) {
        let participants = ComponentsRegister
            .shared.ParticipantsViewController.init(muteTab: false, moreClosure: moreClosure)
        let mutes = ComponentsRegister
            .shared.ParticipantsViewController.init(muteTab: true, moreClosure: muteMoreClosure)
        var pageTitles = ["participant_list_title".chatroom.localize,"Ban List".chatroom.localize]
        if ChatroomContext.shared?.owner ?? false == false {
            pageTitles = ["participant_list_title".chatroom.localize]
        }
        var controllers = [participants,mutes]
        if ChatroomContext.shared?.owner ?? false == false {
            controllers = [participants]
        }
        let container = PageContainersDialogController(pageTitles: pageTitles, childControllers: controllers,constraintsSize: Appearance.pageContainerConstraintsSize)
        UIViewController.currentController?.presentViewController(container)
    }
    
    /// Shows the message reporting page.
    /// - Parameter message: ``ChatMessage``
    @objc public func showReportDialog(message: ChatMessage) {
        var vc = PageContainersDialogController()
        let report = ComponentsRegister
            .shared.ReportViewController.init(message: message) {
                vc.dismiss(animated: true)
                if $0 != nil {
                    UIViewController.currentController?.showToast(toast: $0?.errorDescription ?? "",duration: 2)
                } else {
                    UIViewController.currentController?.showToast(toast: "Successful!",duration: 2)
                }
            }
        vc = PageContainersDialogController(pageTitles: ["barrage_long_press_menu_report".chatroom.localize], childControllers: [report], constraintsSize: Appearance.pageContainerConstraintsSize)
        
        UIViewController.currentController?.presentViewController(vc)
    }
    
    /// Shows message operations.
    /// Generally, message operations are shown when you long-press a message.
    /// - Parameters:
    ///   - actions: ``ActionSheetItemProtocol`` array.
    ///   - action: Callback upon a click of a message operation.
    @objc public func showMessageActions(actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: actions) { item in
            action(item)
            UIViewController.currentController?.dismiss(animated: true)
        }
        actionSheet.frame = CGRect(x: 0, y: 0, width: actionSheet.frame.width, height: actionSheet.frame.height)
        let vc = DialogContainerViewController(custom: actionSheet,constraintsSize: actionSheet.frame.size)
        UIViewController.currentController?.presentViewController(vc)
    }
    
    /// Shows the member operation list when you click `...`.
    /// - Parameters:
    ///   - actions: ``ActionSheetItemProtocol`` array.
    ///   - action: Callback upon a click of a member operation.
    @objc public func showUserActions(actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: actions) { item in
            action(item)
            UIViewController.currentController?.dismiss(animated: true)
        }
        let vc = DialogContainerViewController(custom: actionSheet,constraintsSize: actionSheet.frame.size)
        actionSheet.frame = CGRect(x: 0, y: 0, width: actionSheet.frame.width, height: actionSheet.frame.height)
        UIViewController.currentController?.presentingViewController?.presentViewController(vc)
    }
    
    // Shows the alert view.
    /// - Parameters:
    ///   - content: The alert content to display.
    ///   - showCancel: Whether to display the `Cancel` button.
    ///   - showConfirm: Whether to display the `Confirm` button.
    ///   - confirmClosure: Callback upon a click of the `Confirm` button.
    @objc public func showAlert(content: String,showCancel: Bool,showConfirm: Bool,confirmClosure: @escaping () -> Void) {
        let alert = AlertView(frame: CGRect(x: 0, y: 0, width: Appearance.alertContainerConstraintsSize.width, height: Appearance.alertContainerConstraintsSize.height)).background(color: Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98).content(content: content).title(title: "participant_list_button_click_menu_remove".chatroom.localize).contentTextAlignment(textAlignment: .center)
        if showCancel {
            alert.leftButton(color: Theme.style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3).leftButtonBorder(color: Theme.style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7).leftButton(title: "report_button_click_menu_button_cancel".chatroom.localize)
        }
        if showConfirm {
            alert.rightButtonBackground(color: Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5).rightButton(color: UIColor.theme.neutralColor98).rightButtonTapClosure { _ in
                confirmClosure()
            }.rightButton(title: "Confirm".chatroom.localize)
        }
        let alertVC = AlertViewController(custom: alert)
        UIViewController.currentController?.presentViewController(alertVC)
    }
}
