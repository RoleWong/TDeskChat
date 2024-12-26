//
//  TDeskEvaluationCell.h
//  TUIChat
//
//  Created by xia on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIBubbleMessageCell.h>
#import "TDesk_TUIEvaluationCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDeskEvaluationCell : TDeskBubbleMessageCell

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *commentLabel;
@property(nonatomic, strong) NSMutableArray *starImageArray;

- (void)fillWithData:(TDeskEvaluationCellData *)data;

@end

NS_ASSUME_NONNULL_END
