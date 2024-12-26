//
//  MyCustomCellData.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019 Tencent. All rights reserved.
//
#import <TDeskCommon/TDesk_TUIBubbleMessageCellData.h>
#import <TDeskCommon/TDesk_TUIMessageCellData.h>
NS_ASSUME_NONNULL_BEGIN

@interface TDeskLinkCellData : TDeskBubbleMessageCellData

@property NSString *text;
@property NSString *link;

@end

NS_ASSUME_NONNULL_END
