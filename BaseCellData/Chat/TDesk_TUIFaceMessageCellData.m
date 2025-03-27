//
//  TFaceMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIFaceMessageCellData.h"
#import <TDeskCommon/TDesk_TIMDefine.h>

@implementation TDeskFaceMessageCellData

+ (TDeskMessageCellData *)getCellData:(V2TIMMessage *)message {
    V2TIMFaceElem *elem = message.faceElem;
    TDeskFaceMessageCellData *faceData = [[TDeskFaceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    faceData.groupIndex = elem.index;
    faceData.faceName = [[NSString alloc] initWithData:elem.data encoding:NSUTF8StringEncoding];
    for (TDeskFaceGroup *group in [TDeskIMConfig defaultConfig].faceGroups) {
        if (group.groupIndex == faceData.groupIndex) {
            NSString *path = [group.groupPath stringByAppendingPathComponent:faceData.faceName];
            faceData.path = path;
            break;
        }
    }
    faceData.reuseId = TFaceMessageCell_ReuseId;
    return faceData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return TDeskIMCommonLocalizableString(TUIKitMessageTypeAnimateEmoji);
}

@end
