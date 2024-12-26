
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TDeskCommon/TDesk_TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN
@class TUIMemberDescribeCellData_Minimalist;
@class TUIMemberCellData_Minimalist;

@interface TUIMemberDescribeCell_Minimalist : TDeskCommonTableViewCell

- (void)fillWithData:(TUIMemberDescribeCellData_Minimalist *)cellData;

@end

@interface TUIMemberCell_Minimalist : TDeskCommonTableViewCell

- (void)fillWithData:(TUIMemberCellData_Minimalist *)cellData;

@end

NS_ASSUME_NONNULL_END
