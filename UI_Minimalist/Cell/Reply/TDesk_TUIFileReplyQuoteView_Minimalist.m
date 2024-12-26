//
//  TUIFileReplyQuoteView_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIFileReplyQuoteView_Minimalist.h"
#import "TDesk_TUIFileReplyQuoteViewData.h"

@implementation TUIFileReplyQuoteView_Minimalist

- (void)fillWithData:(TDeskReplyQuoteViewData *)data {
    [super fillWithData:data];
    if (![data isKindOfClass:TDeskFileReplyQuoteViewData.class]) {
        return;
    }
    self.textLabel.numberOfLines = 1;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
}
@end
