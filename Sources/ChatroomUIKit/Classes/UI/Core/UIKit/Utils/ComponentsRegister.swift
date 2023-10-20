//
//  ComponentsRegister.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

fileprivate let component = ComponentsRegister()

/// An object containing UI components that are used through the ChatroomUIKit SDK.
@objcMembers public class ComponentsRegister: NSObject {
    
    public class var shared: ComponentsRegister {
        component
    }
    
    /// Gift barrage list cell class.
    public var GiftBarragesViewCell: GiftBarrageCell.Type = GiftBarrageCell.self
    
    /// Gifts view cell class.
    public var GiftsCell: GiftEntityCell.Type = GiftEntityCell.self
    
    /// Chat input bar class.
    public var InputBar: ChatInputBar.Type = ChatInputBar.self
    
    /// Chatroom barrages list cell class.
    public var ChatBarragesCell: ChatBarrageCell.Type = ChatBarrageCell.self
    
    /// Report message controller
    public var ReportViewController: ReportOptionsController.Type = ReportOptionsController.self
    
    /// Member list page&Banned list page
    public var ParticipantsViewController: ParticipantsController.Type = ParticipantsController.self
    
    public var ChatroomParticipantCell: ChatroomParticipantsCell.Type = ChatroomParticipantsCell.self
    
}
