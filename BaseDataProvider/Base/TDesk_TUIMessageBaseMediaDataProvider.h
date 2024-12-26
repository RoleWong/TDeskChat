
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TDesk_TUIMessageBaseDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDeskMessageBaseMediaDataProvider : TDeskMessageBaseDataProvider
@property(nonatomic, strong) NSMutableArray *medias;

- (instancetype)initWithConversationModel:(nullable TDeskChatConversationModel *)conversationModel;

/**
 * Pull 20 video (picture) messages before and after the current message
 */
- (void)loadMediaWithMessage:(V2TIMMessage *)curMessage;

/**
 * Pull older 20 video (image) messages
 */
- (void)loadOlderMedia;

/**
 * Pull the last 20 video (image) messages
 */
- (void)loadNewerMedia;

- (void)removeCache;

+ (TDeskMessageCellData *)getMediaCellData:(V2TIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
