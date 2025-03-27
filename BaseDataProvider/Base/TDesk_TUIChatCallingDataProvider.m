//
//  TDeskChatCallingDataProvider.m
//  TUIChat
//
//  Created by harvy on 2022/12/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIChatCallingDataProvider.h"
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCore/TDesk_TUICore.h>
#import <TDeskCore/TDesk_TUILogin.h>
#import "TDesk_TUIMessageBaseDataProvider.h"

typedef NSString *TDeskChatMessageID;
typedef NSDictionary *TUIChatCallingJsonData;

// ********************************************************************
//                          TDeskChatCallingInfo
// ********************************************************************

@interface TDeskChatCallingInfo : NSObject <TDeskChatCallingInfoProtocol>

@property(nonatomic, strong) TDeskChatMessageID msgID;
@property(nonatomic, strong, nullable) TUIChatCallingJsonData jsonData;
@property(nonatomic, strong, nullable) V2TIMSignalingInfo *signalingInfo;
@property(nonatomic, strong, nullable) V2TIMMessage *innerMessage;
@property(nonatomic, assign) TDeskChatCallingMessageAppearance style;

@end

@implementation TDeskChatCallingInfo

#pragma mark - TDeskChatCallingInfoProtocol

- (TUICallProtocolType)protocolType {
    if (self.jsonData == nil || self.signalingInfo == nil || self.innerMessage == nil) {
        return TUICallProtocolTypeUnknown;
    }

    TUICallProtocolType type = TUICallProtocolTypeUnknown;

    switch (self.signalingInfo.actionType) {
        case SignalingActionType_Invite: {
            NSDictionary *data = [self.jsonData objectForKey:@"data"];
            if (data && [data isKindOfClass:NSDictionary.class]) {
                // New version for calling
                NSString *cmd = [data objectForKey:@"cmd"];
                if ([cmd isKindOfClass:NSString.class]) {
                    if ([cmd isEqualToString:@"switchToAudio"]) {
                        type = TUICallProtocolTypeSwitchToAudio;
                    } else if ([cmd isEqualToString:@"hangup"]) {
                        type = TUICallProtocolTypeHangup;
                    } else if ([cmd isEqualToString:@"videoCall"]) {
                        type = TUICallProtocolTypeSend;
                    } else if ([cmd isEqualToString:@"audioCall"]) {
                        type = TUICallProtocolTypeSend;
                    } else {
                        type = TUICallProtocolTypeUnknown;
                    }
                } else {
                    NSLog(@"calling protocol error, %@", self.jsonData);
                    type = TUICallProtocolTypeUnknown;
                }
            } else {
                // Compatiable
                NSNumber *callEnd = [self.jsonData objectForKey:@"call_end"];
                if (callEnd && [callEnd isKindOfClass:NSNumber.class]) {
                    type = TUICallProtocolTypeHangup;
                } else {
                    type = TUICallProtocolTypeSend;
                }
            }
        } break;
        case SignalingActionType_Cancel_Invite: {
            type = TUICallProtocolTypeCancel;
        } break;
        case SignalingActionType_Accept_Invite: {
            NSDictionary *data = [self.jsonData objectForKey:@"data"];
            if (data && [data isKindOfClass:NSDictionary.class]) {
                // New version for calling
                NSString *cmd = [data objectForKey:@"cmd"];
                if ([cmd isKindOfClass:NSString.class]) {
                    if ([cmd isEqualToString:@"switchToAudio"]) {
                        type = TUICallProtocolTypeSwitchToAudioConfirm;
                    } else {
                        type = TUICallProtocolTypeAccept;
                    }
                } else {
                    NSLog(@"calling protocol error, %@", self.jsonData);
                    type = TUICallProtocolTypeAccept;
                }
            } else {
                // Compatiable
                type = TUICallProtocolTypeAccept;
            }
        } break;
        case SignalingActionType_Reject_Invite: {
            if ([self.jsonData objectForKey:@"line_busy"]) {
                type = TUICallProtocolTypeLineBusy;
            } else {
                type = TUICallProtocolTypeReject;
            }
        } break;
        case SignalingActionType_Invite_Timeout: {
            type = TUICallProtocolTypeTimeout;
        } break;
        default:
            type = TUICallProtocolTypeUnknown;
            break;
    }
    return type;
}

