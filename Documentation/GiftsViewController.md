# [GiftsViewController](https://github.com/zjc19891106/ChatroomUIKit/blob/main/Sources/ChatroomUIKit/Classes/UI/Components/Gift/Controllers/GiftsViewController.swift)

This is a container containing a gift list. You can inherit this class to implement additional UI definitions and business processing. After clicking the Send button, decide whether to close the gift pop-up window after a gift is delivered to display some animation effects and display special effects. It is recommended to use Tencent libpag, or go to the server to call the gift interface in your business, and then send the gift message to the chat room after the call is successful.

## 1. How to add other operation UI under the gift list?

You can add your new UI below the gift list and change the layout size of the gift list.

## 2. How to make your own business request first when clicking the gift button?

You can inherit GiftsViewController and overload the ``GiftsViewController.onGiftSendClick`` method. You can refer to the implementation logic of the previous class, but do not call super to handle your own business here.