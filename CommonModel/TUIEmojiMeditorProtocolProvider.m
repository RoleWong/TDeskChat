//
//  TUIEmojiMeditorProtocolProvider.m
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/11/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIEmojiMeditorProtocolProvider.h"
#import <TDeskCommon/TUIEmojiMeditorProtocol.h>
#import <TDeskCommon/TIMCommonMediator.h>
#import <TDeskCommon/TIMCommonModel.h>
#import "TUIEmojiConfig.h"

@implementation TUIEmojiMeditorProtocolProvider
+ (void)load {
    [TIMCommonMediator.share registerService:@protocol(TUIEmojiMeditorProtocol) class:self];
}

- (id)getFaceGroup {
    return [TUIEmojiConfig.defaultConfig faceGroups];
}
- (void)appendFaceGroup:(TUIFaceGroup *)faceGroup {
    [TUIEmojiConfig.defaultConfig appendFaceGroup:faceGroup];
}

- (id)getChatPopDetailGroups {
    return [TUIEmojiConfig.defaultConfig chatPopDetailGroups];
}

- (id)getChatContextEmojiDetailGroups {
    return [TUIEmojiConfig.defaultConfig chatContextEmojiDetailGroups];
}

- (id)getChatPopMenuRecentQueue {
    return [TUIEmojiConfig.defaultConfig getChatPopMenuRecentQueue];
}

- (void)updateRecentMenuQueue:(NSString *)faceName {
    [TUIEmojiConfig.defaultConfig updateRecentMenuQueue:faceName];
}

- (void)updateEmojiGroups {
    [TUIEmojiConfig.defaultConfig updateEmojiGroups];
}
@end