- (TUICallStreamMediaType)streamMediaType {
    TUICallProtocolType protocolType = self.protocolType;
    if (protocolType == TUICallProtocolTypeUnknown) {
        return TUICallStreamMediaTypeUnknown;
    }

    // Default type
    TUICallStreamMediaType type = TUICallStreamMediaTypeUnknown;
    NSNumber *callType = [self.jsonData objectForKey:@"call_type"];
    if (callType && [callType isKindOfClass:NSNumber.class]) {
        if ([callType integerValue] == 1) {
            type = TUICallStreamMediaTypeVoice;
        } else if ([callType integerValue] == 2) {
            type = TUICallStreamMediaTypeVideo;
        }
    }

    // Read from special protocol
    if (protocolType == TUICallProtocolTypeSend) {
        NSDictionary *data = [self.jsonData objectForKey:@"data"];
        if (data && [data isKindOfClass:NSDictionary.class]) {
            NSString *cmd = [data objectForKey:@"cmd"];
            if ([cmd isEqual:@"audioCall"]) {
                type = TUICallStreamMediaTypeVoice;
            } else if ([cmd isEqual:@"videoCall"]) {
                type = TUICallStreamMediaTypeVideo;
            }
        }
    } else if (protocolType == TUICallProtocolTypeSwitchToAudio || protocolType == TUICallProtocolTypeSwitchToAudioConfirm) {
        type = TUICallStreamMediaTypeVideo;
    }

    return type;
}

- (TUICallParticipantType)participantType {
    if (self.protocolType == TUICallProtocolTypeUnknown) {
        return TUICallParticipantTypeUnknown;
    }

    if (self.signalingInfo.groupID.length > 0) {
        return TUICallParticipantTypeGroup;
    } else {
        return TUICallParticipantTypeC2C;
    }
}

- (NSString *)caller {
    NSString *callerID = nil;
    NSDictionary *data = [self.jsonData objectForKey:@"data"];
    if (data && [data isKindOfClass:NSDictionary.class]) {
        NSString *inviter = [data objectForKey:@"inviter"];
        if (inviter && [inviter isKindOfClass:NSString.class]) {
            callerID = inviter;
        }
    }
    if (callerID == nil) {
        callerID = TDeskLogin.getUserID;
    }
    return callerID;
}

- (TUICallParticipantRole)participantRole {
    if ([self.caller isEqualToString:TDeskLogin.getUserID]) {
        return TUICallParticipantRoleCaller;
    } else {
        return TUICallParticipantRoleCallee;
    }
}

- (BOOL)excludeFromHistory {
    if (self.style == TDeskChatCallingMessageAppearanceSimplify) {
        return self.protocolType != TUICallProtocolTypeUnknown && self.innerMessage.isExcludedFromLastMessage && self.innerMessage.isExcludedFromUnreadCount;
    } else {
        return NO;
    }
}

- (NSString *)content {
    if (self.style == TDeskChatCallingMessageAppearanceSimplify) {
        return [self contentForSimplifyAppearance];
    } else {
        return [self contentForDetailsAppearance];
    }
}

- (TUICallMessageDirection)direction {
    if (self.style == TDeskChatCallingMessageAppearanceSimplify) {
        return [self directionForSimplifyAppearance];
    } else {
        return [self directionForDetailsAppearance];
    }
}

- (BOOL)showUnreadPoint {
    if (self.excludeFromHistory) {
        return NO;
    }
    return (self.innerMessage.localCustomInt == 0) && (self.participantRole == TUICallParticipantRoleCallee) &&
           (self.participantType == TUICallParticipantTypeC2C) &&
           (self.protocolType == TUICallProtocolTypeCancel || self.protocolType == TUICallProtocolTypeTimeout ||
            self.protocolType == TUICallProtocolTypeLineBusy);
}

