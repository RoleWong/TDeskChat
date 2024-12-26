
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCommon/TDesk_TIMInputViewMoreActionProtocol.h>
#import "TDesk_TUIChatBaseDataProvider.h"
#import "TDesk_TUIChatConversationModel.h"
#import "TDesk_TUIInputMoreCellData.h"
#import "TDesk_TUIVideoMessageCellData.h"

@class TDeskChatDataProvider;
@class TDeskCustomActionSheetItem;

NS_ASSUME_NONNULL_BEGIN

@interface TDeskChatDataProvider : TDeskChatBaseDataProvider

#pragma mark - CellData
- (NSMutableArray<TDeskInputMoreCellData *> *)moreMenuCellDataArray:(NSString *)groupID
                                                           userID:(NSString *)userID
                                                conversationModel:(TDeskChatConversationModel *)conversationModel
                                                 actionController:(id<TDeskInputViewMoreActionProtocol>)actionController;

- (NSArray<TDeskCustomActionSheetItem *> *)getInputMoreActionItemList:(nullable NSString *)userID
                                                            groupID:(nullable NSString *)groupID
                                                  conversationModel:(TDeskChatConversationModel *)conversationModel
                                                             pushVC:(nullable UINavigationController *)pushVC
                                                   actionController:(id<TDeskInputViewMoreActionProtocol>)actionController;

@end

NS_ASSUME_NONNULL_END
