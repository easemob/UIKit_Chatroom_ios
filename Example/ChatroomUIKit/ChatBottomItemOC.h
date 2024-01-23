//
//  ChatBottomItemOC.h
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2024/1/23.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ChatroomUIKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatBottomItemOC : NSObject<ChatBottomItemProtocol>

@property (nonatomic, copy) void (^action)(id <ChatBottomItemProtocol> item);
@property (nonatomic, assign) BOOL showRedDot;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END
