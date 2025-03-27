
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TDesk_TUIMessageDataProvider.h"
#import <AVFoundation/AVFoundation.h>
#import <TDeskCommon/TDesk_TUIRelationUserModel.h>
#import <TDeskCommon/TDesk_TUISystemMessageCellData.h>
#import <TDeskCore/TDesk_TUILogin.h>
#import "TDesk_TUIChatCallingDataProvider.h"
#import "TDesk_TUICloudCustomDataTypeCenter.h"
#import "TDesk_TUIFaceMessageCellData.h"
#import "TDesk_TUIFileMessageCellData.h"
#import "TDesk_TUIImageMessageCellData.h"
#import "TDesk_TUIJoinGroupMessageCellData.h"
#import "TDesk_TUIMergeMessageCellData.h"
#import "TDesk_TUIMessageDataProvider+MessageDeal.h"
#import "TDesk_TUIMessageProgressManager.h"
#import "TDesk_TUIReplyMessageCellData.h"
#import "TDesk_TUITextMessageCellData.h"
#import "TDesk_TUIVideoMessageCellData.h"
#import "TDesk_TUIVoiceMessageCellData.h"

/**
 * The maximum editable time after the message is recalled, default is (2 * 60)
 */
#define MaxReEditMessageDelay 2 * 60

#define kIsCustomMessageFromPlugin @"kIsCustomMessageFromPlugin"

static Class<TDeskMessageDataProviderDataSource> gDataSourceClass = nil;

@implementation TDeskMessageDataProvider

#pragma mark - Life cycle

- (void)dealloc {
    gCallingDataProvider = nil;
}

+ (void)setDataSourceClass:(Class<TDeskMessageDataProviderDataSource>)dataSourceClass {
    gDataSourceClass = dataSourceClass;
}

#pragma mark - TDeskMessageCellData parser
+ (nullable TDeskMessageCellData *)getCellData:(V2TIMMessage *)message {
    // 1 Parse cell data
    TDeskMessageCellData *data = [self parseMessageCellDataFromMessageStatus:message];
    if (data == nil) {
        data = [self parseMessageCellDataFromMessageCustomData:message];
    }
    if (data == nil) {
        data = [self parseMessageCellDataFromMessageElement:message];
    }

    // 2 Fill in property if needed
    if (data) {
        [self fillPropertyToCellData:data ofMessage:message];
    } else {
        NSLog(@"current message will be ignored in chat page, msg:%@", message);
    }

    return data;
}

+ (nullable TDeskMessageCellData *)parseMessageCellDataFromMessageStatus:(V2TIMMessage *)message {
    TDeskMessageCellData *data = nil;
    if (message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        data = [TDeskMessageDataProvider getRevokeCellData:message];
    }
    return data;
}

+ (nullable TDeskMessageCellData *)parseMessageCellDataFromMessageCustomData:(V2TIMMessage *)message {
    TDeskMessageCellData *data = nil;
    if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReply]) {
        /**
         * Determine whether to include "reply-message"
         */
        data = [TDeskReplyMessageCellData getCellData:message];
    } else if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReference]) {
        /**
         * Determine whether to include "quote-message"
         */
        data = [TDeskReferenceMessageCellData getCellData:message];
    }
    return data;
}

+ (nullable TDeskMessageCellData *)parseMessageCellDataFromMessageElement:(V2TIMMessage *)message {
    TDeskMessageCellData *data = nil;
    switch (message.elemType) {
        case V2TIM_ELEM_TYPE_TEXT: {
            data = [TDeskTextMessageCellData getCellData:message];
        } break;
        case V2TIM_ELEM_TYPE_IMAGE: {
            data = [TDeskImageMessageCellData getCellData:message];
        } break;
        case V2TIM_ELEM_TYPE_SOUND: {
            data = [TDeskVoiceMessageCellData getCellData:message];
        } break;
        case V2TIM_ELEM_TYPE_VIDEO: {
            data = [TDeskVideoMessageCellData getCellData:message];
        } break;
        case V2TIM_ELEM_TYPE_FILE: {
            data = [TDeskFileMessageCellData getCellData:message];
        } break;
        case V2TIM_ELEM_TYPE_FACE: {
            data = [TDeskFaceMessageCellData getCellData:message];
        } break;
        case V2TIM_ELEM_TYPE_GROUP_TIPS: {
            data = [self getSystemCellData:message];
        } break;
        case V2TIM_ELEM_TYPE_MERGER: {
            data = [TDeskMergeMessageCellData getCellData:message];
        } break;
        case V2TIM_ELEM_TYPE_CUSTOM: {
            data = [self getCustomMessageCellData:message];
        } break;
        default:
            data = [self getUnsupportedCellData:message];
            break;
    }
    return data;
}

