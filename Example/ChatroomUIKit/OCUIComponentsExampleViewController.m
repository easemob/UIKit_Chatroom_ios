//
//  OCExampleViewController.m
//  ChatroomUIKit_Example
//
//  Created by 朱继超 on 2023/8/31.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

#import "OCUIComponentsExampleViewController.h"
#import <ChatroomUIKit-Swift.h>
#import "ChatBottomItemOC.h"
#import "GiftsOCViewController.h"

#define BottomSafeAreaHeight (UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0 ? 34:0)

@interface OCUIComponentsExampleViewController ()<GiftMessageListTransformAnimationDataSource,MessageListActionEventsHandler,BottomAreaToolBarActionEvents>

@property (nonatomic, strong) NSHashTable<ChatroomViewActionEventsDelegate> *eventHandlers;
@property (nonatomic, strong) GlobalBoardcastView *carouselTextView;
@property (nonatomic, strong) GiftMessageList *giftArea;
@property (nonatomic, strong) MessageList *chatList;
@property (nonatomic, strong) BottomAreaToolBar *bottomBar;
@property (nonatomic, strong) MessageInputBar *inputBar;

@property (nonatomic, strong) NSString *roomId;
@end

@implementation OCUIComponentsExampleViewController

- (instancetype)initWithRoomId:(NSString *)roomId ownerId:(nonnull NSString *)ownerId {
    if (self = [super init]) {
        self.roomId = roomId;
        ChatroomContext.shared.roomId = roomId;
        ChatroomContext.shared.ownerId = ownerId;
        ChatroomUIKitClient.shared.roomService = [[RoomService alloc] initWithRoomId:self.roomId];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    background.image = [UIImage imageNamed:@"background_light"];
    [self.view addSubview:background];
    
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.carouselTextView];
    [self.view addSubview:self.self.giftArea];
    [self.view addSubview:self.chatList];
    [self.view addSubview:self.bottomBar];
    [self.view addSubview:self.inputBar];
    
//    CGRect(x: 100, y: 160, width: 150, height: 20)
    UIButton *members = [[UIButton alloc] initWithFrame:CGRectMake(100, 160, 150, 20)];
    members.backgroundColor = [UIColor orangeColor];
    [members addTarget:self action:@selector(showMembers) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:members];
    
    [self viewActions];
    
    [self connectService];
}

- (void)showMembers {
    __weak typeof(self) weakSelf = self;
    [DialogManager.shared showParticipantsDialogWithMoreClosure:^(id<UserInfoProtocol> _Nonnull user) {
        [weakSelf handleUserActionWithUser:user muteTab:NO];
    } muteMoreClosure:^(id<UserInfoProtocol> _Nonnull user) {
        [weakSelf handleUserActionWithUser:user muteTab:YES];
    }];
}

- (void)handleUserActionWithUser:(id<UserInfoProtocol>)user muteTab:(BOOL)muteTab {
    NSArray *actions = muteTab ? [Appearance defaultOperationMuteUserActions] : [Appearance defaultOperationUserActions];
    [DialogManager.shared showWithUserActions:actions action:^(id<ActionSheetItemProtocol> _Nonnull item, id _Nullable object) {
        if ([item.tag isEqualToString:@"Mute"]) {
            [ChatroomUIKitClient.shared.roomService muteUserWithId:user.userId completion:^(EMError * _Nullable error) {
                NSString *toast;
                if (error == nil) {
                    toast = @"禁言成功";
                } else {
                    toast = error.errorDescription;
                }
                [[UIViewController currentController] showToastWithToast:toast duration:2 delay:0];
            }];
        }
        if ([item.tag isEqualToString:@"unMute"]) {
            [ChatroomUIKitClient.shared.roomService unmuteUserWithId:user.userId completion:^(EMError * _Nullable error) {
                NSString *toast;
                if (error == nil) {
                    toast = @"解除禁言成功";
                } else {
                    toast = error.errorDescription;
                }
                [[UIViewController currentController] showToastWithToast:toast duration:2 delay:0];
            }];
        }
        if ([item.tag isEqualToString:@"Remove"]) {
            NSString *memberName = [user.nickname isEqualToString:@""] ? user.userId:user.nickname;
            [DialogManager.shared showAlertWithContent:[NSString stringWithFormat:@"确定删除`%@`？",memberName] showCancel:YES showConfirm:YES title:@"" confirmClosure:^{
                [ChatroomUIKitClient.shared.roomService kickUserWithId:user.userId completion:^(EMError * _Nullable error) {
                    NSString *toast;
                    if (error == nil) {
                        toast = @"踢出成功";
                    } else {
                        toast = error.errorDescription;
                    }
                    [[UIViewController currentController] showToastWithToast:toast duration:2 delay:0];
                }];
            }];
        }
    }];
//case "Mute":
//    ChatroomUIKitClient.shared.roomService?.mute(userId: user.userId, completion: { [weak self] error in
//        guard let `self` = self else { return }
//        if error == nil {
////                        self.removeUser(user: user)
//        } else {
//            self.showToast(toast: "\(error?.errorDescription ?? "")",duration: 3)
//        }
//    })
//case "unMute":
//    ChatroomUIKitClient.shared.roomService?.unmute(userId: user.userId, completion: { [weak self] error in
//        guard let `self` = self else { return }
//        if error == nil {
////                        self.removeUser(user: user)
//        } else {
//            self.showToast(toast: "\(error?.errorDescription ?? "")", duration: 3)
//        }
//    })
//case "Remove":
//    DialogManager.shared.showAlert(content: "删除 `\(user.nickname.isEmpty ? user.userId:user.nickname)`.确定?", showCancel: true, showConfirm: true) {
//        ChatroomUIKitClient.shared.roomService?.kick(userId: user.userId) { [weak self] error in
//            guard let `self` = self else { return }
//            if error == nil {
////                            self.removeUser(user: user)
//                self.showToast(toast: error == nil ? "删除成功":"\(error?.errorDescription ?? "")",duration: 2)
//            } else {
//                self.showToast(toast: "\(error?.errorDescription ?? "")", duration: 3)
//            }
//        }
//    }
}


