
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 * Tencent Cloud Communication Service Interface Component TUIKIT - Chat Interface Component
 *
 * This document mainly declares the components used to implement the chat interface, which supports two modes of 1v1 single chat and group chat, including:
 * - Message display area: that is, the bubble display area.
 * - Message input area: that is, the part that allows users to input message text, emoticons, pictures and videos.
 *
 * The TDeskBaseChatViewController class is used to implement the general controller of the chat view, which is responsible for unified control of input, message
 * controller, and more views. The classes and protocols declared in this file can effectively help you implement custom message formats.
 *
 */
#import <TDeskCommon/TDesk_TIMCommonModel.h>
#import <UIKit/UIKit.h>
#import "TDesk_TUIBaseMessageController.h"
#import "TDesk_TUIChatConversationModel.h"
#import "TDesk_TUIInputController.h"
@class TDeskBaseChatViewController;

/////////////////////////////////////////////////////////////////////////////////
//
//                          TDeskBaseChatViewController
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *
 * 【Module name】TDeskBaseChatViewController
 * 【Function description】Responsible for implementing the UI components of the chat interface, including the message display area and the message input area.
 *
 *  The TDeskBaseChatViewController class is used to implement the overall controller of the chat view, and is responsible for unified control of the chat message
 * controller (TDeskBaseMessageController), the information input controller (TDeskInputController) and more views.
 *
 *  The chat message controller is responsible for responding in the UI when you receive a new message or sending a message, and respond to your interactions on
 * the message bubble, see: Section\Chat\TDeskBaseMessageController.h The information input controller is responsible for receiving your input, providing you with
 * the editing function of the input content and sending messages. For details, please refer to: Section\Chat\Input\TDeskInputController.h This class contains the
 * "more" view, that is, when you click the "+" button in the UI, more buttons can be displayed to satisfy your further operations. For details, please refer
 * to: Section\Chat\TDeskMoreView.h
 *
 *  Q: How to implement custom messages?
 *  A: If you want to implement a message style that TUIKit does not support, such as adding a voting link to the message style, you can refer to the
 * documentation: https://cloud.tencent.com/document/product/269/37067
 */
@interface TDeskBaseChatViewController : UIViewController

@property(nonatomic, strong) TDeskChatConversationModel *conversationData;

/**
 * Highlight text
 * In the search scenario, when highlightKeyword is not empty and matches @locateMessage, opening the chat session page will highlight the current cell
 */
@property(nonatomic, copy) NSString *highlightKeyword;

/**
 * Locate message
 * In the search scenario, when locateMessage is not empty, opening the chat session page will automatically scroll to here
 */
@property(nonatomic, strong) V2TIMMessage *locateMessage;

/**
 * View for displaying unread count number
 */
@property TDeskUnReadView *unRead;

/**
 *  TUIKit message controller
 *  It is responsible for the display of message bubbles, and at the same time, it is responsible for responding to the user's interaction with the message
 * bubbles, such as: clicking on the avatar of the message sender, tapping the message, and long-pressing the message. For more information about the chat
 * message controller, please refer to TUIChat\UI\Chat\TDeskBaseMessageController.h
 */
@property TDeskBaseMessageController *messageController;

/**
 *
 * The custom container view at the bottom, which is usually used to add plugin subviews.
 */
@property (nonatomic, strong) UIView *bottomContainerView;

/**
 *  TUIKit input controller
 *  Responsible for receiving user input, and displaying the "+" button, voice input button, emoticon button, etc.
 *  At the same time, TDeskInputController integrates the message sending function, and you can directly use TDeskInputController to collect and send message input.
 *  Please refer to TUIChat\UI\Input\TDeskInputController.h for details of the message input controller
 */
@property TDeskInputController *inputController;

/**
 *  Data group for more menu view data
 *  More menu views include: Capture, Picture, Video, File. See Section\Chat\TDeskMoreView.h for details
 */
@property NSArray<TDeskInputMoreCellData *> *moreMenus;

/**
 *  Need to scroll to the bottom
 *  It is usually used to push to another VC and need to scroll to the bottom after returning.
 */
@property(nonatomic, assign) BOOL needScrollToBottom;


@property (nonatomic, assign) BOOL isUIInitialized;

@property CGFloat kCustomerServiceNavBarHeight;

- (void)sendMessage:(V2TIMMessage *)message;

- (void)sendMessage:(V2TIMMessage *)message placeHolderCellData:(TDeskMessageCellData *)placeHolderCellData;

/**
 * Add a custom view at the top of the chat interface. The view will stay at the top of the message list and will not slide up as the message list slides up.
 * If not set, it will not be displayed by default.
 */
+ (void)setCustomTopView:(UIView *)view;

/**
 * Get a custom view at the top of the chat interface.
 */
+ (UIView *)customTopView;

+ (UIView *)groupPinTopView;

+ (UIView *)topAreaBottomView;

@end
