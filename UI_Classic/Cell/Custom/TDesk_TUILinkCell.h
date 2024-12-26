//
//  MyCustomCell.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIBubbleMessageCell.h>
#import <TDeskCommon/TDesk_TUIMessageCell.h>
#import "TDesk_TUILinkCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TDeskLinkCell : TDeskBubbleMessageCell
@property UILabel *myTextLabel;
@property UILabel *myLinkLabel;

@property TDeskLinkCellData *customData;
- (void)fillWithData:(TDeskLinkCellData *)data;

@end

NS_ASSUME_NONNULL_END