- (void)viewActions {
    __weak typeof(self) weakSelf = self;
    [self.inputBar setSendClosure:^(NSString * _Nonnull text) {
        [weakSelf sendTextMessage:text];
    }];
    
    [self.chatList addActionHandlerWithActionHandler:self];
    [self.bottomBar addActionHandlerWithActionHandler:self];
}

- (GlobalBoardcastView *)carouselTextView {
    if (!_carouselTextView) {
        _carouselTextView = [[GlobalBoardcastView alloc] initWithOriginPoint:Appearance.notifyMessageOriginPoint width:CGRectGetWidth(self.view.frame)-40 font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] hiddenIcon:NO];
        _carouselTextView.backgroundColor = [UIColor clearColor];
        _carouselTextView.alpha = 0;
    }
    return _carouselTextView;
}

- (GiftMessageList *)giftArea {
    if (!_giftArea) {
        CGRect frame = CGRectMake(10, self.view.center.y, CGRectGetWidth(self.view.frame)/2.0+60, Appearance.giftAreaRowHeight*2);
        _giftArea = [[GiftMessageList alloc] initWithFrame:frame source:self];
        _giftArea.backgroundColor = [UIColor clearColor];
    }
    return _giftArea;
}

- (MessageList *)chatList {
    if (!_chatList) {
        _chatList = [[MessageList alloc] initWithFrame:CGRectMake(0, ChatroomUIKitClient.shared.option.option_UI.showGiftMessageArea ? CGRectGetMaxY(self.giftArea.frame)+5:self.view.center.y, CGRectGetWidth(self.view.frame)-50, self.view.center.y-54-BottomSafeAreaHeight-5-(ChatroomUIKitClient.shared.option.option_UI.showGiftMessageArea ? (Appearance.giftAreaRowHeight*2):0))];
        _chatList.backgroundColor = [UIColor clearColor];
    }
    return _chatList;
}

- (BottomAreaToolBar *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[BottomAreaToolBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-BottomSafeAreaHeight-54, CGRectGetWidth(self.view.frame), 54) datas:[self bottomBarDatas]];
    }
    return _bottomBar;
}

- (MessageInputBar *)inputBar {
    if (!_inputBar) {
        _inputBar = [[MessageInputBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame), CGRectGetWidth(self.view.frame), 52) text:@"" placeHolder:@"跟主播聊聊"];
    }
    return _inputBar;
}

- (NSArray<id<ChatBottomItemProtocol>> *)bottomBarDatas { NSMutableArray<id<ChatBottomItemProtocol>> *entities = [NSMutableArray array]; 
    NSArray *names = @[@"ellipsis_vertical", @"gift"];
    for (int i = 0; i <= names.count-1; i++) {
        ChatBottomItemOC *entity = [[ChatBottomItemOC alloc] init];
        entity.showRedDot = NO;
        entity.selected = NO;
        entity.selectedImage = [UIImage imageNamed:names[i]];
        entity.normalImage = [UIImage imageNamed:names[i]];
        entity.type = i; [entities addObject:entity];
    }
    return entities;
}