- (BOOL)isUseReceiverAvatar {
    if (self.style == TDeskChatCallingMessageAppearanceSimplify) {
        return [self isUseReceiverAvatarForSimplifyAppearance];
    } else {
        return [self isUseReceiverAvatarForDetailsAppearance];
    }
}

- (NSArray<NSString *> *)participantIDList {
  NSMutableArray *arrayM = [NSMutableArray array];
  if (self.signalingInfo.inviter) {
    [arrayM addObject:self.signalingInfo.inviter];
  }
  if (self.signalingInfo.inviteeList.count > 0) {
    [arrayM addObjectsFromArray:self.signalingInfo.inviteeList];
  }
  return [NSArray arrayWithArray:arrayM];
}

#pragma mark - Details style
- (NSString *)contentForDetailsAppearance {
    TUICallProtocolType protocolType = self.protocolType;
    BOOL isGroup = (self.participantType == TUICallParticipantTypeGroup);

    if (protocolType == TUICallProtocolTypeUnknown) {
        return TDeskIMCommonLocalizableString(TUIkitSignalingUnrecognlize);
    }

    NSString *display = TDeskIMCommonLocalizableString(TUIkitSignalingUnrecognlize);
    NSString *showName = [TDeskMessageBaseDataProvider getShowName:self.innerMessage];

    if (protocolType == TUICallProtocolTypeSend) {
        // Launch call
        display = isGroup ? [NSString stringWithFormat:TDeskIMCommonLocalizableString(TUIKitSignalingNewGroupCallFormat), showName]
                          : TDeskIMCommonLocalizableString(TUIKitSignalingNewCall);
    } else if (protocolType == TUICallProtocolTypeAccept) {
        // Accept call
        display = isGroup ? [NSString stringWithFormat:TDeskIMCommonLocalizableString(TUIKitSignalingHangonCallFormat), showName]
                          : TDeskIMCommonLocalizableString(TUIkitSignalingHangonCall);
    } else if (protocolType == TUICallProtocolTypeReject) {
        // Reject call
        display = isGroup ? [NSString stringWithFormat:TDeskIMCommonLocalizableString(TUIKitSignalingDeclineFormat), showName]
                          : TDeskIMCommonLocalizableString(TUIkitSignalingDecline);
    } else if (protocolType == TUICallProtocolTypeCancel) {
        // Cancel pending call
        display = isGroup ? [NSString stringWithFormat:TDeskIMCommonLocalizableString(TUIkitSignalingCancelGroupCallFormat), showName]
                          : TDeskIMCommonLocalizableString(TUIkitSignalingCancelCall);
    } else if (protocolType == TUICallProtocolTypeHangup) {
        // Hang up
        NSUInteger duration = [[self.jsonData objectForKey:@"call_end"] unsignedIntegerValue];
        display = isGroup
                      ? TDeskIMCommonLocalizableString(TUIKitSignalingFinishGroupChat)
        : [NSString stringWithFormat:@"%@:%.2d:%.2d",TDeskIMCommonLocalizableString(TUIKitSignalingFinishConversationAndTimeFormat),duration / 60, duration % 60];
    } else if (protocolType == TUICallProtocolTypeTimeout) {
        // Call timeout
        NSMutableString *mutableContent = [NSMutableString string];
        if (isGroup) {
            for (NSString *invitee in self.signalingInfo.inviteeList) {
                [mutableContent appendString:@"\"{"];
                [mutableContent appendString:invitee];
                [mutableContent appendString:@"}\"、"];
            }
            if (mutableContent.length > 0) {
                [mutableContent replaceCharactersInRange:NSMakeRange(mutableContent.length - 1, 1) withString:@" "];
            }
        }
        [mutableContent appendString:TDeskIMCommonLocalizableString(TUIKitSignalingNoResponse)];
        display = [NSString stringWithString:mutableContent];
    } else if (protocolType == TUICallProtocolTypeLineBusy) {
        // Hang up with line busy
        display = isGroup ? [NSString stringWithFormat:TDeskIMCommonLocalizableString(TUIKitSignalingBusyFormat), showName]
                          : TDeskIMCommonLocalizableString(TUIKitSignalingCallBusy);
    } else if (protocolType == TUICallProtocolTypeSwitchToAudio) {
        // Change video-call to voice-call
        display = TDeskIMCommonLocalizableString(TUIKitSignalingSwitchToAudio);
    } else if (protocolType == TUICallProtocolTypeSwitchToAudioConfirm) {
        // Confirm the change of video-voice-call
        display = TDeskIMCommonLocalizableString(TUIKitSignalingComfirmSwitchToAudio);
    }

    return rtlString(display);
}

