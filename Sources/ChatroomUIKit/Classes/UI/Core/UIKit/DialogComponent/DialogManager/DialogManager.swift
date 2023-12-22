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
    @objc(showGiftsDialogWithTitles:gifts:)
    public func showGiftsDialog(titles: [String],gifts: [GiftsViewController]) {
        let gift = PageContainersDialogController(pageTitles: titles, childControllers: gifts,constraintsSize: Appearance.giftDialogContainerConstraintsSize)
        
        UIViewController.currentController?.presentViewController(gift)
    }
    
    /// Shows the chat room member list page.
    /// - Parameters:
    ///   - moreClosure: Callback that occurs when you click `...` to perform operations on chat room participants.
    ///   - muteMoreClosure: Callback that occurs when you click `...` to perform operations on muted chat room participants.
    @objc(showParticipantsDialogWithMoreClosure:muteMoreClosure:)
    public func showParticipantsDialog(moreClosure: @escaping (UserInfoProtocol) -> Void,muteMoreClosure: @escaping (UserInfoProtocol) -> Void) {
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
    @objc public func showReportDialog(message: ChatMessage,errorClosure: @escaping (ChatError?)->Void) {
        var vc = PageContainersDialogController()
        let report = ComponentsRegister
            .shared.ReportViewController.init(message: message) {
                vc.dismiss(animated: true)
                errorClosure($0)
            }
        vc = PageContainersDialogController(pageTitles: ["barrage_long_press_menu_report".chatroom.localize], childControllers: [report], constraintsSize: Appearance.pageContainerConstraintsSize)
        
        let current = UIViewController.currentController
        if current?.presentingViewController != nil {
            current?.presentingViewController?.presentViewController(vc)
        } else {
            current?.presentViewController(vc)
        }
    }
    
    /// Shows message operations.
    /// Generally, message operations are shown when you long-press a message.
    /// - Parameters:
    ///   - actions: ``ActionSheetItemProtocol`` array.
    ///   - action: Callback upon a click of a message operation.
    @objc(showWithMessageActions:action:)
    public func showMessageActions(_ actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
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
    @objc(showWithUserActions:action:)
    public func showUserActions(actions: [ActionSheetItemProtocol],action: @escaping ActionClosure) {
        let actionSheet = ActionSheet(items: actions) { item in
            action(item)
            UIViewController.currentController?.dismiss(animated: true)
        }
        let vc = DialogContainerViewController(custom: actionSheet,constraintsSize: actionSheet.frame.size)
        actionSheet.frame = CGRect(x: 0, y: 0, width: actionSheet.frame.width, height: actionSheet.frame.height)
        let current = UIViewController.currentController
        if current?.presentingViewController != nil {
            current?.presentingViewController?.presentViewController(vc)
        } else {
            current?.presentViewController(vc)
        }
    }
    
    // Shows the alert view.
    /// - Parameters:
    ///   - content: The alert content to display.
    ///   - showCancel: Whether to display the `Cancel` button.
    ///   - showConfirm: Whether to display the `Confirm` button.
    ///   - confirmClosure: Callback upon a click of the `Confirm` button.
    @objc(showAlertWithContent:showCancel:showConfirm:title:confirmClosure:)
    public func showAlert(content: String,showCancel: Bool,showConfirm: Bool,title: String = "",confirmClosure: @escaping () -> Void) {
        let alert = AlertView().background(color: Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98).title(title: title).content(content: content).contentTextAlignment(textAlignment: .center).cornerRadius(.medium).contentColor(color: Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1).titleColor(color: Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        if showCancel {
            alert.leftButton(color: Theme.style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor4).leftButtonBorder(color: Theme.style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7).leftButton(title: "report_button_click_menu_button_cancel".chatroom.localize).leftButtonBackground(color: Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        }
        if showConfirm {
            alert.rightButtonBackground(color: Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5).rightButton(color: UIColor.theme.neutralColor98).rightButtonTapClosure { _ in
                confirmClosure()
            }.rightButton(title: "Confirm".chatroom.localize)
        }
        let alertVC = AlertViewController(custom: alert)
        let vc = UIViewController.currentController
        if vc?.presentingViewController != nil {
            vc?.presentingViewController?.presentViewController(alertVC)
        } else {
            vc?.presentViewController(alertVC)
        }
    }
}