- (NSArray<GiftEntityProtocol> *)gifts {
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"Gifts" withExtension:@"json"];
    NSMutableDictionary<NSString *, id> *data = [NSMutableDictionary dictionary];


    NSData *jsonData = [NSData dataWithContentsOfURL:path];
    if (jsonData) {
        NSError *error;
        data = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription); 
            return @[];
        }
    }


    NSArray<NSDictionary<NSString *, id> *> *jsons = data[@"gifts"];
    if (jsons && [jsons isKindOfClass:[NSArray class]]) {
        NSMutableArray<GiftEntityProtocol> *result = [NSMutableArray array];
        for (NSDictionary<NSString *, id> *json in jsons) {
            GiftEntity *entity = [[GiftEntity alloc] init];
            [entity setValuesForKeysWithDictionary:json];
            [result addObject:entity];
        }
        return result;
    }

    return @[];

}

- (void)sendTextMessage:(NSString *)text {
    [ChatroomUIKitClient.shared.roomService.roomService sendMessageWithText:text roomId:self.roomId completion:^(EMChatMessage * _Nonnull message, EMError * _Nullable error) {
        if (error == nil) {
            [self.chatList showWithNewMessage:message gift:nil];
        } else {
            NSString *errorInfo = [NSString stringWithFormat:@"Send message failure!\n%@", error.errorDescription];
            NSLog(@"send message error:%@",errorInfo);
        }
    }];

}

- (void)connectService{
    [ChatroomUIKitClient.shared.roomService bindChatDriver:self.chatList];
    //如果要显示礼物区域在弹幕区域上方需要绑定这个
    if (ChatroomUIKitClient.shared.option.option_UI.showGiftMessageArea) {
        [ChatroomUIKitClient.shared.roomService bindGiftDriver:self.giftArea];
    }
    
    [ChatroomUIKitClient.shared.roomService bindChatDriver:self.chatList];
    [ChatroomUIKitClient.shared.roomService bindGlobalNotifyDriverWithDriver:self.carouselTextView];
    [ChatroomUIKitClient.shared.roomService enterRoomWithCompletion:^(EMError * _Nullable error) {
        if (error) {
            NSLog(@"enter room error code:%ld reason:%@",(long)error.code,error.errorDescription);
        }
    }];
    
}

