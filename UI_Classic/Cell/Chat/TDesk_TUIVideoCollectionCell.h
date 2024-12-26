
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import "TDesk_TUIMediaCollectionCell.h"
#import "TDesk_TUIVideoMessageCellData.h"

@interface TDeskVideoCollectionCell : TDeskMediaCollectionCell

- (void)fillWithData:(TDeskVideoMessageCellData *)data;

- (void)stopVideoPlayAndSave;

- (void)reloadAllView;
@end
