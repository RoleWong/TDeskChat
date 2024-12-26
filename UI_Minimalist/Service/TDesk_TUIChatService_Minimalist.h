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

@interface TUIChatService_Minimalist : NSObject <TDeskServiceProtocol>

+ (TUIChatService_Minimalist *)shareInstance;

@end

NS_ASSUME_NONNULL_END
