//
//  TDeskMergeReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIMergeReplyQuoteViewData.h"
#import <TDeskCommon/TDesk_NSString+TUIEmoji.h>
#import "TDesk_TUIMergeMessageCellData.h"

@implementation TDeskMergeReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TDeskMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TDeskMergeMessageCellData.class]) {
        return nil;
    }

    TDeskMergeReplyQuoteViewData *myData = [[TDeskMergeReplyQuoteViewData alloc] init];
    myData.title = [(TDeskMergeMessageCellData *)originCellData title];
    NSAttributedString *abstract = [(TDeskMergeMessageCellData *)originCellData abstractAttributedString];
    myData.abstract = abstract.string;
    myData.originCellData = originCellData;
    return myData;
}

- (CGSize)contentSize:(CGFloat)maxWidth {
    CGFloat singleHeight = [UIFont systemFontOfSize:10.0].lineHeight;
    NSAttributedString *titleAttributeString = [self.title getFormatEmojiStringWithFont:[UIFont systemFontOfSize:10.0] emojiLocations:nil];
    CGRect titleRect = [titleAttributeString boundingRectWithSize:CGSizeMake(maxWidth, singleHeight)
                                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                          context:nil];
    CGFloat width = titleRect.size.width;
    CGFloat height = titleRect.size.height;
    return CGSizeMake(MIN(width, maxWidth), height);
}

@end
