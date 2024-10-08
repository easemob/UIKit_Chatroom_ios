//
//  ExampleRequiredConfig.swift
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/9/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import ChatroomUIKit
/*
 第一步先创建App `https://docs-im-beta.easemob.com/product/enable_and_configure_IM.html#%E8%8E%B7%E5%8F%96%E7%8E%AF%E4%BF%A1%E5%8D%B3%E6%97%B6%E9%80%9A%E8%AE%AF-im-%E7%9A%84%E4%BF%A1%E6%81%AF` website.Then enable chat function.
 
第二步生成token测试.
 **/
public class ExampleRequiredConfig {
    //请参看文档 https://docs-im-beta.easemob.com/product/enable_and_configure_IM.html#%E8%8E%B7%E5%8F%96%E7%8E%AF%E4%BF%A1%E5%8D%B3%E6%97%B6%E9%80%9A%E8%AE%AF-im-%E7%9A%84%E4%BF%A1%E6%81%AF
    static let appKey: String = ""
    
    //请参看文档  https://docs-im-beta.easemob.com/product/enable_and_configure_IM.html#%E5%88%9B%E5%BB%BA-im-%E7%94%A8%E6%88%B7
    static var chatToken: String = ""
    //   然后复制聊天室id在launchRoomView时使用
    
    /// `YourAppUser` 代表您App中的用户类.
    public final class YourAppUser: NSObject,UserInfoProtocol {
        public var identity: String = ""//user level picture url
        
        public func toJsonObject() -> Dictionary<String, Any>? {
            ["userId":self.userId,"nickname":self.nickname,"avatarURL":self.avatarURL,"identity":self.identity,"gender":self.gender]
        }
        
        //请参看文档  https://docs-im-beta.easemob.com/product/enable_and_configure_IM.html#%E5%88%9B%E5%BB%BA-im-%E7%94%A8%E6%88%B7
        public var userId: String = ""
        
        public var nickname: String = "Jack"
        
        public var avatarURL: String = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_1.png"
        
        public var gender: Int = 1
        
    }
}
