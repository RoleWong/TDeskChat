//
//  TDeskMessageSearchDataProvider.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/7/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIMessageMediaDataProvider.h"
#import "TDesk_TUIImageMessageCellData.h"
#import "TDesk_TUIMessageBaseDataProvider+ProtectedAPI.h"
#import "TDesk_TUIVideoMessageCellData.h"

@implementation TDeskMessageMediaDataProvider

+ (TDeskMessageCellData *)getMediaCellData:(V2TIMMessage *)message {
    if (message.status == V2TIM_MSG_STATUS_HAS_DELETED || message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        return nil;
    }
    TDeskMessageCellData *data = nil;
    if (message.elemType == V2TIM_ELEM_TYPE_IMAGE) {
        data = [TDeskImageMessageCellData getCellData:message];
    } else if (message.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        data = [TDeskVideoMessageCellData getCellData:message];
    }
    if (data) {
        data.innerMessage = message;
    }
    return data;
}

@end
