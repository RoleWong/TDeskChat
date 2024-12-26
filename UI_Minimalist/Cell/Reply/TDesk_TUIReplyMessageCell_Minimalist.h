//
//  TUIReplyMessageCell_Minimalist.h
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIBubbleMessageCell_Minimalist.h>
#import "TDesk_TUIChatDefine.h"

@class TDeskReplyMessageCellData;
@class TDeskReplyQuoteViewData;
@class TUIImageVideoReplyQuoteViewData;
@class TUIVoiceFileReplyQuoteViewData;
@class TDeskMergeReplyQuoteViewData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReplyMessageCell_Minimalist : TDeskBubbleMessageCell_Minimalist

@property(nonatomic, strong) UIView *quoteBorderLine;
@property(nonatomic, strong) UIView *quoteView;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UILabel *senderLabel;

@property(nonatomic, strong) TDeskReplyMessageCellData *replyData;

- (void)fillWithData:(TDeskReplyMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
