//
//  TDeskFileReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIFileReplyQuoteViewData.h"
#import <TDeskCore/TDesk_TUIThemeManager.h>
#import "TDesk_TUIFileMessageCellData.h"

@implementation TDeskFileReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TDeskMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TDeskFileMessageCellData.class]) {
        return nil;
    }

    TDeskFileReplyQuoteViewData *myData = [[TDeskFileReplyQuoteViewData alloc] init];
    myData.text = [(TDeskFileMessageCellData *)originCellData fileName];
    myData.icon = TUIChatCommonBundleImage(@"msg_file");
    myData.originCellData = originCellData;
    return myData;
}

@end
