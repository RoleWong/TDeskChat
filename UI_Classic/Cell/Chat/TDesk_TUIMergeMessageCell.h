
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  This document declares the TDeskMergeMessageCell class.
 *  When multiple messages are merged and forwarded, a merged-forward message will be displayed on the chat interface.
 *
 *  When we receive a merged-forward message, it is usually displayed in the chat interface like this:
 *  | History of vinson and lynx                                                                             |        -- title
 *  | vinson：When will the new version of the SDK be released？                      |        -- abstract1
 *  | lynx：Plan for next Monday, the specific time depends on the system test situation in these two days..                                                                                                                                     |        -- abstract2
 *  | vinson：Okay.
 */

#import <TDeskCommon/TDesk_TUIMessageCell.h>
#import "TDesk_TUIMergeMessageCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TDeskMergeMessageCell : TDeskMessageCell
/**
 * Title of merged-forward message
 */
@property(nonatomic, strong) UILabel *relayTitleLabel;

/**
 * Horizontal dividing line
 */
@property(nonatomic, strong) UIView *separtorView;

/**
 *  bottom prompt
 */
@property(nonatomic, strong) UILabel *bottomTipsLabel;

@property(nonatomic, strong) TDeskMergeMessageCellData *mergeData;
- (void)fillWithData:(TDeskMergeMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
