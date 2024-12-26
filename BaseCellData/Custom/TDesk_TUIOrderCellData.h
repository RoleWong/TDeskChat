//
//  TDeskOrderCellData.h
//  TUIChat
//
//  Created by xia on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIBubbleMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDeskOrderCellData : TDeskBubbleMessageCellData

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, copy) NSString *price;
@property(nonatomic, copy) NSString *imageUrl;
@property(nonatomic, copy) NSString *link;

@end

NS_ASSUME_NONNULL_END
