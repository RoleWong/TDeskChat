//
//  TDeskOrderCell.h
//  TUIChat
//
//  Created by xia on 2022/6/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIBubbleMessageCell.h>
#import "TDesk_TUIOrderCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDeskOrderCell : TDeskBubbleMessageCell

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *priceLabel;
@property(nonatomic, strong) TDeskOrderCellData *customData;

- (void)fillWithData:(TDeskOrderCellData *)data;

@end

NS_ASSUME_NONNULL_END
