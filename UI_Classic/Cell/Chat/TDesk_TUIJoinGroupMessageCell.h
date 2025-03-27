
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TDeskCommon/TDesk_TUISystemMessageCell.h>
#import "TDesk_TUIJoinGroupMessageCellData.h"
NS_ASSUME_NONNULL_BEGIN

@class TDeskJoinGroupMessageCell;

@protocol TDeskJoinGroupMessageCellDelegate <NSObject>

@optional

- (void)didTapOnNameLabel:(TDeskJoinGroupMessageCell *)cell;

- (void)didTapOnSecondNameLabel:(TDeskJoinGroupMessageCell *)cell;

- (void)didTapOnRestNameLabel:(TDeskJoinGroupMessageCell *)cell withIndex:(NSInteger)index;

@end

@interface TDeskJoinGroupMessageCell : TDeskSystemMessageCell

@property TDeskJoinGroupMessageCellData *joinData;

@property(nonatomic, weak) id<TDeskJoinGroupMessageCellDelegate> joinGroupDelegate;

@end

NS_ASSUME_NONNULL_END
