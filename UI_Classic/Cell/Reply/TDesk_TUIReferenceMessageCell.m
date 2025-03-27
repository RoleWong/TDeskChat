//
//  TDeskReferenceMessageCell.m
//  TUIChat
//
//  Created by wyl on 2022/5/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIReferenceMessageCell.h"
#import <TDeskCommon/TDesk_NSString+TUIEmoji.h>
#import <TDeskCore/TDesk_TUICore.h>
#import <TDeskCore/TDesk_TUIDarkModel.h>
#import <TDeskCore/TDesk_TUIThemeManager.h>
#import <TDeskCore/TDesk_UIView+TUILayout.h>
#import "TDesk_TUIFileMessageCellData.h"
#import "TDesk_TUIImageMessageCellData.h"
#import "TDesk_TUILinkCellData.h"
#import "TDesk_TUIMergeMessageCellData.h"
#import "TDesk_TUIReplyMessageCell.h"
#import "TDesk_TUIReplyMessageCellData.h"
#import "TDesk_TUITextMessageCellData.h"
#import "TDesk_TUIVideoMessageCellData.h"
#import "TDesk_TUIVoiceMessageCellData.h"

#import "TDesk_TUIFileReplyQuoteView.h"
#import "TDesk_TUIImageReplyQuoteView.h"
#import "TDesk_TUIMergeReplyQuoteView.h"
#import "TDesk_TUIReplyQuoteView.h"
#import "TDesk_TUITextMessageCell.h"
#import "TDesk_TUITextReplyQuoteView.h"
#import "TDesk_TUIVideoReplyQuoteView.h"
#import "TDesk_TUIVoiceReplyQuoteView.h"

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@interface TDeskReferenceMessageCell () <UITextViewDelegate>

@property(nonatomic, strong) TDeskReplyQuoteView *currentOriginView;
@property(nonatomic, strong) NSMutableDictionary<NSString *, TDeskReplyQuoteView *> *customOriginViewsCache;

@end

