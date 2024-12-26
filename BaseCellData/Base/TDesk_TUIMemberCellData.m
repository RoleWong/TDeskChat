//
//  TDeskMemberCellData.m
//  TUIChat
//
//  Created by xia on 2022/3/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIMemberCellData.h"

@implementation TDeskMemberDescribeCellData

@end

@implementation TDeskMemberCellData

- (instancetype)initWithUserID:(nonnull NSString *)userID
                      nickName:(nullable NSString *)nickName
                  friendRemark:(nullable NSString *)friendRemark
                      nameCard:(nullable NSString *)nameCard
                     avatarUrl:(nonnull NSString *)avatarUrl
                        detail:(nullable NSString *)detail {
    self = [super init];
    
    if (userID.length > 0) {
        _userID = userID;
    }

    if (avatarUrl.length > 0) {
        _avatarUrL = [NSURL URLWithString:avatarUrl];
    }
    _detail = detail;

    if (nameCard.length > 0) {
        _title = nameCard;
    } else if (friendRemark.length > 0) {
        _title = friendRemark;
    } else if (nickName.length > 0) {
        _title = nickName;
    } else {
        _title = userID;
    }

    return self;
}

@end
