# ChatroomUIKit Example 详解

## 1. ExampleRequiredConfig

- 说明：此类是运行ChatroomUIKit Example所必须的配置类，主要包括了ChatroomUIKit的初始化配置和登录配置。

## 2. ExamplesViewController

- 说明：此类是ChatroomUIKit Example的入口类，主要包括了ChatroomUIKit的中几种情况的示例。

- UIComponentsExampleViewController为ChatroomUIKit中纯UI组件的使用示例，支持一些样式的配置以及换肤能力。

- UIWithBusinessViewController是在配置了ExampleRequiredConfig中对应的appkey、token、用户信息，以及在控制台创建聊天室后带有的整体业务演示，此类中是正确的ChatroomUIKit使用示例

- OCUIComponentsExampleViewController是为了标明ChatroomUIKit支持OC中使用（但是ChatroomUIKit中的Swift类不支持OC继承）。

## 3.MineGiftsViewController

- 说明：此类为继承UIKit中的礼物弹窗页面后，如何处理点击礼物发送按钮点击事件等的示例。


其余使用示例说明详见代码注释。