@implementation TDeskReferenceMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self setupContentTextView];
    [self.quoteView addSubview:self.senderLabel];
    [self.contentView addSubview:self.quoteView];

    self.bottomContainer = [[UIView alloc] init];
    [self.contentView addSubview:self.bottomContainer];
}
- (void)setupContentTextView {
    self.textView = [[TDeskTextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.scrollEnabled = NO;
    self.textView.editable = NO;
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16.0];
    self.textView.textColor = TDeskChatDynamicColor(@"chat_reference_message_content_text_color", @"#000000");

    [self.bubbleView addSubview:self.textView];
}

- (void)fillWithData:(TDeskReferenceMessageCellData *)data {
    [super fillWithData:data];
    self.referenceData = data;
    self.senderLabel.text = [NSString stringWithFormat:@"%@:", data.sender];
    self.selectContent = data.content;
    self.textView.attributedText = [data.content getFormatEmojiStringWithFont:self.textView.font emojiLocations:self.referenceData.emojiLocations];

    self.bottomContainer.hidden = CGSizeEqualToSize(data.bottomContainerSize, CGSizeZero);

    @weakify(self);
    [[RACObserve(data, originMessage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(V2TIMMessage *originMessage) {
      @strongify(self);
        // tell constraints they need updating
        [self setNeedsUpdateConstraints];

        // update constraints now so we can animate the change
        [self updateConstraintsIfNeeded];

        [self layoutIfNeeded];
    }];

    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
    
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    
    [self updateUI:self.referenceData];
    
    [self layoutBottomContainer];

}

// Override
- (void)notifyBottomContainerReadyOfData:(TDeskMessageCellData *)cellData {
    NSDictionary *param = @{TDeskCore_TUIChatExtension_BottomContainer_CellData : self.referenceData};
    [TDeskCore raiseExtension:TDeskCore_TUIChatExtension_BottomContainer_ClassicExtensionID parentView:self.bottomContainer param:param];
}

- (void)updateUI:(TDeskReferenceMessageCellData *)referenceData {
    self.currentOriginView = [self getCustomOriginView:referenceData.originCellData];
    [self hiddenAllCustomOriginViews:YES];
    self.currentOriginView.hidden = NO;

    referenceData.quoteData.supportForReply = NO;
    referenceData.quoteData.showRevokedOriginMessage = referenceData.showRevokedOriginMessage;
    [self.currentOriginView fillWithData:referenceData.quoteData];

    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bubbleView.mas_leading).mas_offset(self.referenceData.textOrigin.x);
        make.top.mas_equalTo(self.bubbleView.mas_top).mas_offset(self.referenceData.textOrigin.y);
        make.size.mas_equalTo(self.referenceData.textSize);
    }];

    if (referenceData.direction == MsgDirectionIncoming) {
        self.textView.textColor = TDeskChatDynamicColor(@"chat_reference_message_content_recv_text_color", @"#000000");
        self.senderLabel.textColor = TDeskChatDynamicColor(@"chat_reference_message_quoteView_recv_text_color", @"#888888");
        self.quoteView.backgroundColor = TDeskChatDynamicColor(@"chat_reference_message_quoteView_bg_color", @"#4444440c");
    } else {
        self.textView.textColor = TDeskChatDynamicColor(@"chat_reference_message_content_text_color", @"#000000");
        self.senderLabel.textColor = TDeskChatDynamicColor(@"chat_reference_message_quoteView_text_color", @"#888888");
        self.quoteView.backgroundColor = TDeskChatDynamicColor(@"chat_reference_message_quoteView_bg_color", @"#4444440c");
    }
    if (referenceData.textColor) {
        self.textView.textColor = referenceData.textColor;
    }
    
    BOOL hasRiskContent = self.messageData.innerMessage.hasRiskContent;
    if (hasRiskContent ) {
        [self.securityStrikeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.textView.mas_bottom);
            make.width.mas_equalTo(self.bubbleView);
            make.bottom.mas_equalTo(self.container);
        }];
    }
    
    [self.senderLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.quoteView).mas_offset(6);
        make.top.mas_equalTo(self.quoteView).mas_offset(8);
        make.width.mas_equalTo(referenceData.senderSize.width);
        make.height.mas_equalTo(referenceData.senderSize.height);
    }];
    
    BOOL hideSenderLabel = (referenceData.originCellData.innerMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) &&
                            !referenceData.showRevokedOriginMessage;
    if (hideSenderLabel) {
        self.senderLabel.hidden = YES;
    } else {
        self.senderLabel.hidden = NO;
    }
    
    [self.quoteView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.referenceData.direction == MsgDirectionIncoming) {
            make.leading.mas_equalTo(self.bubbleView);
        }
        else {
            make.trailing.mas_equalTo(self.bubbleView);
        }
        make.top.mas_equalTo(self.container.mas_bottom).mas_offset(6);
        make.size.mas_equalTo(self.referenceData.quoteSize);
    }];
    
    if (self.referenceData.showMessageModifyReplies) {
        [self.messageModifyRepliesButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.referenceData.direction == MsgDirectionIncoming) {
                make.leading.mas_equalTo(self.quoteView.mas_leading);
            }
            else {
                make.trailing.mas_equalTo(self.quoteView.mas_trailing);
            }
            make.top.mas_equalTo(self.quoteView.mas_bottom).mas_offset(3);
            make.size.mas_equalTo(self.messageModifyRepliesButton.frame.size);
        }];
    }
    [self.currentOriginView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (hideSenderLabel) {
            make.leading.mas_equalTo(self.quoteView).mas_offset(6);
            make.top.mas_equalTo(self.quoteView).mas_offset(8);
            make.trailing.mas_lessThanOrEqualTo(self.quoteView.mas_trailing);
            make.height.mas_equalTo(self.referenceData.quotePlaceholderSize);
        }
        else {
            make.leading.mas_equalTo(self.senderLabel.mas_trailing).mas_offset(3);
            make.top.mas_equalTo(self.senderLabel.mas_top).mas_offset(1);
            make.trailing.mas_lessThanOrEqualTo(self.quoteView.mas_trailing);
            make.height.mas_equalTo(self.referenceData.quotePlaceholderSize);
        }
    }];
    
}

- (TDeskReplyQuoteView *)getCustomOriginView:(TDeskMessageCellData *)originCellData {
    NSString *reuseId = originCellData ? NSStringFromClass(originCellData.class) : NSStringFromClass(TDeskTextMessageCellData.class);
    TDeskReplyQuoteView *view = nil;
    BOOL reuse = NO;
    BOOL hasRiskContent = originCellData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        reuseId = @"hasRiskContent";
    }
    if ([self.customOriginViewsCache.allKeys containsObject:reuseId]) {
        view = [self.customOriginViewsCache objectForKey:reuseId];
        reuse = YES;
    }
    
    if (hasRiskContent && view == nil){
        TDeskTextReplyQuoteView *quoteView = [[TDeskTextReplyQuoteView alloc] init];
        view = quoteView;
    }
    
    if (view == nil) {
        Class class = [originCellData getReplyQuoteViewClass];
        if (class) {
            view = [[class alloc] init];
        }
    }

    if (view == nil) {
        TDeskTextReplyQuoteView *quoteView = [[TDeskTextReplyQuoteView alloc] init];
        view = quoteView;
    }

    if ([view isKindOfClass:[TDeskTextReplyQuoteView class]]) {
        TDeskTextReplyQuoteView *quoteView = (TDeskTextReplyQuoteView *)view;
        if (self.referenceData.direction == MsgDirectionIncoming) {
            quoteView.textLabel.textColor = TDeskChatDynamicColor(@"chat_reference_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.textLabel.textColor = TDeskChatDynamicColor(@"chat_reference_message_quoteView_text_color", @"#888888");
        }
    } else if ([view isKindOfClass:[TDeskMergeReplyQuoteView class]]) {
        TDeskMergeReplyQuoteView *quoteView = (TDeskMergeReplyQuoteView *)view;
        if (self.referenceData.direction == MsgDirectionIncoming) {
            quoteView.titleLabel.textColor = TDeskChatDynamicColor(@"chat_reference_message_quoteView_recv_text_color", @"#888888");
        } else {
            quoteView.titleLabel.textColor = TDeskChatDynamicColor(@"chat_reference_message_quoteView_text_color", @"#888888");
        }
    }

    if (!reuse) {
        [self.customOriginViewsCache setObject:view forKey:reuseId];
        [self.quoteView addSubview:view];
    }

    view.hidden = YES;
    return view;
}

