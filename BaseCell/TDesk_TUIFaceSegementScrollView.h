//
//  TDeskFaceSegementScrollView.h
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/11/15.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDesk_TUIFaceView.h"
#import "TDesk_TUIFaceVerticalView.h"
NS_ASSUME_NONNULL_BEGIN
@class TDeskFaceGroup;

@interface TDeskFaceSegementScrollView : UIView
@property(nonatomic, copy) void(^onScrollCallback)(NSInteger indexPage);
@property(strong, nonatomic) UIScrollView *pageScrollView;
- (void)setItems:(NSArray<TDeskFaceGroup *> *)items delegate:(id <TDeskFaceVerticalViewDelegate>) delegate;
- (void)updateContainerView;
- (void)setPageIndex:(NSInteger)index;
- (void)setAllFloatCtrlViewAllowSendSwitch:(BOOL)isAllow;
- (void)updateRecentView;
@end

NS_ASSUME_NONNULL_END
