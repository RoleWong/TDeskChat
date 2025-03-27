
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TDesk_TUIChatService.h"
#import <TDeskCore/TDesk_NSDictionary+TUISafe.h>
#import <TDeskCore/TDesk_TUILogin.h>
#import <TDeskCore/TDesk_TUIThemeManager.h>
#import "TDesk_TUIChatConfig.h"
#import "TDesk_TUIChatDefine.h"
#import "TDesk_TUIMessageCellConfig.h"
#import "TDesk_TUIBaseMessageController.h"

@interface TDeskChatService () <TDeskNotificationProtocol, TDeskExtensionProtocol>

@end

@implementation TDeskChatService

+ (void)load {
    [TDeskCore registerService:TDeskCore_TUIChatService object:[TDeskChatService shareInstance]];
    TDeskRegisterThemeResourcePath(TUDeskChatThemePath, TUIThemeModuleChat);
}

+ (TDeskChatService *)shareInstance {
    static dispatch_once_t onceToken;
    static TDeskChatService *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      g_sharedInstance = [[TDeskChatService alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNotification) name:TUILoginSuccessNotification object:nil];
    }
    return self;
}

- (void)loginSuccessNotification {
    [TDeskCore callService:TDeskCore_TUICallingService
                  method:TDeskCore_TUICallingService_EnableFloatWindowMethod
                   param:@{TDeskCore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow : @(TDeskChatConfig.defaultConfig.enableFloatWindowForCall)}];
    [TDeskCore
        callService:TDeskCore_TUICallingService
             method:TDeskCore_TUICallingService_EnableMultiDeviceAbilityMethod
              param:@{
                  TDeskCore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility : @(TDeskChatConfig.defaultConfig.enableMultiDeviceForCall)
              }];
}

- (NSString *)getDisplayString:(V2TIMMessage *)message {
    return [TDeskBaseMessageController getDisplayString:message];
}

- (void)asyncGetDisplayString:(NSArray<V2TIMMessage *> *)messageList callback:(TDeskCallServiceResultCallback)resultCallback {
  if (resultCallback == nil) {
    return;
  }

  [TDeskBaseMessageController asyncGetDisplayString:messageList callback:^(NSDictionary<NSString *,NSString *> * result) {
    resultCallback(0, @"", result);
  }];
}

#pragma mark - TDeskServiceProtocol
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TDeskCore_TUIChatService_GetDisplayStringMethod]) {
        return [self getDisplayString:param[TDeskCore_TUIChatService_GetDisplayStringMethod_MsgKey]];
    } else if ([method isEqualToString:TDeskCore_TUIChatService_SendMessageMethod]) {
        V2TIMMessage *message = [param tdesk_objectForKey:TDeskCore_TUIChatService_SendMessageMethod_MsgKey asClass:V2TIMMessage.class];
        if (message == nil) {
            return nil;
        }
        NSDictionary *userInfo = @{TDeskCore_TUIChatService_SendMessageMethod_MsgKey : message};
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIChatSendMessageNotification object:nil userInfo:userInfo];
    } else if ([method isEqualToString:TDeskCore_TUIChatService_SendMessageMethodWithoutUpdateUI]) {
        V2TIMMessage *message = [param tdesk_objectForKey:TDeskCore_TUIChatService_SendMessageMethodWithoutUpdateUI_MsgKey asClass:V2TIMMessage.class];
        if (message == nil) {
            return nil;
        }
        NSDictionary *userInfo = @{TDeskCore_TUIChatService_SendMessageMethodWithoutUpdateUI_MsgKey : message};
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIChatSendMessageWithoutUpdateUINotification object:nil userInfo:userInfo];
    } else if ([method isEqualToString:TDeskCore_TUIChatService_SetChatExtensionMethod]) {
        [param enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *_Nonnull stop) {
          if (![key isKindOfClass:NSString.class] || ![obj isKindOfClass:NSNumber.class]) {
              return;
          }
        }];
    } else if ([method isEqualToString:TDeskCore_TUIChatService_AppendCustomMessageMethod]) {
        if ([param isKindOfClass:NSDictionary.class]) {
            NSString *businessID = param[BussinessID];
            NSString *cellName = param[TMessageCell_Name];
            NSString *cellDataName = param[TMessageCell_Data_Name];
            [TDeskMessageCellConfig registerCustomMessageCell:cellName messageCellData:cellDataName forBusinessID:businessID isPlugin:YES];
        }
    }
    else if ([method isEqualToString:TDeskCore_TUIChatService_SetMaxTextSize]) {
        if ([param isKindOfClass:NSDictionary.class]) {
            CGSize sizeVa = [param[@"maxsize"] CGSizeValue];
            [TDeskMessageCellConfig setMaxTextSize:sizeVa];
        }
    }

    return nil;
}

- (id)onCall:(NSString *)method param:(NSDictionary *)param resultCallback:(TDeskCallServiceResultCallback)resultCallback {
  if ([method isEqualToString:TDeskCore_TUIChatService_AsyncGetDisplayStringMethod]) {
    NSArray *messageList = param[TDeskCore_TUIChatService_AsyncGetDisplayStringMethod_MsgListKey];
    [self asyncGetDisplayString:messageList callback:resultCallback];
    return nil;
  }
  return nil;
}

@end
