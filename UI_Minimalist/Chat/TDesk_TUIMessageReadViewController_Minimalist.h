//
//  TUIMessageReadViewController_Minimalist.h
//  TUIChat
//
//  Created by xia on 2022/3/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIMessageCellData.h>
#import <TDeskCommon/TDesk_TUIMessageCell_Minimalist.h>
#import <UIKit/UIKit.h>
#import "TDesk_TUIChatDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class TDeskMessageDataProvider;

@interface TUIMessageReadViewController_Minimalist : UIViewController
@property(nonatomic, strong) Class alertCellClass;
@property(nonatomic, strong) TDeskMessageCellData *alertViewCellData;
@property(nonatomic, assign) CGRect originFrame;

@property(copy, nonatomic) void (^viewWillShowHandler)(TDeskMessageCell *alertView);
@property(copy, nonatomic) void (^viewDidShowHandler)(TDeskMessageCell *alertView);
@property(copy, nonatomic) void (^viewWillDismissHandler)(TDeskMessageCell *alertView);

- (instancetype)initWithCellData:(TDeskMessageCellData *)data
                    dataProvider:(TDeskMessageDataProvider *)dataProvider
           showReadStatusDisable:(BOOL)showReadStatusDisable
                 c2cReceiverName:(NSString *)name
               c2cReceiverAvatar:(NSString *)avatarUrl;
@end

NS_ASSUME_NONNULL_END
