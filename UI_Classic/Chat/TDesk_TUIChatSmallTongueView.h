//
//  TDeskChatSmallTongue.h
//  TUIChat
//
//  Created by xiangzhang on 2022/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDesk_TUIChatDefine.h"

@class TDeskChatSmallTongue;

NS_ASSUME_NONNULL_BEGIN

@protocol TDeskChatSmallTongueViewDelegate <NSObject>

- (void)onChatSmallTongueClick:(TDeskChatSmallTongue *)tongue;

@end

@interface TDeskChatSmallTongueView : UIView

@property(nonatomic, weak) id<TDeskChatSmallTongueViewDelegate> delegate;

- (void)setTongue:(TDeskChatSmallTongue *)tongue;

@end

@interface TDeskChatSmallTongue : NSObject

@property(nonatomic, assign) TDeskChatSmallTongueType type;
@property(nonatomic, strong) UIView *parentView;
@property(nonatomic, assign) NSInteger unreadMsgCount;
@property(nonatomic, strong) NSString *atTipsStr;
@property(nonatomic, strong) NSArray *atMsgSeqs;

@end

@interface TDeskChatSmallTongueManager : NSObject

+ (void)showTongue:(TDeskChatSmallTongue *)tongue delegate:(id<TDeskChatSmallTongueViewDelegate>)delegate;
+ (void)removeTongue:(TDeskChatSmallTongueType)type;
+ (void)removeTongue;
+ (void)hideTongue:(BOOL)isHidden;
+ (void)adaptTongueBottomMargin:(CGFloat)margin;

@end

NS_ASSUME_NONNULL_END
