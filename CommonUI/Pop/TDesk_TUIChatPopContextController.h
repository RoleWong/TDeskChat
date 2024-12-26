//
//  TDeskChatPopContextController.h
//  TUIChat
//
//  Created by wyl on 2022/10/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIMessageCell.h>
#import <TDeskCommon/TDesk_TUIMessageCellData.h>
#import <UIKit/UIKit.h>
#import "TDesk_TUIChatPopContextExtionView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TDeskBlurEffectStyle) {
    BlurEffectStyleLight,
    BlurEffectStyleExtraLight,
    BlurEffectStyleDarkEffect,
};
@interface TDeskChatPopContextController : UIViewController

@property(nonatomic, strong) Class alertCellClass;

@property(nonatomic, strong) TDeskMessageCellData *alertViewCellData;

@property(nonatomic, assign) CGRect originFrame;

@property(copy, nonatomic) void (^viewWillShowHandler)(TDeskMessageCell *alertView);

@property(copy, nonatomic) void (^viewDidShowHandler)(TDeskMessageCell *alertView);

// dismiss controller completed block
@property(nonatomic, copy) void (^dismissComplete)(void);

@property(nonatomic, copy) void (^reactClickCallback)(NSString *faceName);

@property(nonatomic, strong) NSMutableArray<TDeskChatPopContextExtionItem *> *items;

- (void)setBlurEffectWithView:(UIView *)view;

- (void)blurDismissViewControllerAnimated:(BOOL)animated completion:(void (^__nullable)(BOOL finished))completion;

- (void)updateExtionView;

@end

NS_ASSUME_NONNULL_END