- (TUICallMessageDirection)directionForDetailsAppearance {
    if (self.innerMessage.isSelf) {
        return TUICallMessageDirectionOutgoing;
    } else {
        return TUICallMessageDirectionIncoming;
    }
}

- (BOOL)isUseReceiverAvatarForDetailsAppearance {
    return NO;
}

#pragma mark - Simplify style
- (NSString *)contentForSimplifyAppearance {
    if (self.excludeFromHistory) {
        return nil;
    }

    TUICallParticipantType participantType = self.participantType;
    TUICallProtocolType protocolType = self.protocolType;
    BOOL isCaller = (self.participantRole == TUICallParticipantRoleCaller);

    NSString *display = nil;
    NSString *showName = [TDeskMessageBaseDataProvider getShowName:self.innerMessage];

    if (participantType == TUICallParticipantTypeC2C) {
        // C2C shown: reject、cancel、hangup、timeout、line_busy
        if (protocolType == TUICallProtocolTypeReject) {
            display = isCaller ? TDeskChatLocalizableString(TUIChatCallRejectInCaller) : TDeskChatLocalizableString(TUIChatCallRejectInCallee);
        } else if (protocolType == TUICallProtocolTypeCancel) {
            display = isCaller ? TDeskChatLocalizableString(TUIChatCallCancelInCaller) : TDeskChatLocalizableString(TUIChatCallCancelInCallee);
        } else if (protocolType == TUICallProtocolTypeHangup) {
            NSInteger duration = [[self.jsonData objectForKey:@"call_end"] integerValue];
            display = [NSString stringWithFormat:@"%@:%.2d:%.2d",TDeskChatLocalizableString(TUIChatCallDurationFormat),duration / 60, duration % 60];
        } else if (protocolType == TUICallProtocolTypeTimeout) {
            display = isCaller ? TDeskChatLocalizableString(TUIChatCallTimeoutInCaller) : TDeskChatLocalizableString(TUIChatCallTimeoutInCallee);
        } else if (protocolType == TUICallProtocolTypeLineBusy) {
            display = isCaller ? TDeskChatLocalizableString(TUIChatCallLinebusyInCaller) : TDeskChatLocalizableString(TUIChatCallLinebusyInCallee);
        }
        // C2C compatiable
        else if (protocolType == TUICallProtocolTypeSend) {
            display = TDeskChatLocalizableString(TUIChatCallSend);
        } else if (protocolType == TUICallProtocolTypeAccept) {
            display = TDeskChatLocalizableString(TUIChatCallAccept);
        } else if (protocolType == TUICallProtocolTypeSwitchToAudio) {
            display = TDeskChatLocalizableString(TUIChatCallSwitchToAudio);
        } else if (protocolType == TUICallProtocolTypeSwitchToAudioConfirm) {
            display = TDeskChatLocalizableString(TUIChatCallConfirmSwitchToAudio);
        } else {
            display = TDeskChatLocalizableString(TUIChatCallUnrecognized);
        }
    } else if (participantType == TUICallParticipantTypeGroup) {
        // Group shown: invite、cancel、hangup、timeout、line_busy
        if (protocolType == TUICallProtocolTypeSend) {
            display = [NSString stringWithFormat:TDeskChatLocalizableString(TUIChatGroupCallSendFormat), showName];
        } else if (protocolType == TUICallProtocolTypeCancel) {
            display = TDeskChatLocalizableString(TUIChatGroupCallEnd);
        } else if (protocolType == TUICallProtocolTypeHangup) {
            display = TDeskChatLocalizableString(TUIChatGroupCallEnd);
        } else if (protocolType == TUICallProtocolTypeTimeout || protocolType == TUICallProtocolTypeLineBusy) {
            NSMutableString *mutableContent = [NSMutableString string];
            if (participantType == TUICallParticipantTypeGroup) {
                for (NSString *invitee in self.signalingInfo.inviteeList) {
                    [mutableContent appendString:@"\"{"];
                    [mutableContent appendString:invitee];
                    [mutableContent appendString:@"}\"、"];
                }
                [mutableContent replaceCharactersInRange:NSMakeRange(mutableContent.length - 1, 1) withString:@" "];
            }
            [mutableContent appendString:TDeskChatLocalizableString(TUIChatGroupCallNoAnswer)];
            display = [NSString stringWithString:mutableContent];
        }
        // Group compatiable
        else if (protocolType == TUICallProtocolTypeReject) {
            display = [NSString stringWithFormat:TDeskChatLocalizableString(TUIChatGroupCallRejectFormat), showName];
        } else if (protocolType == TUICallProtocolTypeAccept) {
            display = [NSString stringWithFormat:TDeskChatLocalizableString(TUIChatGroupCallAcceptFormat), showName];
        } else if (protocolType == TUICallProtocolTypeSwitchToAudio) {
            display = [NSString stringWithFormat:TDeskChatLocalizableString(TUIChatGroupCallSwitchToAudioFormat), showName];
        } else if (protocolType == TUICallProtocolTypeSwitchToAudioConfirm) {
            display = [NSString stringWithFormat:TDeskChatLocalizableString(TUIChatGroupCallConfirmSwitchToAudioFormat), showName];
        } else {
            display = TDeskChatLocalizableString(TUIChatCallUnrecognized);
        }
    } else {
        display = TDeskChatLocalizableString(TUIChatCallUnrecognized);
    }
    return rtlString(display);
}

