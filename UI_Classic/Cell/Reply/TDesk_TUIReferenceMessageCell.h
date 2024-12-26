//
//  TDeskReferenceMessageCell.h
//  TUIChat
//
//  Created by wyl on 2022/5/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIBubbleMessageCell.h>
#import "TDesk_TUIChatDefine.h"

@class TDeskReplyMessageCellData;
@class TDeskReplyQuoteViewData;
@class TUIImageVideoReplyQuoteViewData;
@class TUIVoiceFileReplyQuoteViewData;
@class TDeskMergeReplyQuoteViewData;
@class TDeskReferenceMessageCellData;
@class TDeskTextView;

NS_ASSUME_NONNULL_BEGIN

@interface TDeskReferenceMessageCell : TDeskBubbleMessageCell
/**
 * 
 * Border of quote view
 */
@property(nonatomic, strong) CALayer *quoteBorderLayer;

@property(nonatomic, strong) UIView *quoteView;

@property(nonatomic, strong) UILabel *senderLabel;

@property(nonatomic, strong) TDeskReferenceMessageCellData *referenceData;

@property(nonatomic, strong) TDeskTextView *textView;
@property(nonatomic, strong) NSString *selectContent;
@property(nonatomic, strong) TUIReferenceSelectAllContentCallback selectAllContentContent;

- (void)fillWithData:(TDeskReferenceMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
