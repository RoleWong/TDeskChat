//
//  MyCustomCell.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <TDeskCommon/TUIBubbleMessageCell_Minimalist.h>
#import <TDeskCommon/TUIMessageCell.h>
#import "TUILinkCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUILinkCell_Minimalist : TUIBubbleMessageCell_Minimalist
@property UILabel *myTextLabel;
@property UILabel *myLinkLabel;

@property TUILinkCellData *customData;
- (void)fillWithData:(TUILinkCellData *)data;

@end

NS_ASSUME_NONNULL_END
