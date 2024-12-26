//
//  TDeskTypingStatusCellData.h
//  TUIChat
//
//  Created by wyl on 2022/7/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDeskTypingStatusCellData : TDeskMessageCellData

@property(nonatomic, assign) NSInteger typingStatus;

@end

NS_ASSUME_NONNULL_END
