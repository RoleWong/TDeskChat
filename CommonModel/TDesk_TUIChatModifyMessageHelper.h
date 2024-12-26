//
//  TDeskChatModifyMessageHelper.h
//  TUIChat
//
//  Created by wyl on 2022/6/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ImSDK_Plus;

@interface TDeskChatModifyMessageHelper : NSObject

+ (TDeskChatModifyMessageHelper *)defaultHelper;

- (void)modifyMessage:(V2TIMMessage *)msg simpleCurrentContent:(NSDictionary *)simpleCurrentContent;

- (void)modifyMessage:(V2TIMMessage *)msg revokeMsgID:(NSString *)revokeMsgID;

@end