- (void)disconnectService {
    __weak typeof(self) weakSelf = self;
    [ChatroomUIKitClient.shared.roomService leaveRoomWithCompletion:^(EMError * _Nullable error) {
        if (error != nil) {
            if (error == nil) {
                ChatroomUIKitClient.shared.roomService = nil;
            } else {
                NSLog(@"SDK leave chatroom failure!\nError:%@", error.errorDescription);
            }
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.inputBar hiddenInputBar];
}

#pragma mark - GiftMessageListTransformAnimationDataSource

- (CGFloat)rowHeight {
    return Appearance.giftAreaRowHeight;
}

#pragma mark - MessageListActionEventsHandler

- (void)onMessageLongPressedWithMessage:(EMChatMessage *)message {
    __weak typeof(self) weakSelf = self;
    
    [DialogManager.shared showWithMessageActions:[self filterMessageActionsWithMessage:message] action:^(id<ActionSheetItemProtocol> _Nonnull item, id _Nullable object) {
        [weakSelf processMessageLongPressedActions:item message:message object:object];
    }];
}

- (void)processMessageLongPressedActions:(ActionSheetItem *)item message:(EMChatMessage *)message object:(id _Nullable)object {
    if ([item.tag isEqualToString:@"Translate"]) {
        [ChatroomUIKitClient.shared.roomService translateWithMessage:message completion:^(EMError * _Nullable error) {
            if (error != nil) {
                NSLog(@"translate message error:%@",error.errorDescription);
            }
        }];
    }
    if ([item.tag isEqualToString:@"Recall"]) {
        [ChatroomUIKitClient.shared.roomService recallWithMessage:message completion:^(EMError * _Nullable error) {
            if (error != nil) {
                NSLog(@"recall message error:%@",error.errorDescription);
            }
        }];
    }
    if ([item.tag isEqualToString:@"Mute"]) {
        [ChatroomUIKitClient.shared.roomService muteUserWithId:message.from completion:^(EMError * _Nullable error) {
            if (error != nil) {
                NSLog(@"mute user error:%@",error.errorDescription);
            }
        }];
    }
    if ([item.tag isEqualToString:@"unMute"]) {
        [ChatroomUIKitClient.shared.roomService unmuteUserWithId:message.from completion:^(EMError * _Nullable error) {
            if (error != nil) {
                NSLog(@"unmute user error:%@",error.errorDescription);
            }
        }];
    }
    if ([item.tag isEqualToString:@"Report"]) {
        [DialogManager.shared showReportDialogWithMessage:message errorClosure:^(EMError * _Nullable error) {
            if (error != nil) {
                NSLog(@"report message error:%@",error.errorDescription);
            }
        }];        
    }
}

- (NSArray<ActionSheetItem*> *)filterMessageActionsWithMessage:(EMChatMessage *)message {
    if (message.body.type == EMMessageBodyTypeCustom) {
        return @[];
    }
    NSString *currentUser = ChatroomContext.shared.currentUser.userId ?: @"";
    NSMutableArray<ActionSheetItemProtocol> *messageActions = [NSMutableArray<ActionSheetItemProtocol> array];
    [messageActions addObjectsFromArray:Appearance.defaultMessageActions];
    if (ChatroomContext.shared.owner) {
        NSDictionary<NSString *, NSNumber *> *map = ChatroomContext.shared.muteMap;
        NSNumber *mute = map[message.from];
        if (map != nil && [map allKeys].count > 0) {
            int muteIndex = -1;
            int unmuteIndex = -1;
            for (int i = 0; i < messageActions.count; i++)
            {
                ActionSheetItem *item = messageActions[i];
                if ([item.tag isEqualToString:@"Mute"]) {
                    muteIndex = i;
                }
                if ([item.tag isEqualToString:@"unMute"]) {
                    unmuteIndex = i;
                }
            }
            if (muteIndex > -1) {
                ActionSheetItem *item = [[ActionSheetItem alloc] initWithTitle:[LanguageConvertor localValueWithKey:@"barrage_long_press_menu_unmute"] type:ActionSheetItemTypeNormal tag:@"unMute"];
                [messageActions replaceObjectAtIndex:muteIndex withObject:item];
            }
            if (unmuteIndex > -1) {
                ActionSheetItem *item = [[ActionSheetItem alloc] initWithTitle:[LanguageConvertor localValueWithKey:@"barrage_long_press_menu_mute"] type:ActionSheetItemTypeNormal tag:@"Mute"];
                [messageActions replaceObjectAtIndex:unmuteIndex withObject:item];
            }
        } else {
            int unmuteIndex = -1;
            ActionSheetItem *muteItem;
            for (int i = 0; i < messageActions.count; i++)
            {
                ActionSheetItem *item = messageActions[i];
                if ([item.tag isEqualToString:@"unMute"]) {
                    unmuteIndex = i;
                }
                if ([item.tag isEqualToString:@"Mute"]) {
                    muteItem = item;
                }
            }
            if (unmuteIndex > 0) {
                ActionSheetItem *item = [[ActionSheetItem alloc] initWithTitle:[LanguageConvertor localValueWithKey:@"barrage_long_press_menu_mute"] type:ActionSheetItemTypeNormal tag:@"Mute"];
                [messageActions replaceObjectAtIndex:unmuteIndex withObject:item];
            } else {
                if (muteItem == nil) {
                    ActionSheetItem *item = [[ActionSheetItem alloc] initWithTitle:[LanguageConvertor localValueWithKey:@"barrage_long_press_menu_unmute"] type:ActionSheetItemTypeNormal tag:@"Mute"];
                    [messageActions insertObject:item atIndex:2];
                }
            }
        }
            
    } else {
        int muteIndex = -1;
        int unmuteIndex = -1;
        for (int i = 0; i < messageActions.count; i++)
        {
            ActionSheetItem *item = messageActions[i];
            if ([item.tag isEqualToString:@"Mute"]) {
                muteIndex = i;
            }
            if ([item.tag isEqualToString:@"unMute"]) {
                unmuteIndex = i;
            }
        }
        if (muteIndex > 0) {
            [messageActions removeObjectAtIndex:muteIndex];
        }
        if (unmuteIndex > 0) {
            [messageActions removeObjectAtIndex:unmuteIndex];
        }
    }

    if ([currentUser isEqualToString:message.from]) {
        int muteIndex = -1;
        int recallIndex = -1;
        for (int i = 0; i < messageActions.count; i++)
        {
            ActionSheetItem *item = messageActions[i];
            if ([item.tag isEqualToString:@"Mute"]) {
                muteIndex = i;
            }
            if ([item.tag isEqualToString:@"Recall"]) {
                recallIndex = i;
            }
        }
        if (muteIndex > 0) {
            [messageActions removeObjectAtIndex:muteIndex];
        }
        if (recallIndex > 0 && ![[message.from lowercaseString] isEqualToString:[currentUser lowercaseString]]) {
            [messageActions removeObjectAtIndex:recallIndex];
        }
    }
    return messageActions;
}

- (void)onMessageClickedWithMessage:(EMChatMessage *)message {
    
}

- (void)onBottomItemClickedWithItem:(id<ChatBottomItemProtocol> _Nonnull)item { 
    if (item.type == 1) {
        GiftsOCViewController *vc= [[GiftsOCViewController alloc] initWithGifts:[self gifts]];
        [DialogManager.shared showGiftsDialogWithTitles:@[[LanguageConvertor localValueWithKey:@"Gifts"]] gifts:@[vc]];
    }
}

- (void)onKeyboardWillWakeup { 
    [self.inputBar show];
}



@end



