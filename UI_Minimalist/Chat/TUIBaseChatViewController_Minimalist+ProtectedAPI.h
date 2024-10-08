//
//  TUIBaseChatViewController+ProtectedAPI.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TIMDefine.h>
#import <TDeskCore/TUICore.h>
#import "TUIBaseChatViewController_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIBaseChatViewController_Minimalist () <TUIInputControllerDelegate_Minimalist, TUINotificationProtocol>
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr;
@end

NS_ASSUME_NONNULL_END
