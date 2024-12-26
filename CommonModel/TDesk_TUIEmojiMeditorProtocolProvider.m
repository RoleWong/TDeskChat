//
//  TUIEmojiMeditorProtocolProvider.m
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/11/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIEmojiMeditorProtocolProvider.h"
#import <TDeskCommon/TDesk_TUIEmojiMeditorProtocol.h>
#import <TDeskCommon/TDesk_TIMCommonMediator.h>
#import <TDeskCommon/TDesk_TIMCommonModel.h>
#import "TDesk_TUIEmojiConfig.h"

@implementation TUIEmojiMeditorProtocolProvider
+ (void)load {
    [TDeskCommonMediator.share registerService:@protocol(TDeskEmojiMeditorProtocol) class:self];
}

- (id)getFaceGroup {
    return [TDeskEmojiConfig.defaultConfig faceGroups];
}
- (void)appendFaceGroup:(TDeskFaceGroup *)faceGroup {
    [TDeskEmojiConfig.defaultConfig appendFaceGroup:faceGroup];
}

- (id)getChatPopDetailGroups {
    return [TDeskEmojiConfig.defaultConfig chatPopDetailGroups];
}

- (id)getChatContextEmojiDetailGroups {
    return [TDeskEmojiConfig.defaultConfig chatContextEmojiDetailGroups];
}

- (id)getChatPopMenuRecentQueue {
    return [TDeskEmojiConfig.defaultConfig getChatPopMenuRecentQueue];
}

- (void)updateRecentMenuQueue:(NSString *)faceName {
    [TDeskEmojiConfig.defaultConfig updateRecentMenuQueue:faceName];
}

- (void)updateEmojiGroups {
    [TDeskEmojiConfig.defaultConfig updateEmojiGroups];
}
@end
