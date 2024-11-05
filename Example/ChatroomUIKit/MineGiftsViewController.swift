//
//  MineGiftsViewController.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import ChatroomUIKit

class MineGiftsViewController: GiftsViewController {
    
    override func onGiftSendClick(item: GiftEntityProtocol) {
        //点击发送礼物按钮时此方法会被触发
        super.onGiftSendClick(item: item)
    }

    override func onGiftSelected(item: any GiftEntityProtocol) {
        //点击选择礼物后此方法会触发
    }
}
