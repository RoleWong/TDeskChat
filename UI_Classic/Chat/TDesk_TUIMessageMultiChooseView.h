
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TDeskMessageMultiChooseView;

@protocol TDeskMessageMultiChooseViewDelegate <NSObject>

/**
 * Callback when the cancel button on the multi-select message panel is clicked
 */
- (void)messageMultiChooseViewOnCancelClicked:(TDeskMessageMultiChooseView *)multiChooseView;

/**
 * Callback for when the forward button on the multi-select message panel is clicked
 */
- (void)messageMultiChooseViewOnRelayClicked:(TDeskMessageMultiChooseView *)multiChooseView;

/**
 * Callback for when the delete button on the multi-select message panel is clicked
 */
- (void)messageMultiChooseViewOnDeleteClicked:(TDeskMessageMultiChooseView *)multiChooseView;

@end

@interface TDeskMessageMultiChooseView : UIView

@property(nonatomic, weak) id<TDeskMessageMultiChooseViewDelegate> delegate;

#pragma mark - Top toolbar
/**
 * The top toolbar, showing shortcut operations such as cancel
 */
@property(nonatomic, strong) UIView *toolView;

/**
 * Top toolbar element: Cancel button
 */
@property(nonatomic, strong) UIButton *cancelButton;

/**
 * Top toolbar element: title
 */
@property(nonatomic, strong) UILabel *titleLabel;

#pragma mark - Bottom menu bar
/**
 * The bottom menu bar,  shows the operation menu after multiple selection messages, such as forwarding, deleting, etc.
 */
@property(nonatomic, strong) UIView *menuView;

/**
 * Bottom menu bar element: Forward button
 */
@property(nonatomic, strong) UIButton *relayButton;

/**
 * Bottom menu bar element: Delete button
 */
@property(nonatomic, strong) UIButton *deleteButton;

@end

NS_ASSUME_NONNULL_END
