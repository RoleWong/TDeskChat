//
//  TDeskMediaCollectionCell.m
//  TUIChat
//
//  Created by xiangzhang on 2021/11/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIMediaCollectionCell.h"

@interface TDeskMediaCollectionCell()<V2TIMAdvancedMsgListener>

@end
@implementation TDeskMediaCollectionCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self registerTUIKitNotification];
    }
    return self;
}

- (void)fillWithData:(TDeskMessageCellData *)data {
    return;
}

- (void)registerTUIKitNotification {
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
}
@end
