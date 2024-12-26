
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TDeskCommon/TDesk_TUIBubbleMessageCell.h>
#import <TDeskCommon/TDesk_TUITextView.h>
#import "TDesk_TUIChatDefine.h"
#import "TDesk_TUITextMessageCellData.h"

@class TDeskTextView;

typedef void (^TUIChatSelectAllContentCallback)(BOOL);

@interface TDeskTextMessageCell : TDeskBubbleMessageCell <UITextViewDelegate>

/**
 *  
 *  TextView for display text message content
 */
@property(nonatomic, strong) TDeskTextView *textView;

/**
 *  
 *  Selected text content
 */
@property(nonatomic, strong) NSString *selectContent;

/**
 *  
 *  Callback for selected all text
 */
@property(nonatomic, strong) TUIChatSelectAllContentCallback selectAllContentContent;

/// Data for text message cell.
@property(nonatomic, strong) TDeskTextMessageCellData *textData;

@property(nonatomic, strong) UIImageView *voiceReadPoint;

- (void)fillWithData:(TDeskTextMessageCellData *)data;

@end


@interface TDeskTextMessageCell (TUILayoutConfiguration)

/**
 *
 *  The color of label which displays the text message content.
 *  Used when the message direction is send.
 */
@property(nonatomic, class) UIColor *outgoingTextColor;

/**
 *
 *  The font of label which displays the text message content.
 *  Used when the message direction is send.
 */
@property(nonatomic, class) UIFont *outgoingTextFont;

/**
 *
 *  The color of label which displays the text message content.
 *  Used when the message direction is received.
 */
@property(nonatomic, class) UIColor *incommingTextColor;

/**
 *
 *  The font of label which displays the text message content.
 *  Used when the message direction is received.
 */
@property(nonatomic, class) UIFont *incommingTextFont;

+ (void)setMaxTextSize:(CGSize)maxTextSz;

@end
