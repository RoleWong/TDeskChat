//
//  TDeskDeslObjectFactory.h
//  TUIChat
//
//  Created by wyl on 2023/3/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCore/TDesk_TUICore.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDeskDeslObjectFactory : NSObject
+ (TDeskDeslObjectFactory *)shareInstance;
@end

NS_ASSUME_NONNULL_END
