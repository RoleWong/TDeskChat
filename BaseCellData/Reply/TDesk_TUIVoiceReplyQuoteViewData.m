//
//  TDeskVoiceReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIVoiceReplyQuoteViewData.h"
#import <TDeskCommon/TDesk_NSString+TUIEmoji.h>
#import <TDeskCore/TDesk_TUIThemeManager.h>
#import "TDesk_TUIVoiceMessageCellData.h"
@implementation TDeskVoiceReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TDeskMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TDeskVoiceMessageCellData.class]) {
        return nil;
    }

    TDeskVoiceReplyQuoteViewData *myData = [[TDeskVoiceReplyQuoteViewData alloc] init];
    myData.text = [NSString stringWithFormat:@"%d\"", [(TDeskVoiceMessageCellData *)originCellData duration]];
    myData.icon = TUIChatCommonBundleImage(@"voice_reply");
    myData.originCellData = originCellData;
    return myData;
}

- (CGSize)contentSize:(CGFloat)maxWidth {
    CGFloat marginWidth = 18;
    CGSize size = [@"0" sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0]}];
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(maxWidth - marginWidth, size.height)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0]}
                                          context:nil];
    return CGSizeMake(rect.size.width + marginWidth, size.height);
}

@end
