
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TDeskCommon/TUIMessageCell_Minimalist.h>
#import "TUIImageMessageCellData.h"

@interface TUIImageMessageCell_Minimalist : TUIMessageCell_Minimalist

@property(nonatomic, strong) UIImageView *thumb;

@property(nonatomic, strong) UILabel *progress;

@property TUIImageMessageCellData *imageData;

- (void)fillWithData:(TUIImageMessageCellData *)data;
@end
