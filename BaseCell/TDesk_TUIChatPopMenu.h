//
//  TDeskChatPopMenu.h
//  TUIChat
//
//  Created by harvy on 2021/11/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDesk_TUIChatConfig.h"
#import "TDesk_TUIChatPopMenuDefine.h"
#import <TDeskCommon/TDesk_TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDeskChatPopMenuActionCallback)(void);

@interface TDeskChatPopMenuAction : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, copy) TDeskChatPopMenuActionCallback callback;

/**
 * The higher the weight, the more prominent it is: audioPlayback 11000 Copy 10000, Forward 9000, Multiple Choice 8000, Quote 7000, Reply 5000, Withdraw 4000, Delete 3000.
 */
@property(nonatomic, assign) NSInteger weight;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image weight:(NSInteger)weight callback:(TDeskChatPopMenuActionCallback)callback;
@end

typedef void (^TDeskChatPopMenuHideCallback)(void);
@interface TDeskChatPopMenu : UIView
@property(nonatomic, copy) TDeskChatPopMenuHideCallback hideCallback;
@property(nonatomic, copy) void (^reactClickCallback)(NSString *faceName);
@property(nonatomic, weak) TDeskMessageCellData *targetCellData;
/**
 * TDeskChatPopMenu has no emojiView by default. If you need a chatPopMenu with emojiView, use this initializer.
 */
- (instancetype)initWithEmojiView:(BOOL)hasEmojiView frame:(CGRect)frame;

@property(nonatomic, strong, readonly) UIView *emojiContainerView;
@property(nonatomic, strong, readonly) UIView *containerView;

- (void)addAction:(TDeskChatPopMenuAction *)action;
- (void)removeAllAction;
- (void)setArrawPosition:(CGPoint)point adjustHeight:(CGFloat)adjustHeight;
- (void)showInView:(UIView *__nullable)window;
- (void)layoutSubview;
- (void)hideWithAnimation;

@end

NS_ASSUME_NONNULL_END
