//
//  TDeskTextReplyQuoteView.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUITextReplyQuoteView.h"
#import <TDeskCommon/TDesk_NSString+TUIEmoji.h>
#import <TDeskCore/TDesk_TUIThemeManager.h>
#import "TDesk_TUITextReplyQuoteViewData.h"

@implementation TDeskTextReplyQuoteView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:10.0];
        _textLabel.textColor = TUIChatDynamicColor(@"chat_reply_message_sender_text_color", @"888888");
        _textLabel.numberOfLines = 2;
        [self addSubview:_textLabel];
    }
    return self;
}


+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)fillWithData:(TDeskReplyQuoteViewData *)data {
    [super fillWithData:data];
    if (![data isKindOfClass:TDeskTextReplyQuoteViewData.class]) {
        return;
    }
    TDeskTextReplyQuoteViewData *myData = (TDeskTextReplyQuoteViewData *)data;
    BOOL showRevokeStr = data.originCellData.innerMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED &&
                            !data.showRevokedOriginMessage;
    if (showRevokeStr) {
        NSString* revokeStr = data.supportForReply ?
        TIMCommonLocalizableString(TUIKitRepliesOriginMessageRevoke) :
        TIMCommonLocalizableString(TUIKitReferenceOriginMessageRevoke);
        self.textLabel.attributedText = [revokeStr getFormatEmojiStringWithFont:self.textLabel.font emojiLocations:nil];
    }
    else {
        self.textLabel.attributedText = [myData.text getFormatEmojiStringWithFont:self.textLabel.font emojiLocations:nil];
    }

    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

- (void)reset {
    self.textLabel.text = @"";
}

@end