- (TUICallMessageDirection)directionForSimplifyAppearance {
    if (self.participantRole == TUICallParticipantRoleCaller) {
        return TUICallMessageDirectionOutgoing;
    } else {
        return TUICallMessageDirectionIncoming;
    }
}

- (BOOL)isUseReceiverAvatarForSimplifyAppearance {
    if (self.direction == TUICallMessageDirectionOutgoing) {
        return !self.innerMessage.isSelf;
    } else {
        return self.innerMessage.isSelf;
    }
}

#pragma mark - Utils
- (NSString *)convertProtocolTypeToString:(TUICallProtocolType)type {
    static NSDictionary *dict = nil;
    if (dict == nil) {
        dict = @{
            @(TUICallProtocolTypeSend) : @"TUICallProtocolTypeSend",
            @(TUICallProtocolTypeAccept) : @"TUICallProtocolTypeAccept",
            @(TUICallProtocolTypeReject) : @"TUICallProtocolTypeReject",
            @(TUICallProtocolTypeCancel) : @"TUICallProtocolTypeCancel",
            @(TUICallProtocolTypeHangup) : @"TUICallProtocolTypeHangup",
            @(TUICallProtocolTypeTimeout) : @"TUICallProtocolTypeTimeout",
            @(TUICallProtocolTypeLineBusy) : @"TUICallProtocolTypeLineBusy",
            @(TUICallProtocolTypeSwitchToAudio) : @"TUICallProtocolTypeSwitchToAudio",
            @(TUICallProtocolTypeSwitchToAudioConfirm) : @"TUICallProtocolTypeSwitchToAudioConfirm",
        };
    }
    return [dict objectForKey:@(type)] ?: @"unknown";
}

