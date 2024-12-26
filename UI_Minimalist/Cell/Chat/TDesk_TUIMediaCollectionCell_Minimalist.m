//
//  TDeskMediaCollectionCell.m
//  TUIChat
//
//  Created by xiangzhang on 2021/11/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIMediaCollectionCell_Minimalist.h"

@implementation TUIMediaCollectionCell_Minimalist
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)fillWithData:(TDeskMessageCellData *)data {
    return;
}

@end