- (void)hiddenAllCustomOriginViews:(BOOL)hidden {
    [self.customOriginViewsCache enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, TDeskReplyQuoteView *_Nonnull obj, BOOL *_Nonnull stop) {
      obj.hidden = hidden;
      [obj reset];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)layoutBottomContainer {
    if (CGSizeEqualToSize(self.referenceData.bottomContainerSize, CGSizeZero)) {
        return;
    }

    CGSize size = self.referenceData.bottomContainerSize;
    CGFloat topMargin = self.bubbleView.mm_maxY + self.nameLabel.mm_h + 6;

    [self.bottomContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (!self.messageModifyRepliesButton.isHidden){
            make.top.mas_equalTo(self.messageModifyRepliesButton.mas_bottom).mas_offset(8);
        }
        else {
            make.top.mas_equalTo(self.quoteView.mas_bottom).mas_offset(8);
        }
        make.size.mas_equalTo(size);
        if (self.referenceData.direction == MsgDirectionOutgoing) {
            make.trailing.mas_equalTo(self.container);
        }
        else {
            make.leading.mas_equalTo(self.container);
        }
    }];

    if (!self.quoteView.hidden) {
        CGRect oldRect = self.quoteView.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.bottomContainer.frame) + 5, oldRect.size.width, oldRect.size.height);
        self.quoteView.frame = newRect;
    }
    if (!self.messageModifyRepliesButton.hidden) {
        CGRect oldRect = self.messageModifyRepliesButton.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.quoteView.frame), oldRect.size.width, oldRect.size.height);
        self.messageModifyRepliesButton.frame = newRect;
    }
}

- (UILabel *)senderLabel {
    if (_senderLabel == nil) {
        _senderLabel = [[UILabel alloc] init];
        _senderLabel.text = @"harvy:";
        _senderLabel.font = [UIFont systemFontOfSize:12.0];
        _senderLabel.textColor = TDeskChatDynamicColor(@"chat_reference_message_sender_text_color", @"#888888");
    }
    return _senderLabel;
}

- (UIView *)quoteView {
    if (_quoteView == nil) {
        _quoteView = [[UIView alloc] init];
        _quoteView.backgroundColor = TDeskChatDynamicColor(@"chat_reference_message_quoteView_bg_color", @"#4444440c");
        _quoteView.layer.cornerRadius = 4.0;
        _quoteView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quoteViewOnTap)];
        [_quoteView addGestureRecognizer:tap];
    }
    return _quoteView;
}

- (void)quoteViewOnTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectMessage:)]) {
        [self.delegate onSelectMessage:self];
    }
}

- (NSMutableDictionary *)customOriginViewsCache {
    if (_customOriginViewsCache == nil) {
        _customOriginViewsCache = [[NSMutableDictionary alloc] init];
    }
    return _customOriginViewsCache;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSAttributedString *selectedString = [textView.attributedText attributedSubstringFromRange:textView.selectedRange];
    if (self.selectAllContentContent && selectedString) {
        if (selectedString.length == textView.attributedText.length) {
            self.selectAllContentContent(YES);
        } else {
            self.selectAllContentContent(NO);
        }
    }
    if (selectedString.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        [attributedString appendAttributedString:selectedString];
        NSUInteger offsetLocation = 0;
        for (NSDictionary *emojiLocation in self.referenceData.emojiLocations) {
            NSValue *key = emojiLocation.allKeys.firstObject;
            NSAttributedString *originStr = emojiLocation[key];
            NSRange currentRange = [key rangeValue];
            currentRange.location += offsetLocation;
            if (currentRange.location >= textView.selectedRange.location) {
                currentRange.location -= textView.selectedRange.location;
                if (currentRange.location + currentRange.length <= attributedString.length) {
                    [attributedString replaceCharactersInRange:currentRange withAttributedString:originStr];
                    offsetLocation += originStr.length - currentRange.length;
                }
            }
        }
        self.selectContent = attributedString.string;
    } else {
        self.selectContent = nil;
    }
}

