
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 * This file mainly declares the controller class that jumps to the read member list after clicking the read label of the group chat message
 *
 * The TDeskMessageReadSelectView class defines a tab-like view in the read list. Currently only used in TDeskMessageReadViewController.
 * TDeskMessageReadSelectViewDelegate Callback for clicked view event. Currently implemented by TDeskMessageReadViewController to switch between read and unread
 * lists.
 *
 * The TDeskMessageReadViewController class implements the UI and logic for the read member list.
 * TUIMessageReadViewControllerDelegate callback click member list cell event.
 */

#import <TDeskCommon/TDesk_TUIMessageCellData.h>
#import <UIKit/UIKit.h>
#import "TDesk_TUIChatDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class TDeskMessageReadSelectView;
@protocol TDeskMessageReadSelectViewDelegate <NSObject>
@optional
- (void)messageReadSelectView:(TDeskMessageReadSelectView *)view didSelectItemTag:(TUIMessageReadViewTag)tag;
@end

@interface TDeskMessageReadSelectView : UIView
@property(nonatomic, weak) id<TDeskMessageReadSelectViewDelegate> delegate;
@property(nonatomic, assign) BOOL selected;

- (instancetype)initWithTitle:(NSString *)title viewTag:(TUIMessageReadViewTag)tag selected:(BOOL)selected;

@end

@class TDeskMessageDataProvider;
@interface TDeskMessageReadViewController : UIViewController
@property(copy, nonatomic) void (^viewWillDismissHandler)(void);

- (instancetype)initWithCellData:(TDeskMessageCellData *)data
                    dataProvider:(TDeskMessageDataProvider *)dataProvider
           showReadStatusDisable:(BOOL)showReadStatusDisable
                 c2cReceiverName:(NSString *)name
               c2cReceiverAvatar:(NSString *)avatarUrl;
@end

NS_ASSUME_NONNULL_END
