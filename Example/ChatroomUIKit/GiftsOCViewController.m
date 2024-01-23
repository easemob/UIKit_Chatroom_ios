//
//  GiftsOCViewController.m
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2024/1/23.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#import "GiftsOCViewController.h"
#define BottomSafeAreaHeight (UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0 ? 34:0)

@interface GiftsOCViewController ()<GiftsViewActionEventsDelegate>

@property (nonatomic, strong, readwrite) NSArray<id<GiftEntityProtocol>> *giftsSource;

@property (nonatomic, strong) GiftsView *giftContainer;

@end

@implementation GiftsOCViewController

- (instancetype)initWithGifts:(NSArray<id<GiftEntityProtocol>> *)gifts {
    if (self = [super init]) {
        _giftsSource = gifts;
    }
    return self;
}

- (id<GiftService>)giftService {
    return ChatroomUIKitClient.shared.roomService.giftService;
}

- (GiftsView *)giftContainer {
    if (!_giftContainer) {
        _giftContainer = [self giftsView];
    }
    return _giftContainer;
}

- (GiftsView *)giftsView {
    return [[GiftsView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-BottomSafeAreaHeight) gifts:self.dataSource];
}

- (NSArray<id<GiftEntityProtocol>> * _Nonnull)dataSource {
    return self.giftsSource;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.giftContainer];
    [self.giftContainer addActionHandlerWithActionHandler:self];
}


- (void)onGiftSelectedWithItem:(id<GiftEntityProtocol>)item {
    
}

- (void)onGiftSendClickWithItem:(id<GiftEntityProtocol>)item {
//    if ChatroomContext.shared?.muteMap?[ChatroomContext.shared?.currentUser?.userId ?? ""] ?? false {
//        UIViewController.currentController?.dismiss(animated: true) {
//            UIViewController.currentController?.showToast(toast: "You have been muted and are unable to send messages.".chatroom.localize, duration: 2,delay: 1)
//        }
//        return
//    }
    if ([ChatroomContext.shared.muteMap objectForKey:ChatroomContext.shared.currentUser.userId]) {
        UIViewController *currentController = [UIViewController currentController];
        [currentController showToastWithToast:[LanguageConvertor localValueWithKey:@"You have been muted and are unable to send messages."] duration:2 delay:0];
        return;
    }
    if (item.sentThenClose) {
        [[UIViewController currentController] dismissViewControllerAnimated:YES completion:nil];
    }
    [self.giftService sendGiftWithGift:item completion:^(EMChatMessage * _Nullable message, EMError * _Nullable error) {
        UIViewController *currentController = [UIViewController currentController];
        if (error != nil) {
            [currentController showToastWithToast:error.errorDescription duration:2 delay:0];
        } else {
            item.sendUser = ChatroomContext.shared.currentUser;
            GiftServiceImplement *implement = ((GiftServiceImplement *)self.giftService);
            [implement notifyGiftDriveShowSelfSendWithGift:item message:message];
        }
    }];
}

@end
