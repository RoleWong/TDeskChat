//
//  TUIReplyQuoteView_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIReplyQuoteView_Minimalist.h"
#import <TDeskCommon/TDesk_NSString+TUIEmoji.h>
#import "TDesk_TUIReplyQuoteViewData.h"

@implementation TUIReplyQuoteView_Minimalist

- (void)fillWithData:(TDeskReplyQuoteViewData *)data {
    _data = data;
}

- (void)reset {
}

@end
