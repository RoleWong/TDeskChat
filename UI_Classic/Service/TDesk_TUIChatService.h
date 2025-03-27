//
//  TUIChatManager.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/12.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCore/TDesk_TUICore.h>

@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN
/**
 * TDeskChatService currently provides two services:
 * 1. Creating chat class
 * 2. Getting display text information through V2TIMMessage object
 *
 * You can call the service through the [TDeskCore callService:..] method. The different service parameters are as follows:
 *
 *  > Getting display text information through V2TIMMessage object
 *    serviceName: TDeskCore_TUIChatService
 *    method ：TDeskCore_TUIChatService_GetDisplayStringMethod
 *    param: @{TDeskCore_TUIChatService_GetDisplayStringMethod_MsgKey:V2TIMMessage};
 *
 *  > Send Message
 *  serviceName: TDeskCore_TUIChatService
 *  method: TDeskCore_TUIChatService_SendMessageMethod
 *  param: @{TDeskCore_TUIChatService_SendMessageMethod_MsgKey:V2TIMMessage};
 */

@interface TDeskChatService : NSObject <TDeskServiceProtocol>

+ (TDeskChatService *)shareInstance;

@end
NS_ASSUME_NONNULL_END