+ (void)fillPropertyToCellData:(TDeskMessageCellData *)data ofMessage:(V2TIMMessage *)message {
    data.innerMessage = message;
    if (message.groupID.length > 0 && !message.isSelf && ![data isKindOfClass:[TDeskSystemMessageCellData class]]) {
        data.showName = YES;
    }
    switch (message.status) {
        case V2TIM_MSG_STATUS_SEND_SUCC:
            data.status = Msg_Status_Succ;
            break;
        case V2TIM_MSG_STATUS_SEND_FAIL:
            data.status = Msg_Status_Fail;
            break;
        case V2TIM_MSG_STATUS_SENDING:
            data.status = Msg_Status_Sending_2;
            break;
        default:
            break;
    }

    /**
     * Update progress of message uploading/downloading
     */
    {
        NSInteger uploadProgress = [TDeskMessageProgressManager.shareManager uploadProgressForMessage:message.msgID];
        NSInteger downloadProgress = [TDeskMessageProgressManager.shareManager downloadProgressForMessage:message.msgID];
        if ([data conformsToProtocol:@protocol(TDeskMessageCellDataFileUploadProtocol)]) {
            ((id<TDeskMessageCellDataFileUploadProtocol>)data).uploadProgress = uploadProgress;
        }
        if ([data conformsToProtocol:@protocol(TDeskMessageCellDataFileDownloadProtocol)]) {
            ((id<TDeskMessageCellDataFileDownloadProtocol>)data).downladProgress = downloadProgress;
            ((id<TDeskMessageCellDataFileDownloadProtocol>)data).isDownloading = (downloadProgress != 0) && (downloadProgress != 100);
        }
    }

    /**
     * Determine whether to include "replies-message"
     */
    if ([message isContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReplies]) {
        [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReplies
                                                callback:^(BOOL isContains, id obj) {
                                                  if (isContains) {
                                                      if ([data isKindOfClass:TDeskSystemMessageCellData.class] ||
                                                          [data isKindOfClass:TDeskJoinGroupMessageCellData.class]) {
                                                          data.showMessageModifyReplies = NO;
                                                      } else {
                                                          data.showMessageModifyReplies = YES;
                                                      }
                                                      if (obj && [obj isKindOfClass:NSDictionary.class]) {
                                                          NSDictionary *dic = (NSDictionary *)obj;
                                                          NSString *typeStr =
                                                              [TDeskCloudCustomDataTypeCenter convertType2String:TUICloudCustomDataType_MessageReplies];
                                                          NSDictionary *messageReplies = [dic valueForKey:typeStr];
                                                          NSArray *repliesArr = [messageReplies valueForKey:@"replies"];
                                                          if ([repliesArr isKindOfClass:NSArray.class]) {
                                                              data.messageModifyReplies = repliesArr.copy;
                                                          }
                                                      }
                                                  }
                                                }];
    }
}

