# [GiftsViewController](https://github.com/zjc19891106/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Components/Gift/Controllers/GiftsViewController.swift)

这是一个礼物容器Controller。您可以继承这个类在发送礼物之后调用您服务器的送礼api成功后再去调用`GiftsViewController`中原有的发送礼物消息到聊天室的api，并在可以在发送一些大额礼物的时候决定是否让礼物容器收起并展示礼物特效。礼物特效的话我们推荐腾讯的libpag动效库。

## 1. 如何添加额外的UI?

您可以在礼物列表上面或者下面添加您的自定义view.

## 2. 如何在单个礼物上加一些标识?

您可以集成`GiftEntityCell`后，新增UI属性，在调用`super init`后添加在UI上，重载`refresh`方法并调用`super.refresh`后进行您的新增UI的刷新.
