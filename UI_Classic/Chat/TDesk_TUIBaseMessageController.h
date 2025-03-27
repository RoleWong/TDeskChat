
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  This file declares the controller class used to implement the messaging logic
 *  The message controller is responsible for uniformly displaying the messages you send/receive, while providing response callbacks when you interact with
 * those messages (tap/long-press, etc.). The message controller is also responsible for unified data processing of the messages you send into a data format
 * that can be sent through the IM SDK and sent. That is to say, when you use this controller, you can save a lot of data processing work, so that you can
 * access the IM SDK more quickly and conveniently.
 */

#import <TDeskCommon/TDesk_TUIMessageCell.h>
#import <UIKit/UIKit.h>

#import "TDesk_TUIBaseMessageControllerDelegate.h"
#import "TDesk_TUIChatConversationModel.h"
#import "TDesk_TUIChatDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class TDeskConversationCellData;
@class TDeskBaseMessageController;
@class TDeskReplyMessageCell;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TDeskBaseMessageController
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *
 * 【Module name】TDeskBaseMessageController
 * 【Function description】The message controller is responsible for implementing a series of business logic such as receiving, sending, and displaying
 * messages.
 *  - This class provides callback interfaces for interactive operations such as receiving/displaying new messages, showing/hiding menus, and clicking on
 * message avatars.
 *  - At the same time, this class provides the sending function of image, video, and file information, and directly integrates and calls the IM SDK to realize
 * the sending function.
 *
 */
@interface TDeskBaseMessageController : UITableViewController

+ (void)asyncGetDisplayString:(NSArray<V2TIMMessage *> *)messageList callback:(void(^)(NSDictionary<NSString *, NSString *> *))callback;
+ (nullable NSString *)getDisplayString:(V2TIMMessage *)message;

@property(nonatomic, weak) id<TDeskBaseMessageControllerDelegate> delegate;

@property(nonatomic, assign) BOOL isInVC;

/**
 * Whether a read receipt is required to send a message, the default is NO
 */
@property(nonatomic) BOOL isMsgNeedReadReceipt;

@property(nonatomic, copy) void (^groupRoleChanged)(V2TIMGroupMemberRole role);

@property(nonatomic, copy) void (^pinGroupMessageChanged)(NSArray *groupPinList);


- (void)sendMessage:(V2TIMMessage *)msg;

- (void)sendMessage:(V2TIMMessage *)msg placeHolderCellData:(TDeskMessageCellData *)placeHolderCellData;

- (void)clearUImsg;

- (void)scrollToBottom:(BOOL)animate;

- (void)setConversation:(TDeskChatConversationModel *)conversationData;

- (void)sendPlaceHolderUIMessage:(TDeskMessageCellData *)cellData;
/**
 *
 * After enabling multi-selection mode, get the currently selected result
 * Returns an empty array if multiple selection mode is off
 */
- (NSArray<TDeskMessageCellData *> *)multiSelectedResult:(TDeskMultiResultOption)option;
- (void)enableMultiSelectedMode:(BOOL)enable;

- (void)deleteMessages:(NSArray<TDeskMessageCellData *> *)uiMsgs;

/**
 * Conversation read report
 *
 */
- (void)readReport;

/**
 * Subclass implements click-to-reply messages
 */
- (void)showReplyMessage:(TDeskReplyMessageCell *)cell;
- (void)willShowMediaMessage:(TDeskMessageCell *)cell;
- (void)didCloseMediaMessage:(TDeskMessageCell *)cell;

// Reload the specific cell UI.
- (void)reloadCellOfMessage:(NSString *)messageID;
- (void)reloadAndScrollToBottomOfMessage:(NSString *)messageID;
- (void)scrollCellToBottomOfMessage:(NSString *)messageID;

- (void)loadGroupInfo;
- (BOOL)isCurrentUserRoleSuperAdminInGroup;
- (BOOL)isCurrentMessagePin:(NSString *)msgID;
- (void)unPinGroupMessage:(V2TIMMessage *)innerMessage;

- (CGFloat)getHeightFromMessageCellData:(TDeskMessageCellData *)cellData;
@end

NS_ASSUME_NONNULL_END
