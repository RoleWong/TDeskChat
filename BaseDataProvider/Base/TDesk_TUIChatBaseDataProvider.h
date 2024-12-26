
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <TDeskCommon/TDesk_TUIMessageCellData.h>
#import "TDesk_TUIChatConversationModel.h"

@class TDeskChatBaseDataProvider;
NS_ASSUME_NONNULL_BEGIN

@protocol TDeskChatBaseDataProviderDelegate <NSObject>

@required
- (NSString *)dataProvider:(TDeskChatBaseDataProvider *)dataProvider mergeForwardTitleWithMyName:(NSString *)name;
- (NSString *)dataProvider:(TDeskChatBaseDataProvider *)dataProvider mergeForwardMsgAbstactForMessage:(V2TIMMessage *)message;

- (void)dataProvider:(TDeskChatBaseDataProvider *)dataProvider sendMessage:(V2TIMMessage *)message;
- (void)onSelectPhotoMoreCellData;
- (void)onTakePictureMoreCellData;
- (void)onTakeVideoMoreCellData;
- (void)onSelectFileMoreCellData;

@end

@interface TDeskChatBaseDataProvider : NSObject

@property(nonatomic, weak) id<TDeskChatBaseDataProviderDelegate> delegate;

- (void)getForwardMessageWithCellDatas:(NSArray<TDeskMessageCellData *> *)uiMsgs
                             toTargets:(NSArray<TDeskChatConversationModel *> *)targets
                                 Merge:(BOOL)merge
                           ResultBlock:(void (^)(TDeskChatConversationModel *targetConversation, NSArray<V2TIMMessage *> *msgs))resultBlock
                                  fail:(nullable V2TIMFail)fail;

- (NSString *)abstractDisplayWithMessage:(V2TIMMessage *)msg;

@end

#pragma mark - TDeskChatBaseDataProvider (IMSDK)
@interface TDeskChatBaseDataProvider (IMSDK)

+ (void)getTotalUnreadMessageCountWithSuccBlock:(void (^)(UInt64 totalCount))succ fail:(nullable V2TIMFail)fail;

+ (void)saveDraftWithConversationID:(NSString *)conversationId Text:(NSString *)text;

+ (void)findMessages:(NSArray *)msgIDs callback:(void (^)(BOOL succ, NSString *error_message, NSArray *msgs))callback;

#pragma mark - C2C
+ (void)getFriendInfoWithUserId:(nullable NSString *)userID
                      SuccBlock:(void (^)(V2TIMFriendInfoResult *friendInfoResult))succ
                      failBlock:(nullable V2TIMFail)fail;
+ (void)getUserInfoWithUserId:(NSString *)userID SuccBlock:(void (^)(V2TIMUserFullInfo *userInfo))succ failBlock:(nullable V2TIMFail)fail;

#pragma mark - Group
+ (void)getGroupInfoWithGroupID:(NSString *)groupID SuccBlock:(void (^)(V2TIMGroupInfoResult *groupResult))succ failBlock:(nullable V2TIMFail)fail;

@end

NS_ASSUME_NONNULL_END
