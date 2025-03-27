//
//  TDeskChatConfig.m
//  TUIChat
//
//  Created by wyl on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIChatConfig.h"
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCommon/TDesk_TIMCommonMediator.h>
#import <TDeskCommon/TDesk_TUIEmojiMeditorProtocol.h>
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCore/TDesk_TUICore.h>
@implementation TDeskChatConfig

- (id)init {
    self = [super init];
    if (self) {
        self.msgNeedReadReceipt = NO;
        self.enableVideoCall = YES;
        self.enableAudioCall = YES;
        self.enableWelcomeCustomMessage = YES;
        self.enablePopMenuEmojiReactAction = YES;
        self.enablePopMenuReplyAction = YES;
        self.enablePopMenuReferenceAction = YES;
        self.enableMainPageInputBar = YES;
        self.enableTypingStatus = YES;
        self.enableFloatWindowForCall = YES;
        self.enableMultiDeviceForCall = NO;
        self.timeIntervalForMessageRecall = 120;
    }
    return self;
}

+ (TDeskChatConfig *)defaultConfig {
    static dispatch_once_t onceToken;
    static TDeskChatConfig *config;
    dispatch_once(&onceToken, ^{
      config = [[TDeskChatConfig alloc] init];
    });
    return config;
}

- (NSArray<TDeskFaceGroup *> *)chatContextEmojiDetailGroups {
    id<TDeskEmojiMeditorProtocol> service = [[TDeskCommonMediator share] getObject:@protocol(TDeskEmojiMeditorProtocol)];
    return [service getChatContextEmojiDetailGroups];
}

- (TDeskChatEventConfig *)eventConfig {
    if (!_eventConfig) {
        _eventConfig = [[TDeskChatEventConfig alloc] init];
    }
    return _eventConfig;
}

@end

@implementation TDeskChatEventConfig

@end


@implementation TDeskChatConfig (CustomMessageRegiser)

- (void)registerCustomMessage:(NSString *)businessID
             messageCellClassName:(NSString *)cellName
         messageCellDataClassName:(NSString *)cellDataName {
    [self registerCustomMessage:businessID
           messageCellClassName:cellName
       messageCellDataClassName:cellDataName
                      styleType:TUIChatRegisterCustomMessageStyleTypeClassic];
}

- (void)registerCustomMessage:(NSString *)businessID
              messageCellClassName:(NSString *)cellName
          messageCellDataClassName:(NSString *)cellDataName
                    styleType:(TDeskChatRegisterCustomMessageStyleType)styleType {
    
    if (businessID.length <0 || cellName.length <0 ||cellDataName.length <0) {
        NSLog(@"registerCustomMessage Error, check info %s", __func__);
        return;
    }
    NSString * serviceName = @"";
    if (styleType == TUIChatRegisterCustomMessageStyleTypeClassic) {
        serviceName = TDeskCore_TUIChatService;
    }
    else {
        serviceName = TDeskCore_TUIChatService_Minimalist;
    }
    [TDeskCore callService:serviceName
                  method:TDeskCore_TUIChatService_AppendCustomMessageMethod
                   param:@{BussinessID : businessID,
                           TMessageCell_Name : cellName,
                           TMessageCell_Data_Name : cellDataName
                         }
    ];
}


@end
