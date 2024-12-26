//
//  TDeskMessageDataProvider+MessageDeal.h
//  TUIChat
//
//  Created by wyl on 2022/3/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIMessageDataProvider.h"
#import "TDesk_TUIReplyMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDeskMessageDataProvider (MessageDeal)
- (void)loadOriginMessageFromReplyData:(TDeskReplyMessageCellData *)replycellData dealCallback:(void (^)(void))callback;
@end

NS_ASSUME_NONNULL_END
