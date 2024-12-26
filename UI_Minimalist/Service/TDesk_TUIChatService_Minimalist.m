
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TDesk_TUIChatService_Minimalist.h"
#import <TDeskCore/TDesk_NSDictionary+TUISafe.h>
#import <TDeskCore/TDesk_TUILogin.h>
#import <TDeskCore/TDesk_TUIThemeManager.h>
#import "TDesk_TUIChatConfig.h"
#import "TDesk_TUIMessageCellConfig_Minimalist.h"
#import "TDesk_TUIBaseMessageController_Minimalist.h"

@interface TUIChatService_Minimalist () <TUINotificationProtocol, TUIExtensionProtocol>

@end

@implementation TUIChatService_Minimalist

+ (void)load {
    [TDeskCore registerService:TUICore_TUIChatService_Minimalist object:[TUIChatService_Minimalist shareInstance]];
    TDeskRegisterThemeResourcePath(TUIBundlePath(@"TUIChatTheme_Minimalist", TUIChatBundle_Key_Class), TUIThemeModuleChat_Minimalist);
}

+ (TUIChatService_Minimalist *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIChatService_Minimalist *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      g_sharedInstance = [[TUIChatService_Minimalist alloc] init];
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
    [TDeskCore callService:TUICore_TUICallingService
                  method:TUICore_TUICallingService_EnableFloatWindowMethod
                   param:@{TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow : @(TDeskChatConfig.defaultConfig.enableFloatWindowForCall)}];
    [TDeskCore
        callService:TUICore_TUICallingService
             method:TUICore_TUICallingService_EnableMultiDeviceAbilityMethod
              param:@{
                  TUICore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility : @(TDeskChatConfig.defaultConfig.enableMultiDeviceForCall)
              }];
}

- (NSString *)getDisplayString:(V2TIMMessage *)message {
    return [TUIBaseMessageController_Minimalist getDisplayString:message];
}

- (void)asyncGetDisplayString:(NSArray<V2TIMMessage *> *)messageList callback:(TUICallServiceResultCallback)resultCallback {
  if (resultCallback == nil) {
    return;
  }

  [TUIBaseMessageController_Minimalist asyncGetDisplayString:messageList callback:^(NSDictionary<NSString *,NSString *> * result) {
    resultCallback(0, @"", result);
  }];
}

#pragma mark - TDeskServiceProtocol
- (id)onCall:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIChatService_GetDisplayStringMethod]) {
        return [self getDisplayString:param[TUICore_TUIChatService_GetDisplayStringMethod_MsgKey]];
    } else if ([method isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod]) {
        [param enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *_Nonnull stop) {
          if (![key isKindOfClass:NSString.class] || ![obj isKindOfClass:NSNumber.class]) {
              return;
          }
          if ([key isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod_EnableVideoCallKey]) {
              TDeskChatConfig.defaultConfig.enableVideoCall = obj.boolValue;
          } else if ([key isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod_EnableAudioCallKey]) {
              TDeskChatConfig.defaultConfig.enableAudioCall = obj.boolValue;
          } else if ([key isEqualToString:TUICore_TUIChatService_SetChatExtensionMethod_EnableLinkKey]) {
              TDeskChatConfig.defaultConfig.enableWelcomeCustomMessage = obj.boolValue;
          }
        }];
    } else if ([method isEqualToString:TUICore_TUIChatService_AppendCustomMessageMethod]) {
        if ([param isKindOfClass:NSDictionary.class]) {
            NSString *businessID = param[BussinessID];
            NSString *cellName = param[TMessageCell_Name];
            NSString *cellDataName = param[TMessageCell_Data_Name];
            [TUIMessageCellConfig_Minimalist registerCustomMessageCell:cellName messageCellData:cellDataName forBusinessID:businessID isPlugin:YES];
        }
    }

    return nil;
}

- (id)onCall:(NSString *)method param:(NSDictionary *)param resultCallback:(TUICallServiceResultCallback)resultCallback {
  if ([method isEqualToString:TUICore_TUIChatService_AsyncGetDisplayStringMethod]) {
    NSArray *messageList = param[TUICore_TUIChatService_AsyncGetDisplayStringMethod_MsgListKey];
    [self asyncGetDisplayString:messageList callback:resultCallback];
    return nil;
  }
  return nil;
}

@end