@end

// ********************************************************************

// ********************************************************************
//                       TDeskChatCallingDataProvider
// ********************************************************************
@interface TDeskChatCallingDataProvider ()

@property(nonatomic, assign) TDeskChatCallingMessageAppearance style;
@property(nonatomic, strong) NSCache<TDeskChatMessageID, TDeskChatCallingInfo *> *callingCache;

@end

@implementation TDeskChatCallingDataProvider

- (instancetype)init {
    if (self = [super init]) {
        self.style = TDeskChatCallingMessageAppearanceSimplify;
    }
    return self;
}

- (void)setCallingMessageStyle:(TDeskChatCallingMessageAppearance)style {
    self.style = style;
}

- (void)redialFromMessage:(V2TIMMessage *)innerMessage {
    NSDictionary *param = nil;
    id<TDeskChatCallingInfoProtocol> callingInfo = nil;
    if ([self isCallingMessage:innerMessage callingInfo:&callingInfo]) {
        if (callingInfo.streamMediaType == TUICallStreamMediaTypeVoice) {
            param = @{
                TDeskCore_TUICallingService_ShowCallingViewMethod_UserIDsKey : @[ innerMessage.userID ],
                TDeskCore_TUICallingService_ShowCallingViewMethod_CallTypeKey : @"0"
            };
        } else if (callingInfo.streamMediaType == TUICallStreamMediaTypeVideo) {
            param = @{
                TDeskCore_TUICallingService_ShowCallingViewMethod_UserIDsKey : @[ innerMessage.userID ],
                TDeskCore_TUICallingService_ShowCallingViewMethod_CallTypeKey : @"1"
            };
        }
        if (param) {
            [TDeskCore callService:TDeskCore_TUICallingService method:TDeskCore_TUICallingService_ShowCallingViewMethod param:param];
        }
    }
}

- (BOOL)isCallingMessage:(V2TIMMessage *)innerMessage callingInfo:(id<TDeskChatCallingInfoProtocol> __nullable *__nullable)callingInfo {
    TDeskChatCallingInfo *item = [self callingInfoForMesssage:innerMessage];
    if (item == nil) {
        if (callingInfo) {
            *callingInfo = nil;
        }
        return NO;

    } else {
        if (callingInfo) {
            *callingInfo = item;
        }
        return YES;
    }
}

- (TDeskChatCallingInfo *__nullable)callingInfoForMesssage:(V2TIMMessage *)innerMessage {
    // 1. Fetch from cache
    TDeskChatMessageID msgID = innerMessage.msgID ?: @"";
    TDeskChatCallingInfo *item = [self.callingCache objectForKey:msgID];
    if (item) {
        item.innerMessage = innerMessage;
        return item;
    }

    // 2. Parse
    V2TIMSignalingInfo *info = [V2TIMManager.sharedInstance getSignallingInfo:innerMessage];
    if (info == nil || info.data.length == 0) {
        return nil;
    }
    NSData *data = [info.data dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        return nil;
    }

    NSError *err = nil;
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (param == nil || ![param isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    NSString *businessID = [param objectForKey:@"businessID"];
    if (businessID == nil || ![businessID isKindOfClass:NSString.class]) {
        return nil;
    }
    if (![businessID isEqualToString:@"av_call"]) {
        return nil;
    }

    // 3 Cached and return
    item = [[TDeskChatCallingInfo alloc] init];
    item.style = self.style;
    item.signalingInfo = info;
    item.jsonData = param;
    item.innerMessage = innerMessage;
    [self.callingCache setObject:item forKey:msgID];
    return item;
}

#pragma mark - Lazy

- (NSCache<TDeskChatMessageID, TDeskChatCallingInfo *> *)callingCache {
    if (_callingCache == nil) {
        _callingCache = [[NSCache alloc] init];
    }
    return _callingCache;
}

@end

// ********************************************************************