+ (nullable TDeskMessageCellData *)getCustomMessageCellData:(V2TIMMessage *)message {
    // ************************************************************************************
    // ************************************************************************************
    // **The compatible processing logic of TUICallKit will be removed after***************
    // **TUICallKit is connected according to the standard process. ***********************
    // ************************************************************************************
    // ************************************************************************************
    TDeskMessageCellData *data = nil;
    id<TDeskChatCallingInfoProtocol> callingInfo = nil;
    if ([self.callingDataProvider isCallingMessage:message callingInfo:&callingInfo]) {
        // Voice-video-call message
        if (callingInfo) {
            // Supported voice-video-call message
            if (callingInfo.excludeFromHistory) {
                // This message will be ignore in chat page
                data = nil;
            } else {
                data = [self getCallingCellData:callingInfo];
                if (data == nil) {
                    data = [self getUnsupportedCellData:message];
                }
            }
        } else {
            // Unsupported voice-video-call message
            data = [self getUnsupportedCellData:message];
        }

        return data;
    }
    // ************************************************************************************
    // ************************************************************************************
    // ************************************************************************************
    // ************************************************************************************

    NSString *businessID = nil;
    BOOL excludeFromHistory = NO;

    V2TIMSignalingInfo *signalingInfo = [V2TIMManager.sharedInstance getSignallingInfo:message];
    if (signalingInfo) {
        // This message is signaling message
        BOOL isOnlineOnly = NO;
        @try {
            isOnlineOnly = [[message valueForKeyPath:@"message.IsOnlineOnly"] boolValue];
        } @catch (NSException *exception) {
            isOnlineOnly = NO;
        }
        excludeFromHistory = isOnlineOnly || (message.isExcludedFromLastMessage && message.isExcludedFromUnreadCount);
        businessID = [self getSignalingBusinessID:signalingInfo];
    } else {
        // This message is normal custom message
        excludeFromHistory = NO;
        businessID = [self getCustomBusinessID:message];
    }

    if (excludeFromHistory) {
        // Return nil means not display in the chat page
        return nil;
    }

    if (businessID.length > 0) {
        Class cellDataClass = nil;
        if (gDataSourceClass && [gDataSourceClass respondsToSelector:@selector(onGetCustomMessageCellDataClass:)]) {
            cellDataClass = [gDataSourceClass onGetCustomMessageCellDataClass:businessID];
        }
        if (cellDataClass && [cellDataClass respondsToSelector:@selector(getCellData:)]) {
            TDeskMessageCellData *data = [cellDataClass getCellData:message];
            if (data.shouldHide) {
                return nil;
            } else {
                data.reuseId = businessID;
                return data;
            }
        }
        // In CustomerService scenarios, unsupported messages are not displayed directly.
        if ([businessID tdesk_containsString:BussinessID_CustomerService]) {
            return nil;
        }
        return [self getUnsupportedCellData:message];
    } else {
        return [self getUnsupportedCellData:message];
    }
}