#pragma mark - TDeskMessageCellProtocol
+ (CGFloat)getHeight:(TDeskMessageCellData *)data withWidth:(CGFloat)width {
    NSAssert([data isKindOfClass:TDeskReferenceMessageCellData.class], @"data must be kind of TDeskReferenceMessageCellData");
    TDeskReferenceMessageCellData *referenceCellData = (TDeskReferenceMessageCellData *)data;
    
    CGFloat cellHeight = [super getHeight:data withWidth:width];
    cellHeight += referenceCellData.quoteSize.height + referenceCellData.bottomContainerSize.height;
    cellHeight += kScale375(6);
    return cellHeight;
}

+ (CGSize)getContentSize:(TDeskMessageCellData *)data {
    NSAssert([data isKindOfClass:TDeskReferenceMessageCellData.class], @"data must be kind of TDeskReferenceMessageCellData");
    TDeskReferenceMessageCellData *referenceCellData = (TDeskReferenceMessageCellData *)data;
    
    CGFloat quoteHeight = 0;
    CGFloat quoteWidth = 0;
    CGFloat quoteMaxWidth = TReplyQuoteView_Max_Width;
    CGFloat quotePlaceHolderMarginWidth = 12;

    // Calculate the size of label which displays the sender's displayname
    CGSize senderSize = [@"0" sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}];
    CGRect senderRect = [[NSString stringWithFormat:@"%@:",referenceCellData.sender] boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                               context:nil];
    

    // Calculate the size of customize quote placeholder view
    CGSize placeholderSize = [referenceCellData quotePlaceholderSizeWithType:referenceCellData.originMsgType data:referenceCellData.quoteData];

    // Calculate the size of revoke string
    CGRect messageRevokeRect = CGRectZero;
    bool showRevokeStr = (referenceCellData.originCellData.innerMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) &&
                            !referenceCellData.showRevokedOriginMessage;
    if (showRevokeStr) {
        NSString *msgRevokeStr = TDeskIMCommonLocalizableString(TUIKitReferenceOriginMessageRevoke);
        messageRevokeRect = [msgRevokeStr boundingRectWithSize:CGSizeMake(quoteMaxWidth, senderSize.height)
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                    attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]}
                                                       context:nil];
    }

    // Calculate the size of label which displays the content of replying the original message
    NSAttributedString *attributeString = [referenceCellData.content getFormatEmojiStringWithFont:[UIFont systemFontOfSize:16.0] emojiLocations:nil];

    CGRect replyContentRect = [attributeString boundingRectWithSize:CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT)
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            context:nil];
    CGSize size = CGSizeMake(CGFLOAT_CEIL(replyContentRect.size.width), CGFLOAT_CEIL(replyContentRect.size.height));
    referenceCellData.textSize = size;
    referenceCellData.textOrigin = CGPointMake(referenceCellData.cellLayout.bubbleInsets.left,
                                               referenceCellData.cellLayout.bubbleInsets.top + [TDeskBubbleMessageCell getBubbleTop:referenceCellData]);

    size.height += referenceCellData.cellLayout.bubbleInsets.top + referenceCellData.cellLayout.bubbleInsets.bottom;
    size.width += referenceCellData.cellLayout.bubbleInsets.left + referenceCellData.cellLayout.bubbleInsets.right;

    if (referenceCellData.direction == MsgDirectionIncoming) {
        size.height = MAX(size.height, TDeskBubbleMessageCell.incommingBubble.size.height);
    } else {
        size.height = MAX(size.height, TDeskBubbleMessageCell.outgoingBubble.size.height);
    }

    BOOL hasRiskContent = referenceCellData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        size.width = MAX(size.width, 200);// width must more than  TDeskIMCommonLocalizableString(TUIKitMessageTypeSecurityStrike)
        size.height += kTUISecurityStrikeViewTopLineMargin;
        size.height += kTUISecurityStrikeViewTopLineToBottom;
    }

    quoteWidth = senderRect.size.width;
    quoteWidth += placeholderSize.width;
    quoteWidth += (quotePlaceHolderMarginWidth * 2);
    
    if (showRevokeStr) {
        quoteWidth = messageRevokeRect.size.width;
    }
    
    quoteHeight = MAX(senderRect.size.height, placeholderSize.height);
    quoteHeight += (8 + 8);

    referenceCellData.senderSize = CGSizeMake(senderRect.size.width, senderRect.size.height);
    referenceCellData.quotePlaceholderSize = placeholderSize;
    //    self.replyContentSize = CGSizeMake(replyContentRect.size.width, replyContentRect.size.height);
    referenceCellData.quoteSize = CGSizeMake(quoteWidth, quoteHeight);

    return size;
}

@end
