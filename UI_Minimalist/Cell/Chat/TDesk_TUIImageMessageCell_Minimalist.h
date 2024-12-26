
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TDeskCommon/TDesk_TUIMessageCell_Minimalist.h>
#import "TDesk_TUIImageMessageCellData.h"

@interface TUIImageMessageCell_Minimalist : TDeskMessageCell_Minimalist

@property(nonatomic, strong) UIImageView *thumb;

@property(nonatomic, strong) UILabel *progress;

@property TDeskImageMessageCellData *imageData;

- (void)fillWithData:(TDeskImageMessageCellData *)data;
@end
