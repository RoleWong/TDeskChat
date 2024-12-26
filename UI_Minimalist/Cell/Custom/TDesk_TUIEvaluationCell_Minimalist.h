//
//  TDeskEvaluationCell.h
//  TUIChat
//
//  Created by xia on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIBubbleMessageCell_Minimalist.h>
#import "TDesk_TUIEvaluationCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIEvaluationCell_Minimalist : TDeskBubbleMessageCell_Minimalist

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *commentLabel;
@property(nonatomic, strong) NSMutableArray *starImageArray;

- (void)fillWithData:(TDeskEvaluationCellData *)data;

@end

NS_ASSUME_NONNULL_END
