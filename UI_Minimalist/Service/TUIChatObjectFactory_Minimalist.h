//
//  TUIChatObjectFactory_Minimalist.h
//  TUIChat
//
//  Created by wyl on 2023/3/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TDeskCommon/TIMDefine.h>
#import <TDeskCore/TUICore.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatObjectFactory_Minimalist : NSObject
+ (TUIChatObjectFactory_Minimalist *)shareInstance;
@end

NS_ASSUME_NONNULL_END
