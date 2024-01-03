# Appearance

# 可配项修改

Appearance.swift 是容纳了所有可配项的类，您需要在初始化ChatroomView之前修改它里面的属性.

## 可配项

1. [Appearance.pageContainerTitleBarItemWidth](https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Core/UIKit/Utils/Appearance.swift). 修改它可以改变PageContainerTitleBar的单个条目宽度.

![位置示意图](./pageContainerTitleBarItemWidth.png).


2. [Appearance.giftDialogContainerConstraintsSize](https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Core/UIKit/Utils/Appearance.swift).修改它可以改变整个PageContainer弹窗的整体Size

![位置示意图](pageContainerTitleBarItemWidth.png).


3. [Appearance.giftContainerConstraintsSize](https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Core/UIKit/Utils/Appearance.swift).修改它可以改变礼物弹窗的整体大小

![位置示意图](giftContainerConstraintsSize.png).


4. [Appearance.messageDisplayStyle](https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Core/UIKit/Utils/Appearance.swift).修改它可以选择弹幕区域Cell的展示样式，前三项可以隐藏。

![位置示意图](custom%20chat%20barrage.png).


5. [Appearance.emojiMap](https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Components/Input/Convertor/ChatEmojiConvertor.swift).如果您想替换全部的表情可以改变这个map，key按照既定的key，value可以传入不同的image图片。

![位置示意图](custom%20chat%20barrage.png).


6. [Appearance.targetLanguage](https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Core/UIKit/Utils/LanguageConvertor.swift).您可以根据您用户的设备的语言环境设置对应的目标翻译语言，前提是需要在环信控制台开通翻译功能，目前聊天室UIKit内置支持中文简繁，英文，俄语，德语，法语，日语，韩语。


7. `Appearance.defaultMessageActions`.长按消息后弹起弹窗的数据源，您可以进行一定配置。

![位置示意图](messageActions.png).


8. `Appearance.defaultOperationUserActions`.成员列表中owner对普通成员的操作项，可以进行配置.

![位置示意图](moreAction.png).


9. ``Appearance.actionSheetRowHeight``.ActionSheet单行高度.

![位置示意图](messageActions.png).


10. ``Appearance.giftPlaceHolder``.礼物默认图

![位置示意图](giftPlaceHolder.png).


11. [Appearance.avatarPlaceHolder](https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Components/Chat/Cells/ChatMessageCell.swift).头像默认图

![位置示意图](avatarPlaceHolder.png)


12. [Appearance.userIdentifyPlaceHolder]((https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Components/Chat/Cells/ChatMessageCell.swift)).用户身份标识默认图

![位置示意图](userIdentifyPlaceHolder.png)


13. ``Appearance.notifyMessageIcon``.全局广播通知左侧icon默认图

![位置示意图](notifyMessageIcon.png)


14. [Appearance.maxInputHeight](https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Components/Input/Views/MessageInputBar.swift).输入框最大高度

![位置示意图](maxInputHeight.png)


15. [Appearance.inputPlaceHolder](https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Components/Input/Views/MessageInputBar.swift).输入框默认显示文字

![位置示意图](inputCorner.png) 默认是 Aa.


17. [Appearance.inputBarCorner](https://github.com/easemob/UIKit_Chatroom_ios/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Components/Input/Views/MessageInputBar.swift).

![位置示意图](inputCorner.png) 圆角默认是最大也就是高度一半.


18. ``Appearance.reportTags``.消息举报弹窗内中举报项，可配置。

![位置示意图](report.png)
