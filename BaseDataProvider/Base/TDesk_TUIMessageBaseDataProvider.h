
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCommon/TDesk_TUIMessageCell.h>
#import <TDeskCommon/TDesk_TUIMessageCellData.h>
#import "TDesk_TUIChatConversationModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TDeskMessageBaseDataProviderDataSourceChangeType) {
    TDeskMessageBaseDataProviderDataSourceChangeTypeInsert,
    TDeskMessageBaseDataProviderDataSourceChangeTypeDelete,
    TDeskMessageBaseDataProviderDataSourceChangeTypeReload,
};

@class TDeskMessageBaseDataProvider;
@protocol TDeskMessageBaseDataProviderDataSource <NSObject>

@required
- (void)dataProviderDataSourceWillChange:(TDeskMessageBaseDataProvider *)dataProvider;
- (void)dataProviderDataSourceChange:(TDeskMessageBaseDataProvider *)dataProvider
                            withType:(TDeskMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation;
- (void)dataProviderDataSourceDidChange:(TDeskMessageBaseDataProvider *)dataProvider;
- (void)dataProvider:(TDeskMessageBaseDataProvider *)dataProvider onRemoveHeightCache:(TDeskMessageCellData *)cellData;

@optional
/**
 * Message read event
 *
 * @param userID recevier of one-to-one message
 * @param timestamp Read receipt time, messages before this timestamp can be considered read by the other party
 */
- (void)dataProvider:(TDeskMessageBaseDataProvider *)dataProvider ReceiveReadMsgWithUserID:(NSString *)userId Time:(time_t)timestamp;


/**
 * Group message read event
 *
 * @param groupID Group ID
 * @param msgID Message idenetifier
 * @param readCount Count of read message
 * @param unreadCount Count of unread message
 */
- (void)dataProvider:(TDeskMessageBaseDataProvider *)dataProvider
    ReceiveReadMsgWithGroupID:(NSString *)groupID
                        msgID:(NSString *)msgID
                    readCount:(NSUInteger)readCount
                  unreadCount:(NSUInteger)unreadCount;

/**
 * A new message is received, the data has been changed, refreshed, it has been processed internally, and subsequent processing can be done in this method
 *
 * @param uiMsg The new message
 */
- (void)dataProvider:(TDeskMessageBaseDataProvider *)dataProvider ReceiveNewUIMsg:(TDeskMessageCellData *)uiMsg;

/**
 * 
 * Reveived a recalled message
 */
- (void)dataProvider:(TDeskMessageBaseDataProvider *)dataProvider ReceiveRevokeUIMsg:(TDeskMessageCellData *)uiMsg;

/**
 * This event is fired when a new message is received after the request for a new message is completed
 * External can use this method to modify the CellData to be displayed, add messages (such as time messages), and customize messages
 */
- (nullable TDeskMessageCellData *)dataProvider:(TDeskMessageBaseDataProvider *)dataProvider CustomCellDataFromNewIMMessage:(V2TIMMessage *)msg;

@end

/**
 *
 * 【Module name】Chat message list view model (TDeskMessageDataProvider)
 * 【Function description】Responsible for implementing the data processing and business logic of the message list in the chat page
 *  1. The view model can pull the message list data from the server through the interface provided by the IM SDK, and load the data.
 *  2. The view model can synchronously remove the message list data when the user needs to delete the session list.
 */
@interface TDeskMessageBaseDataProvider : NSObject

@property(nonatomic, weak) id<TDeskMessageBaseDataProviderDataSource> dataSource;

@property(nonatomic, strong, readonly) NSArray<TDeskMessageCellData *> *uiMsgs;
@property(nonatomic, strong, readonly) NSDictionary<NSString *, NSNumber *> *heightCache;
@property(nonatomic, assign, readonly) BOOL isLoadingData;
@property(nonatomic, assign, readonly) BOOL isNoMoreMsg;
@property(nonatomic, assign, readonly) BOOL isFirstLoad;

/**
 * ，
 *
 * If adjacent messages are sent by the same user, the messages will be merged for display.
 */
@property(nonatomic, assign) BOOL mergeAdjacentMsgsFromTheSameSender;

/**
 *
 * Count of per page, default is 20.
 */
@property(nonatomic, assign) NSInteger pageCount;

- (instancetype)initWithConversationModel:(TDeskChatConversationModel *)conversationModel;

- (void)loadMessageSucceedBlock:(void (^)(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TDeskMessageCellData *> *newMsgs))succeedBlock
                      FailBlock:(V2TIMFail)failBlock;

- (void)sendUIMsg:(TDeskMessageCellData *)uiMsg
    toConversation:(TDeskChatConversationModel *)conversationData
     willSendBlock:(void (^)(BOOL isReSend, TDeskMessageCellData *dateUIMsg))willSendBlock
         SuccBlock:(nullable V2TIMSucc)succ
         FailBlock:(nullable V2TIMFail)fail;

- (void)revokeUIMsg:(TDeskMessageCellData *)uiMsg SuccBlock:(nullable V2TIMSucc)succ FailBlock:(nullable V2TIMFail)fail;

- (void)deleteUIMsgs:(NSArray<TDeskMessageCellData *> *)uiMsgs SuccBlock:(nullable V2TIMSucc)succ FailBlock:(nullable V2TIMFail)fail;

- (void)addUIMsg:(TDeskMessageCellData *)cellData;

- (void)removeUIMsg:(TDeskMessageCellData *)cellData;

- (void)insertUIMsgs:(NSArray<TDeskMessageCellData *> *)uiMsgs atIndexes:(NSIndexSet *)indexes;

- (void)sendPlaceHolderUIMessage:(TDeskMessageCellData *)placeHolderCellData; //Only send PlaceHolder UI Message

- (void)addUIMsgs:(NSArray<TDeskMessageCellData *> *)uiMsgs;

- (void)replaceUIMsg:(TDeskMessageCellData *)cellData atIndex:(NSUInteger)index;

/**
 * Preprocessing reply messages (asynchronously loading original messages and downloading corresponding thumbnails)
 */
- (void)preProcessMessage:(NSArray<TDeskMessageCellData *> *)uiMsgs callback:(void (^)(void))callback;

- (NSArray<NSString *> *)getUserIDListForAdditionalUserInfo:(NSArray<TDeskMessageCellData *> *)uiMsgs;
- (void)requestForAdditionalUserInfo:(NSArray<TDeskMessageCellData *> *)uiMsgs callback:(void (^)(void))callback;

/**
 * Send read receipts for latest messages
 */
- (void)sendLatestMessageReadReceipt;

/**
 * Send a read receipt for the specified index message
 */
- (void)sendMessageReadReceiptAtIndexes:(NSArray *)indexes;

/**
 * Get the index of the message in the mesage data through msgID
 */
- (NSInteger)getIndexOfMessage:(NSString *)msgID;

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs;

- (void)clearUIMsgList;

- (void)processQuoteMessage:(NSArray<TDeskMessageCellData *> *)uiMsgs;  // subclass override required

+ (void)updateUIMsgStatus:(TDeskMessageCellData *)cellData uiMsgs:(NSArray *)uiMsgs;

- (void)getPinMessageList;

- (void)getSelfInfoInGroup:(dispatch_block_t)callback;

- (void)pinGroupMessage:(NSString *)groupID
                message:(V2TIMMessage *)message
               isPinned:(BOOL)isPinned
                   succ:(V2TIMSucc)succ
                   fail:(V2TIMFail)fail;

- (BOOL)isCurrentUserRoleSuperAdminInGroup;

- (BOOL)isCurrentMessagePin:(NSString *)msgID;

@property(nonatomic, copy) void (^groupRoleChanged)(V2TIMGroupMemberRole role);
@property(nonatomic, copy) void (^pinGroupMessageChanged)(NSArray *);

@end

@interface TDeskMessageBaseDataProvider (IMSDK)
/// imsdk interface call
+ (NSString *)sendMessage:(V2TIMMessage *)message
           toConversation:(TDeskChatConversationModel *)conversationData
             appendParams:(TDeskSendMessageAppendParams *)appendParams
                 Progress:(nullable V2TIMProgress)progress
                SuccBlock:(nullable V2TIMSucc)succ
                FailBlock:(nullable V2TIMFail)fail;

- (void)getLastMessage:(BOOL)isFromLocal succ:(void (^)(V2TIMMessage *message))succ fail:(V2TIMFail)fail;

+ (void)markC2CMessageAsRead:(NSString *)userID succ:(nullable V2TIMSucc)succ fail:(nullable V2TIMFail)fail;

+ (void)markGroupMessageAsRead:(NSString *)groupID succ:(nullable V2TIMSucc)succ fail:(nullable V2TIMFail)fail;

+ (void)markConversationAsUndead:(NSArray<NSString *> *)conversationIDList enableMark:(BOOL)enableMark;

+ (void)revokeMessage:(V2TIMMessage *)msg succ:(nullable V2TIMSucc)succ fail:(nullable V2TIMFail)fail;

+ (void)deleteMessages:(NSArray<V2TIMMessage *> *)msgList succ:(nullable V2TIMSucc)succ fail:(nullable V2TIMFail)fail;

+ (void)modifyMessage:(V2TIMMessage *)msg completion:(V2TIMMessageModifyCompletion)completion;

/**
 * Send message read receipts
 */
+ (void)sendMessageReadReceipts:(NSArray *)msgs;

/**
 * Getting the list of read and unread members of group messages
 */
+ (void)getReadMembersOfMessage:(V2TIMMessage *)msg
                         filter:(V2TIMGroupMessageReadMembersFilter)filter
                        nextSeq:(NSUInteger)nextSeq
                     completion:(void (^)(int code, NSString *desc, NSArray *members, NSUInteger nextSeq, BOOL isFinished))block;

/**
 * Getting the read receipt of the message
 */
+ (void)getMessageReadReceipt:(NSArray *)messages succ:(nullable V2TIMMessageReadReceiptsSucc)succ fail:(nullable V2TIMFail)fail;

/// message -> cellData
+ (nullable TDeskMessageCellData *)getCellData:(V2TIMMessage *)message;
+ (nullable TDeskMessageCellData *)getSystemMsgFromDate:(NSDate *)date;
+ (nullable TDeskMessageCellData *)getRevokeCellData:(V2TIMMessage *)message;

/// message -> displayString
+ (nullable NSString *)getDisplayString:(V2TIMMessage *)message;
+ (nullable NSString *)getRevokeDispayString:(V2TIMMessage *)message;
+ (nullable NSString *)getRevokeDispayString:(V2TIMMessage *)message operateUser:(V2TIMUserFullInfo *)operateUser reason:(NSString *)reason;
+ (nullable NSString *)getGroupTipsDisplayString:(V2TIMMessage *)message;

/// message <-> info
+ (V2TIMMessage *)getCustomMessageWithJsonData:(NSData *)data;
+ (V2TIMMessage *)getCustomMessageWithJsonData:(NSData *)data desc:(NSString *)desc extension:(NSString *)extension;
+ (NSMutableArray *)getUserIDList:(NSArray<V2TIMGroupMemberInfo *> *)infoList;
+ (NSString *)getShowName:(V2TIMMessage *)message;
+ (NSString *)getOpUserName:(V2TIMGroupMemberInfo *)info;
+ (NSMutableArray *)getUserNameList:(NSArray<V2TIMGroupMemberInfo *> *)infoList;
+ (NSString *)getUserName:(V2TIMGroupTipsElem *)tips with:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
