//
//  GiftsOCViewController.h
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2024/1/23.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ChatroomUIKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface GiftsOCViewController : UIViewController<GiftsViewControllerProtocol>

- (instancetype)initWithGifts:(NSArray<id<GiftEntityProtocol>> *)gifts;

@end

NS_ASSUME_NONNULL_END