+ (TDeskMessageCellData *)getUnsupportedCellData:(V2TIMMessage *)message {
    TDeskTextMessageCellData *cellData = [[TDeskTextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    cellData.content = TDeskIMCommonLocalizableString(TUIKitNotSupportThisMessage);
    cellData.reuseId = TTextMessageCell_ReuseId;
    return cellData;
}

+ (nullable TDeskSystemMessageCellData *)getSystemCellData:(V2TIMMessage *)message {
    V2TIMGroupTipsElem *tip = message.groupTipsElem;
    NSString *opUserName = [self getOpUserName:tip.opMember];
    NSMutableArray<NSString *> *userNameList = [self getUserNameList:tip.memberList];
    NSMutableArray<NSString *> *userIDList = [self getUserIDList:tip.memberList];
    if (tip.type == V2TIM_GROUP_TIPS_TYPE_JOIN || tip.type == V2TIM_GROUP_TIPS_TYPE_INVITE || tip.type == V2TIM_GROUP_TIPS_TYPE_KICKED ||
        tip.type == V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE || tip.type == V2TIM_GROUP_TIPS_TYPE_QUIT ||
        tip.type == V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_ADDED || tip.type == V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_DELETED) {
        TDeskJoinGroupMessageCellData *joinGroupData = [[TDeskJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [self getDisplayString:message];
        joinGroupData.opUserName = opUserName;
        joinGroupData.opUserID = tip.opMember.userID;
        joinGroupData.userNameList = userNameList;
        joinGroupData.userIDList = userIDList;
        joinGroupData.reuseId = TJoinGroupMessageCell_ReuseId;
        return joinGroupData;
    } else {
        TDeskSystemMessageCellData *sysdata = [[TDeskSystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        sysdata.content = [self getDisplayString:message];
        sysdata.reuseId = TSystemMessageCell_ReuseId;
        if (sysdata.content.length) {
            return sysdata;
        }
    }
    return nil;
}

+ (nullable TDeskSystemMessageCellData *)getRevokeCellData:(V2TIMMessage *)message {
    TDeskSystemMessageCellData *revoke = [[TDeskSystemMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    revoke.reuseId = TSystemMessageCell_ReuseId;
    revoke.content = [self getRevokeDispayString:message];
    revoke.innerMessage = message;
    V2TIMUserFullInfo *revokerInfo = message.revokerInfo;
    if (message.isSelf) {
        if (message.elemType == V2TIM_ELEM_TYPE_TEXT && fabs([[NSDate date] timeIntervalSinceDate:message.timestamp]) < MaxReEditMessageDelay) {
            if (revokerInfo && ![revokerInfo.userID isEqualToString:message.sender]) {
                // Super User revoke
                revoke.supportReEdit = NO;
            } else {
                revoke.supportReEdit = YES;
            }
        }
    } else if (message.groupID.length > 0) {
        /**
         * For the name display of group messages, the group business card is displayed first, the nickname has the second priority, and the user ID has the
         * lowest priority.
         */
        NSString *userName = [TDeskMessageDataProvider getShowName:message];
        TDeskJoinGroupMessageCellData *joinGroupData = [[TDeskJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [self getRevokeDispayString:message];
        joinGroupData.opUserID = message.sender;
        joinGroupData.opUserName = userName;
        joinGroupData.reuseId = TJoinGroupMessageCell_ReuseId;
        return joinGroupData;
    }
    return revoke;
}

+ (nullable TDeskSystemMessageCellData *)getSystemMsgFromDate:(NSDate *)date {
    TDeskSystemMessageCellData *system = [[TDeskSystemMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    system.content = [TDeskTool convertDateToStr:date];
    system.reuseId = TSystemMessageCell_ReuseId;
    system.type = TUISystemMessageTypeDate;
    return system;
}

#pragma mark - Last message parser
+ (void)asyncGetDisplayString:(NSArray<V2TIMMessage *> *)messageList callback:(void (^)(NSDictionary<NSString *, NSString *> *))callback {
    if (!callback) {
        return;
    }

    NSMutableDictionary *originDisplayMap = [NSMutableDictionary dictionary];
    NSMutableArray *cellDataList = [NSMutableArray array];
    for (V2TIMMessage *message in messageList) {
        TDeskMessageCellData *cellData = [self getCellData:message];
        if (cellData) {
            [cellDataList addObject:cellData];
        }

        NSString *displayString = [self getDisplayString:message];
        if (displayString && message.msgID) {
            originDisplayMap[message.msgID] = displayString;
        }
    }

    if (cellDataList.count == 0) {
        callback(@{});
        return;
    }

    TDeskMessageDataProvider *provider = [[TDeskMessageDataProvider alloc] init];
    NSArray *additionUserIDList = [provider getUserIDListForAdditionalUserInfo:cellDataList];
    if (additionUserIDList.count == 0) {
        callback(@{});
        return;
    }

    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [provider
        requestForAdditionalUserInfo:cellDataList
                            callback:^{
                              for (TDeskMessageCellData *cellData in cellDataList) {
                                  [cellData.additionalUserInfoResult
                                      enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, TDeskRelationUserModel *_Nonnull obj, BOOL *_Nonnull stop) {
                                        NSString *str = [NSString stringWithFormat:@"{%@}", key];
                                        NSString *showName = obj.userID;
                                        if (obj.nameCard.length > 0) {
                                            showName = obj.nameCard;
                                        } else if (obj.friendRemark.length > 0) {
                                            showName = obj.friendRemark;
                                        } else if (obj.nickName.length > 0) {
                                            showName = obj.nickName;
                                        }

                                        NSString *displayString = [originDisplayMap objectForKey:cellData.msgID];
                                        if (displayString && [displayString containsString:str]) {
                                            displayString = [displayString stringByReplacingOccurrencesOfString:str withString:showName];
                                            result[cellData.msgID] = displayString;
                                        }

                                        callback(result);
                                      }];
                              }
                            }];
}

+ (nullable NSString *)getDisplayString:(V2TIMMessage *)message {
    BOOL hasRiskContent = message.hasRiskContent;
    BOOL isRevoked = (message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED);
    if (hasRiskContent && !isRevoked) {
        return TDeskIMCommonLocalizableString(TUIKitMessageDisplayRiskContent);
    }
    NSString *str = [self parseDisplayStringFromMessageStatus:message];
    if (str == nil) {
        str = [self parseDisplayStringFromMessageElement:message];
    }

    if (str == nil) {
        NSLog(@"current message will be ignored in chat page or conversation list page, msg:%@", message);
    }
    return str;
}

+ (nullable NSString *)parseDisplayStringFromMessageStatus:(V2TIMMessage *)message {
    NSString *str = nil;
    if (message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        str = [self getRevokeDispayString:message];
    }
    return str;
}

+ (nullable NSString *)parseDisplayStringFromMessageElement:(V2TIMMessage *)message {
    NSString *str = nil;
    switch (message.elemType) {
        case V2TIM_ELEM_TYPE_TEXT: {
            str = [TDeskTextMessageCellData getDisplayString:message];
        } break;
        case V2TIM_ELEM_TYPE_IMAGE: {
            str = [TDeskImageMessageCellData getDisplayString:message];
        } break;
        case V2TIM_ELEM_TYPE_SOUND: {
            str = [TDeskVoiceMessageCellData getDisplayString:message];
        } break;
        case V2TIM_ELEM_TYPE_VIDEO: {
            str = [TDeskVideoMessageCellData getDisplayString:message];
        } break;
        case V2TIM_ELEM_TYPE_FILE: {
            str = [TDeskFileMessageCellData getDisplayString:message];
        } break;
        case V2TIM_ELEM_TYPE_FACE: {
            str = [TDeskFaceMessageCellData getDisplayString:message];
        } break;
        case V2TIM_ELEM_TYPE_MERGER: {
            str = [TDeskMergeMessageCellData getDisplayString:message];
        } break;
        case V2TIM_ELEM_TYPE_GROUP_TIPS: {
            str = [self getGroupTipsDisplayString:message];
        } break;
        case V2TIM_ELEM_TYPE_CUSTOM: {
            str = [self getCustomDisplayString:message];
        } break;
        default:
            str = TDeskIMCommonLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
            break;
    }
    return str;
}

+ (nullable NSString *)getCustomDisplayString:(V2TIMMessage *)message {
    // ************************************************************************************
    // ************************************************************************************
    // ************** TUICallKit ， TUICallKit  *************
    // ************************************************************************************
    // ************************************************************************************
    NSString *str = nil;
    id<TDeskChatCallingInfoProtocol> callingInfo = nil;
    if ([self.callingDataProvider isCallingMessage:message callingInfo:&callingInfo]) {
        // Voice-video-call message
        if (callingInfo) {
            // Supported voice-video-call message
            if (callingInfo.excludeFromHistory) {
                // This message will be ignore in chat page
                str = nil;
            } else {
                // Get display text
                str = callingInfo.content ?: TDeskIMCommonLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
            }
        } else {
            // Unsupported voice-video-call message
            str = TDeskIMCommonLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
        }
        return str;
    }
    // ************************************************************************************
    // ************************************************************************************
    // ************************************************************************************
    // ************************************************************************************

    NSString *businessID = nil;
    BOOL excludeFromHistory = NO;

    V2TIMSignalingInfo *signalingInfo = [V2TIMManager.sharedInstance getSignallingInfo:message];
    if (signalingInfo) {
        // This message is signaling message
        excludeFromHistory = message.isExcludedFromLastMessage && message.isExcludedFromUnreadCount;
        businessID = [self getSignalingBusinessID:signalingInfo];
    } else {
        // This message is normal custom message
        excludeFromHistory = NO;
        businessID = [self getCustomBusinessID:message];
    }

    if (excludeFromHistory) {
        // Return nil means not display int the chat page
        return nil;
    }

    if (businessID.length > 0) {
        Class cellDataClass = nil;
        if (gDataSourceClass && [gDataSourceClass respondsToSelector:@selector(onGetCustomMessageCellDataClass:)]) {
            cellDataClass = [gDataSourceClass onGetCustomMessageCellDataClass:businessID];
        }
        if (cellDataClass && [cellDataClass respondsToSelector:@selector(getDisplayString:)]) {
            return [cellDataClass getDisplayString:message];
        }
        // In CustomerService scenarios, unsupported messages are not displayed directly.
        if ([businessID tdesk_containsString:BussinessID_CustomerService]) {
            return nil;
        }
        return TDeskIMCommonLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
    } else {
        return TDeskIMCommonLocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
    }
}

#pragma mark - Data source operate
- (void)processQuoteMessage:(NSArray<TDeskMessageCellData *> *)uiMsgs {
    if (uiMsgs.count == 0) {
        return;
    }

    @weakify(self);
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, concurrentQueue, ^{
      for (TDeskMessageCellData *cellData in uiMsgs) {
          if (![cellData isKindOfClass:TDeskReplyMessageCellData.class]) {
              continue;
          }

          TDeskReplyMessageCellData *myData = (TDeskReplyMessageCellData *)cellData;
          __weak typeof(myData) weakMyData = myData;
          myData.onFinish = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
              NSUInteger index = [self.uiMsgs indexOfObject:weakMyData];
              if (index != NSNotFound) {
                  // if messageData exist In datasource, reload this data.
                  [UIView performWithoutAnimation:^{
                    @strongify(self);
                    [self.dataSource dataProviderDataSourceWillChange:self];
                    [self.dataSource dataProviderDataSourceChange:self
                                                         withType:TDeskMessageBaseDataProviderDataSourceChangeTypeReload
                                                          atIndex:index
                                                        animation:NO];
                    [self.dataSource dataProviderDataSourceDidChange:self];
                  }];
              }
            });
          };
          dispatch_group_enter(group);
          [self loadOriginMessageFromReplyData:myData
                                  dealCallback:^{
                                    dispatch_group_leave(group);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                      NSUInteger index = [self.uiMsgs indexOfObject:weakMyData];
                                      if (index != NSNotFound) {
                                          // if messageData exist In datasource, reload this data.
                                          [UIView performWithoutAnimation:^{
                                            @strongify(self);
                                            [self.dataSource dataProviderDataSourceWillChange:self];
                                            [self.dataSource dataProvider:self onRemoveHeightCache:weakMyData];
                                            [self.dataSource dataProviderDataSourceChange:self
                                                                                 withType:TDeskMessageBaseDataProviderDataSourceChangeTypeReload
                                                                                  atIndex:index
                                                                                animation:NO];
                                            [self.dataSource dataProviderDataSourceDidChange:self];
                                          }];
                                      }
                                    });
                                  }];
      }
    });

    dispatch_group_notify(group, dispatch_get_main_queue(),
                          ^{
                              // complete
                          });
}

- (void)deleteUIMsgs:(NSArray<TDeskMessageCellData *> *)uiMsgs SuccBlock:(nullable V2TIMSucc)succ FailBlock:(nullable V2TIMFail)fail {
    NSMutableArray *uiMsgList = [NSMutableArray array];
    NSMutableArray *imMsgList = [NSMutableArray array];
    for (TDeskMessageCellData *uiMsg in uiMsgs) {
        if ([self.uiMsgs containsObject:uiMsg]) {
            // Check content cell
            [uiMsgList addObject:uiMsg];
            [imMsgList addObject:uiMsg.innerMessage];

            // Check time cell which also need to be deleted
            NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
            index--;
            if (index >= 0 && index < self.uiMsgs.count && [[self.uiMsgs objectAtIndex:index] isKindOfClass:TDeskSystemMessageCellData.class]) {
                TDeskSystemMessageCellData *systemCellData = (TDeskSystemMessageCellData *)[self.uiMsgs objectAtIndex:index];
                if (systemCellData.type == TUISystemMessageTypeDate) {
                    [uiMsgList addObject:systemCellData];
                }
            }
        }
    }

    if (imMsgList.count == 0) {
        if (fail) {
            fail(ERR_INVALID_PARAMETERS, @"not found uiMsgs");
        }
        return;
    }

    @weakify(self);
    [self.class deleteMessages:imMsgList
                          succ:^{
                            @strongify(self);
                            [self.dataSource dataProviderDataSourceWillChange:self];
                            for (TDeskMessageCellData *uiMsg in uiMsgList) {
                                NSInteger index = [self.uiMsgs indexOfObject:uiMsg];
                                [self.dataSource dataProviderDataSourceChange:self
                                                                     withType:TDeskMessageBaseDataProviderDataSourceChangeTypeDelete
                                                                      atIndex:index
                                                                    animation:YES];
                            }
                            [self removeUIMsgList:uiMsgList];

                            [self.dataSource dataProviderDataSourceDidChange:self];
                            if (succ) {
                                succ();
                            }
                          }
                          fail:fail];
}

- (void)removeUIMsgList:(NSArray<TDeskMessageCellData *> *)cellDatas {
    for (TDeskMessageCellData *uiMsg in cellDatas) {
        [self removeUIMsg:uiMsg];
    }
}

#pragma mark - Utils
+ (nullable NSString *)getCustomBusinessID:(V2TIMMessage *)message {
    if (message == nil || message.customElem.data == nil) {
        return nil;
    }
    NSError *error = nil;
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"parse customElem data error: %@", error);
        return nil;
    }
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSString *businessID = param[BussinessID];
    if (businessID.length > 0 && [businessID isKindOfClass:[NSString class]]) {
        return businessID;
    } else {
        if ([param.allKeys containsObject:BussinessID_CustomerService]) {
            NSString *src = param[BussinessID_Src_CustomerService];
            if (src.length > 0 && [src isKindOfClass:[NSString class]]) {
                return [NSString stringWithFormat:@"%@%@", BussinessID_CustomerService, src];
            }
        }
        return nil;
    }
}

+ (nullable NSString *)getSignalingBusinessID:(V2TIMSignalingInfo *)signalInfo {
    if (signalInfo.data == nil) {
        return nil;
    }

    NSError *error = nil;
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:[signalInfo.data dataUsingEncoding:NSUTF8StringEncoding]
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
    if (error) {
        NSLog(@"parse customElem data error: %@", error);
        return nil;
    }
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *businessID = param[BussinessID];
    if (!businessID || ![businessID isKindOfClass:[NSString class]]) {
        return nil;
    }

    return businessID;
}

#pragma mark - TUICallKit

static TDeskChatCallingDataProvider *gCallingDataProvider;
+ (TDeskChatCallingDataProvider *)callingDataProvider {
    if (gCallingDataProvider == nil) {
        gCallingDataProvider = [[TDeskChatCallingDataProvider alloc] init];
    }
    return gCallingDataProvider;
}

+ (TDeskMessageCellData *)getCallingCellData:(id<TDeskChatCallingInfoProtocol>)callingInfo {
    TDeskMsgDirection direction = MsgDirectionIncoming;
    if (callingInfo.direction == TUICallMessageDirectionIncoming) {
        direction = MsgDirectionIncoming;
    } else if (callingInfo.direction == TUICallMessageDirectionOutgoing) {
        direction = MsgDirectionOutgoing;
    }

    if (callingInfo.participantType == TUICallParticipantTypeC2C) {
        TDeskTextMessageCellData *cellData = [[TDeskTextMessageCellData alloc] initWithDirection:direction];
        if (callingInfo.streamMediaType == TUICallStreamMediaTypeVoice) {
            cellData.isAudioCall = YES;
        } else if (callingInfo.streamMediaType == TUICallStreamMediaTypeVideo) {
            cellData.isVideoCall = YES;
        } else {
            cellData.isAudioCall = NO;
            cellData.isVideoCall = NO;
        }
        cellData.content = callingInfo.content;
        cellData.isCaller = (callingInfo.participantRole == TUICallParticipantRoleCaller);
        cellData.showUnreadPoint = callingInfo.showUnreadPoint;
        cellData.isUseMsgReceiverAvatar = callingInfo.isUseReceiverAvatar;
        cellData.reuseId = TTextMessageCell_ReuseId;
        return cellData;
    } else if (callingInfo.participantType == TUICallParticipantTypeGroup) {
        TDeskSystemMessageCellData *cellData = [[TDeskSystemMessageCellData alloc] initWithDirection:direction];
        cellData.content = callingInfo.content;
        cellData.replacedUserIDList = callingInfo.participantIDList;
        cellData.reuseId = TSystemMessageCell_ReuseId;
        return cellData;
    } else {
        return nil;
    }
}

@end
