
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import "TDesk_TUIMediaCollectionCell_Minimalist.h"
#import "TDesk_TUIVideoMessageCellData.h"

@interface TUIVideoCollectionCell_Minimalist : TUIMediaCollectionCell_Minimalist

- (void)fillWithData:(TDeskVideoMessageCellData *)data;

- (void)stopVideoPlayAndSave;

@end
