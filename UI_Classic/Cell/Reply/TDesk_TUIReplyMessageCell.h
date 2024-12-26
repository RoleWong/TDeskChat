//
//  TDeskReplyMessageCell.h
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIBubbleMessageCell.h>
#import <TDeskCommon/TDesk_TUITextView.h>
#import "TDesk_TUIChatDefine.h"

@class TDeskReplyMessageCellData;
@class TDeskReplyQuoteViewData;
@class TUIImageVideoReplyQuoteViewData;
@class TUIVoiceFileReplyQuoteViewData;
@class TDeskMergeReplyQuoteViewData;

NS_ASSUME_NONNULL_BEGIN

@interface TDeskReplyMessageCell : TDeskBubbleMessageCell

@property(nonatomic, strong) UIView *quoteBorderLine;
@property(nonatomic, strong) UIView *quoteView;

@property(nonatomic, strong) TDeskTextView *textView;
@property(nonatomic, strong) NSString *selectContent;
@property(nonatomic, strong) TUIReplySelectAllContentCallback selectAllContentContent;

@property(nonatomic, strong) UILabel *senderLabel;

@property(nonatomic, strong) TDeskReplyMessageCellData *replyData;

- (void)fillWithData:(TDeskReplyMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
