
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 * This document declares the relevant components to implement the input area.
 * The input area includes the emoticon view input area (TDeskFaceView+TDeskMoreView), the "more" functional area (TDeskMoreView) and the text input area
 * (TDeskInputBar). This file contains the TDeskInputControllerDelegate protocol and the TInputController class. In the input bar (TDeskInputBar), button response
 * callbacks for expressions, voices, and more views are provided. In this class, the InputBar is actually combined with the above three views to realize the
 * display and switching logic of each view.
 */
#import <TDeskCommon/TDesk_TUIMessageCell.h>
#import <UIKit/UIKit.h>
#import "TDesk_TUIChatDefine.h"
#import "TDesk_TUIFaceView.h"
#import "TDesk_TUIInputBar.h"
#import "TDesk_TUIMenuView.h"
#import "TDesk_TUIMoreView.h"
#import "TDesk_TUIReplyPreviewBar.h"
#import "TDesk_TUIFaceSegementScrollView.h"

@class TDeskInputController;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TDeskInputControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TDeskInputControllerDelegate <NSObject>

/**
 * Callback when the current InputController height changes.
 * You can use this callback to adjust the UI layout of each component in the controller according to the changed height.
 */
- (void)inputController:(TDeskInputController *)inputController didChangeHeight:(CGFloat)height;

/**
 *  Callback when the current InputController sends a message.
 */
- (void)inputController:(TDeskInputController *)inputController didSendMessage:(V2TIMMessage *)msg;

/**
 *  Callback for clicking a more item
 *  You can use this callback to achieve: according to the clicked cell type, do the next step. For example, select pictures, select files, etc.
 *  At the same time, the implementation of this delegate contains the following code:
 *  <pre>
 *  - (void)inputController:(TDeskInputController *)inputController didSelectMoreCell:(TDeskInputMoreCell *)cell {
 *      ……
 *      ……
 *      if(_delegate && [_delegate respondsToSelector:@selector(chatController:onSelectMoreCell:)]){
 *          [_delegate chatController:self onSelectMoreCell:cell];
 *      }
 *  }
 *  </pre>
 *  The above code can help you to customize the "more" unit.
 *  For more information you can refer to the comments in TUIChat\UI\Chat\TUIBaseChatController.h
 */
- (void)inputController:(TDeskInputController *)inputController didSelectMoreCell:(TDeskInputMoreCell *)cell;

/**
 *  Callback when @ character is entered
 */
- (void)inputControllerDidInputAt:(TDeskInputController *)inputController;

/**
 *  Callback when there are @xxx characters removed
 */
- (void)inputController:(TDeskInputController *)inputController didDeleteAt:(NSString *)atText;

- (void)inputControllerBeginTyping:(TDeskInputController *)inputController;

- (void)inputControllerEndTyping:(TDeskInputController *)inputController;

- (void)inputControllerDidClickMore:(TDeskInputController *)inputController;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                         TDeskInputControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@interface TDeskInputController : UIViewController

/**
 * A preview view above the input box for message reply scenarios
 */
@property(nonatomic, strong) TDeskReplyPreviewBar *replyPreviewBar;

/**
 * The preview view below the input box, with the message reference scene
 *
 */
@property(nonatomic, strong) TDeskReferencePreviewBar *referencePreviewBar;

/**
 * Message currently being replied to
 */
@property(nonatomic, strong) TDeskReplyPreviewData *replyData;

@property(nonatomic, strong) TDeskReferencePreviewData *referenceData;

/**
 *  Input bar
 *  The input bar contains a series of interactive components such as text input box, voice button, "more" button, emoticon button, etc., and provides
 * corresponding callbacks for these components.
 */
@property(nonatomic, strong) TDeskInputBar *inputBar;

/**
 *  Emoticon view
 *  The emoticon view generally appears after clicking the "Smiley" button. Responsible for displaying each expression group and the expressions within the
 * group.
 *
 */
//@property(nonatomic, strong) TDeskFaceView *faceView;

@property(nonatomic, strong) TDeskFaceSegementScrollView *faceSegementScrollView;
/**
 *  Menu view
 *  The menu view is located below the emoticon view and is responsible for providing the emoticon grouping unit and the send button.
 */
@property(nonatomic, strong) TDeskMenuView *menuView;

/**
 *  More view
 *  More views generally appear after clicking the "More" button ("+" button), and are responsible for displaying each more unit, such as shooting, video, file,
 * album, etc.
 */
@property(nonatomic, strong) TDeskMoreView *moreView;

@property(nonatomic, weak) id<TDeskInputControllerDelegate> delegate;

/**
 *  Reset the current input controller.
 *  If there is currently an emoji view or a "more" view being displayed, collapse the corresponding view and set the current status to Input_Status_Input.
 *  That is, no matter what state the current InputController is in, reset it to its initialized state.
 */
- (void)reset;

/**
 * Show/hide preview bar of message reply input box
 */
- (void)showReplyPreview:(TDeskReplyPreviewData *)data;
- (void)showReferencePreview:(TDeskReferencePreviewData *)data;
- (void)exitReplyAndReference:(void (^__nullable)(void))finishedCallback;

/**
 * Current input box state
 */
@property(nonatomic, assign, readonly) InputStatus status;
@end
