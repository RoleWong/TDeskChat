
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TDesk_TUIMessageBaseDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class TDeskTextMessageCellData;
@class TDeskFaceMessageCellData;
@class TDeskImageMessageCellData;
@class TDeskVoiceMessageCellData;
@class TDeskVideoMessageCellData;
@class TDeskFileMessageCellData;
@class TDeskSystemMessageCellData;
@class TDeskChatCallingDataProvider;

@protocol TDeskMessageDataProviderDataSource <TDeskMessageBaseDataProviderDataSource>

+ (nullable Class)onGetCustomMessageCellDataClass:(NSString *)businessID;

@end

@interface TDeskMessageDataProvider : TDeskMessageBaseDataProvider

+ (void)setDataSourceClass:(Class<TDeskMessageDataProviderDataSource>)dataSourceClass;

#pragma mark - TDeskMessageCellData parser
+ (nullable TDeskMessageCellData *)getCellData:(V2TIMMessage *)message;

#pragma mark - Last message parser
+ (void)asyncGetDisplayString:(NSArray<V2TIMMessage *> *)messageList callback:(void(^)(NSDictionary<NSString *, NSString *> *))callback;
+ (nullable NSString *)getDisplayString:(V2TIMMessage *)message;

#pragma mark - Data source operate
- (void)processQuoteMessage:(NSArray<TDeskMessageCellData *> *)uiMsgs;
- (void)deleteUIMsgs:(NSArray<TDeskMessageCellData *> *)uiMsgs SuccBlock:(nullable V2TIMSucc)succ FailBlock:(nullable V2TIMFail)fail;
- (void)removeUIMsgList:(NSArray<TDeskMessageCellData *> *)cellDatas;


+ (TDeskChatCallingDataProvider *)callingDataProvider;

@end

NS_ASSUME_NONNULL_END
