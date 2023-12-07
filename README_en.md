# [Sample Demo](https://github.com/zjc19891106/ChatroomUIKit#sample-demo)

In this project, there is a best practice demonstration project in the `Example` folder for you to build your own business capabilities.

To experience functions of the ChatroomUIKit, you can scan the following QR code to try a demo.

[![SampleDemo](https://github.com/zjc19891106/ChatroomUIKit/raw/main/Documentation/demo.png)](https://github.com/zjc19891106/ChatroomUIKit/blob/main/Documentation/demo.png).

# [ChatroomUIKit Guide](https://github.com/zjc19891106/ChatroomUIKit#chatroomuikit-guide)

## [Introduction](https://github.com/zjc19891106/ChatroomUIKit#introduction)

This guide presents an overview and usage examples of the ChatroomUIKit framework in iOS development, and describes various components and features of this UIKit, enabling developers to have a good understanding of the UIKit and make effective use of it.

## [Table of Contents](https://github.com/zjc19891106/ChatroomUIKit#table-of-contents)

- [Requirements](https://github.com/zjc19891106/ChatroomUIKit#requirements)
- [Installation](https://github.com/zjc19891106/ChatroomUIKit#installation)
- [Documentation](https://github.com/zjc19891106/ChatroomUIKit#documentation)
- [Structure](https://github.com/zjc19891106/ChatroomUIKit#structure)
- [Quick Start](https://github.com/zjc19891106/ChatroomUIKit#quick-start)
- [Precautions](https://github.com/zjc19891106/ChatroomUIKit#precautions)
- [Advanced Usage](https://github.com/zjc19891106/ChatroomUIKit#advanced-usage)
- [Customization](https://github.com/zjc19891106/ChatroomUIKit#customization)
- [BusinessFlowchart](https://github.com/zjc19891106/ChatroomUIKit#business-flowchart)
- [API Sequence Diagram](https://github.com/zjc19891106/ChatroomUIKit#api-sequence-diagram)
- [DesignGuidelines](https://github.com/zjc19891106/ChatroomUIKit#design-guidelines)
- [Contributing](https://github.com/zjc19891106/ChatroomUIKit#contributing)
- [License](https://github.com/zjc19891106/ChatroomUIKit#license)

# [Requirements](https://github.com/zjc19891106/ChatroomUIKit#requirements)

- iOS 13.0+
- Xcode 13.0+
- Swift 5.0+

# [Installation](https://github.com/zjc19891106/ChatroomUIKit#installation)

You can install ChatroomUIKit with the Swift Package Manager or CocoaPods as a dependency of your Xcode project.

## [Swift Package Manager](https://github.com/zjc19891106/ChatroomUIKit#swift-package-manager)

1. Open your project in Xcode.
2. Choose **File** > **Add Package**.
3. Search for **ChatroomUIKit** and select it.
4. Select the desired version.
5. Click **Add Package** to add the ChatroomUIKit.

## [CocoaPods](https://github.com/zjc19891106/ChatroomUIKit#cocoapods)

```
pod 'ChatroomUIKit'
```

# [Structure](https://github.com/zjc19891106/ChatroomUIKit#structure)

### [Basic Components of ChatroomUIKit](https://github.com/zjc19891106/ChatroomUIKit#basic-components-of-chatroomuikit)

```
ChatroomUIKit  
├─ Service                           // Basic service components.
│  ├─ Protocol                       // Business protocol component.    
│  │  ├─ GiftService                 // Gift sending and receiving channel.
│  │  ├─ UserService                 // Component for user login and user attribute update.
│  │  └─ ChatroomService             // Component for implementing the protocol for chat room management, including joining and leaving the chat room and sending and receiving messages.
│  ├─ Implement                      // Protocol implementation component. 
│  └─ Client                         // ChatroomUIKit initialization class.
│
└─ UI                                // Basic UI components without business.
   ├─ Resource                       // Image or localize file.
   ├─ Component                      // UI module containing specific business. Some functional UI components in chat room UIKit.
   │  ├─ Room                        // Container of all chat room subviews.
   │  ├─ Chat                        // The chat component and bottom functional area in the chat room.  
   │  ├─ Gift                        // Components such as the gift area and gift container in the chat room.
   │  └─ Input                       // Input components in chat rooms such as emoticons. 
   └─ Core
      ├─ UIKit                       // Some common UIKit components and custom components. 
      ├─ Theme                       // Theme-related components, including colors, fonts, skinning protocols and their components. 
      └─ Extension                   // Some convenient system class extensions.  
```



# [Documentation](https://github.com/zjc19891106/ChatroomUIKit#documentation)

## [Document](https://github.com/zjc19891106/ChatroomUIKit/tree/main/Documentation/ChatroomUIKit.doccarchive)

You can open the `ChatroomUIKit.doccarchive` file in Xcode to view files in it or deploy this file to your homepage.

Also, you can right-click the file to show the package contents and copy all files inside to a folder. Then drag this folder to the `terminal` app and run the following command to deploy it on the local IP address.

```
python3 -m http.server 8080
```

After deployment, you can visit `http://yourlocalhost:8080/documentation/chatroomuikit` in your browser, where `yourlocalhost` is your local IP address. Alternatively, you can deploy this folder on an external network address.

## [Appearance](https://github.com/zjc19891106/ChatroomUIKit/tree/main/Documentation/Appearance.md).

Detailed descriptions of available items in the `UI` component.

## [ComponentRegister](https://github.com/zjc19891106/ChatroomUIKit/tree/main/Documentation/ComponentRegister.md).

UI components that can be inherited for customization.

## [GiftsViewController](https://github.com/zjc19891106/ChatroomUIKit/blob/main/Documentation/GiftsViewController.md)

A container that contains a gift list. You can inherit this class to implement additional UI definitions and business processing. After you click the **Send** button to deliver a gift, you can decide whether to close the gift pop-up window and call the gift API in your business on your server to send the gift message to the chat room.

# [Quick Start](https://github.com/zjc19891106/ChatroomUIKit#quick-start)

This guide provides several usage examples for different ChatroomUIKit components. Refer to the `Examples` folder for detailed code snippets and projects showing various use cases.

Refer to the following steps to create an iOS platform App in Xcode. The creation settings are as follows:

- Product Name: Fill in **ChatroomUIKitQuickStart**.
- Organization Identifier: Fill in your identifier.
- User Interface: Select **Storyboard**.
- Language: You common development language.

### [Step 1: Initialize ChatroomUIKit](https://github.com/zjc19891106/ChatroomUIKit#step-1-initialize-chatroomuikit)

```
import UIKit
import ChatroomUIKit
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // You can initialize the ChatroomUIKit when the app loads or before you use it. 
        // You need to pass in the App Key. 
        // To get the App Key, visit https://docs.agora.io/en/agora-chat/get-started/enable?platform=android#get-chat-project-information.  
        ChatroomUIKitClient.shared.setup(with: "Appkey")
        return true
    }
}
```

### [Step 2: Log in to the ChatroomUIKit](https://github.com/zjc19891106/ChatroomUIKit#step-2-log-in-to-the-chatroomuikit)

```
// Log in to the ChatroomUIKit with the user information of the current user object that conforms to the `UserInfoProtocol` protocol.
// The token needs to be obtained from your app server. You can also log in with a temporary token generated on the Agora Console.
// To generate a user and a temporary user token on the Agora Console, see https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios#manage-users-and-generate-tokens.
ChatroomUIKitClient.shared.login(with userId: "user id", token: "token", completion: <#T##(ChatError?) -> Void#>)
```

### [Step 3: Create a chat room view](https://github.com/zjc19891106/ChatroomUIKit#step-3-create-a-chat-room-view)

```
// 1. Get a chat room list and join a chat room. Alternatively, create a chat room on the Agora Console.
// Choose Project Management > Operation Management > Chat Room and click Create Chat Room and set parameters in the displayed dialog box to create a chat room. Get the chat room ID to pass it to the following `launchRoomView` method.
// 2. Create a chat room view with `ChatroomView` by passing in parameters such as layout parameters and the array of extension button model protocols of the bottom toolbar.
// It is recommended that the width of ChatroomView should be initialized as the width of the screen and the height should be no less than the height of the screen minus the height of the navigation.
let roomView = ChatroomUIKitClient.shared.launchRoomViewWithOptions(roomId: self.room?.chatroomId ?? "", frame: CGRect(x: 0, y: self.playView.frame.maxY, width: self.view.frame.width, height: 336+BottomBarHeight), ownerId: "Chatroom's owner user id")        
// 3. Add to the destination frame. 
// 4. Add users to the chat room on the Console.
// Choose ProjectManager > Operation Manager > Chat Room. Select View Chat Room Members in the Action column of a chat room and add users to the chat room in the displayed dialog box.  
```

[![CreateChatroom](https://github.com/zjc19891106/ChatroomUIKit/raw/main/Documentation/CreateChatroom.png)](https://github.com/zjc19891106/ChatroomUIKit/blob/main/Documentation/CreateChatroom.png).

Please refer to the next chapter for transparent transmission of events.

# [Precautions](https://github.com/zjc19891106/ChatroomUIKit#precautions)

When calling `ChatroomUIKitClient.shared.launchRoomView(roomId: String, frame: CGRect, is owner: Bool)`, remember to add ChatroomView above your existing view to facilitate interception and transparent transmission of click events.

For example, if you have a view that plays video streams, be sure to add ChatroomView above this view.

# [Advanced Usage](https://github.com/zjc19891106/ChatroomUIKit#advanced-usage)

Here are three examples of advanced usage.

### [1.Log in to ChatroomUIKit](https://github.com/zjc19891106/ChatroomUIKit#1log-in-to-chatroomuikit)

```
class YourAppUser: UserInfoProtocol {
    var userId: String = "your application user id"
            
    var nickName: String = "Your user nick name"
            
    var avatarURL: String = "Your user avatar url"
            
    var gender: Int = 1
            
    var identity: String =  "Your user level symbol url"
            
}
// Use the user information of the current user object that conforms to the UserInfoProtocol protocol to log in to ChatroomUIKit.
// You need to get a user token from your app server. Alternatively, you can use a temporary token. To generate a temporary token, visit https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios#generate-a-user-token.
ChatroomUIKitClient.shared.login(with: YourAppUser(), token: "token", completion: <#T##(ChatError?) -> Void#>)
```

### [2.Initialize the chat room view](https://github.com/zjc19891106/ChatroomUIKit#2initialize-the-chat-room-view)

```
//1. Get a chat room list and join a chat room. Alternatively, create a chat room on the Agora Console.
// 2. Create a chat room view with `ChatroomView` by passing in parameters such as layout parameters and the array of extension button model protocols of the bottom toolbar.
    let options  = ChatroomUIKitInitialOptions.UIOptions()
    options.bottomDataSource = self.bottomBarDatas()
    options.showGiftMessageArea = true
    options.chatAreaShowGift = false
    ChatroomUIKitClient.shared.launchRoomViewWithOptions(roomId: self.room?.chatroomId ?? "", frame: CGRect(x: 0, y: self.playView.frame.maxY, width: self.view.frame.width, height: 336+BottomBarHeight), ownerId: self.room?.owner ?? "",options: options)        
//3. Add to the destination frame. 
```

### [3.Listen for ChatroomUIKit events and errors](https://github.com/zjc19891106/ChatroomUIKit#3listen-for-chatroomuikit-events-and-errors)

You can call the `registerRoomEventsListener` method to listen for ChatroomUIKit events and errors.

```
ChatroomUIKitClient.shared.registerRoomEventsListener(listener: self)
```

# [Customization](https://github.com/zjc19891106/ChatroomUIKit#customization)

### [1.Modify configurable items](https://github.com/zjc19891106/ChatroomUIKit#1modify-configurable-items)

The following shows how to change the overall cell layout style of the chat area and how to create the ChatroomView.

```
// You can change the overall cell layout style of the chat area by setting the properties.
Appearance.ChatMessageDisplayContentStyle = .all
// Create the ChatroomView by passing in parameters like layout parameters and the bottom toolbar extension button model protocol array.
let roomView = ChatroomUIKitClient.shared.launchRoomViewWithOptions(roomId: self.room?.chatroomId ?? "", frame: CGRect(x: 0, y: self.playView.frame.maxY, width: self.view.frame.width, height: 336+BottomBarHeight), ownerId: self.room?.owner ?? "")
self.view.addSubView(roomView)
```

For details, see [Appearance](https://github.com/zjc19891106/ChatroomUIKit/blob/main/Documentation/Appearance.md).

### [2.Customize components](https://github.com/zjc19891106/ChatroomUIKit#2customize-components)

The following shows how to customize the gift message cell.

```
class CustomGiftMessageCell: GiftMessageCell {
    lazy var redDot: UIView = {
        UIView().backgroundColor(.red).cornerRadius(.large)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(redDot)
    }
    
    override func refresh(item: GiftEntityProtocol) {
        super.refresh(item: item)
        self.redDot.isHidden = item.selected
    }
}
//Register the custom class that inherits the original class in ChatroomUIKit to replace the original one.
//Call this method before creating a ChatroomView or using other UI components.
ComponentsRegister.shared.GiftMessagesViewCell = CustomGiftMessageCell.self
```

For details, see [ComponentsRegister](https://github.com/zjc19891106/ChatroomUIKit/blob/main/Documentation/ComponentsRegister.md).

### [3.Switch to the original or custom theme](https://github.com/zjc19891106/ChatroomUIKit#3switch-to-the-original-or-custom-theme)

- Switch to the light or dark theme that comes with the ChatroomUIKit.

```
Theme.switchTheme(style: .dark)` or `Theme.switchTheme(style: .light)
```

- Switch to a custom theme.

```
/**
How to customize a theme?

To customize a theme, you need to define the hue values of the following five theme colors by reference to the theme color of the design document.

All colors in ChatroomUIKit are defined with the HSLA color model that is a way of representing colors using hue, saturation, lightness, and alpha. 

H (Hue): Hue, the basic attribute of color, is a degree on the color wheel from 0 to 360. 0 is red, 120 is green, and 240 is blue.

S (Saturation): Saturation is the intensity and purity of a color. The higher the saturation is, the brighter the color is; the lower the saturation is, the closer the color gets to gray. Saturation is represented by a percentage value, ranging from 0% to 100%. 0% means a shade of gray, and 100% is the full color.

L (Lightness): Lightness is the brightness or darkness of a color. The higher the brightness is, the brighter the color is; the lower the brightness is, the darker the color is. Lightness is represented by a percentage value, ranging from 0% to 100%. 0% indicates a black color and 100% will result in a white color.

A (Alpha): Alpha is the transparency of a color. The value 1 means fully opaque and 0 is fully transparent.

By adjusting the values of individual components of the HSLA model, you can achieve precise color control.
 */
Appearance.primaryHue = 191/360.0
Appearance.secondaryHue = 210/360.0
Appearance.errorHue = 189/360.0
Appearance.neutralHue = 191/360.0
Appearance.neutralSpecialHue = 199/360.0
Theme.switchTheme(style: .custom)
```

Note that custom themes and built-in themes are mutually exclusive.

# [Business Flowchart](https://github.com/zjc19891106/ChatroomUIKit#business-flowchart)

The following figure presents the entire logic of business requests and callbacks.

[![Overall flow diagram of business logic](https://github.com/zjc19891106/ChatroomUIKit/raw/main/Documentation/BusinessFlowchart.png)](https://github.com/zjc19891106/ChatroomUIKit/raw/main/Documentation/BusinessFlowchart.png)

# [API Sequence Diagram](https://github.com/zjc19891106/ChatroomUIKit#api-sequence-diagram)

The following figure is the best-practice API calling sequence diagram in the `Example` project.

[![APIUML](https://github.com/zjc19891106/ChatroomUIKit/raw/main/Documentation/Api.png)](https://github.com/zjc19891106/ChatroomUIKit/raw/main/Documentation/Api.png)

# [Design Guidelines](https://github.com/zjc19891106/ChatroomUIKit#design-guidelines)

For any questions about design guidelines and details, you can add comments to the Figma design draft and mention our designer Stevie Jiang.

See the [UI design drawing](https://www.figma.com/file/OX2dUdilAKHahAh9VwX8aI/Streamuikit?node-id=137%3A38589&mode=dev).

See the [UI design guidelines](https://www.figma.com/file/OX2dUdilAKHahAh9VwX8aI/Streamuikit?node-id=137)

# [Contributing](https://github.com/zjc19891106/ChatroomUIKit#contributing)

Contributions and feedback are welcome! For any issues or improvement suggestions, you can open an issue or submit a pull request.

## [Author](https://github.com/zjc19891106/ChatroomUIKit#author)

zjc19891106, [984065974@qq.com](mailto:984065974@qq.com)

## [License](https://github.com/zjc19891106/ChatroomUIKit#license)

ChatroomUIKit is available under the MIT license. See the LICENSE file for more information.