
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TDeskCommon/TDesk_TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@class TDeskMemberCellData;
@interface TDeskMemberCell : TDeskCommonTableViewCell

- (void)fillWithData:(TDeskMemberCellData *)cellData;

@end

NS_ASSUME_NONNULL_END
