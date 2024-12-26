//
//  TDeskTypingStatusCellData.m
//  TUIChat
//
//  Created by wyl on 2022/7/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUITypingStatusCellData.h"

@implementation TDeskTypingStatusCellData

+ (TDeskMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    TDeskTypingStatusCellData *cellData = [[TDeskTypingStatusCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.msgID = message.msgID;

    if ([param.allKeys containsObject:@"typingStatus"]) {
        cellData.typingStatus = [param[@"typingStatus"] intValue];
    }

    return cellData;
}

@end
