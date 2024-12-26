
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>
#import "TDesk_TUIImageMessageCellData.h"
#import "TDesk_TUIMediaCollectionCell.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIMediaImageCell
//
/////////////////////////////////////////////////////////////////////////////////

@interface TDeskImageCollectionCell : TDeskMediaCollectionCell

- (void)fillWithData:(TDeskImageMessageCellData *)data;
- (void)reloadAllView;
@end
