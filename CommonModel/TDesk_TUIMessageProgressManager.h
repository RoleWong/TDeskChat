//
//  TDeskMessageProgressManager.h
//  TUIChat
//
//  Created by harvy on 2022/1/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TDeskMessageSendingResultType) { TUIMessageSendingResultTypeSucc = 0, TUIMessageSendingResultTypeFail = 1 };

@protocol TDeskMessageProgressManagerDelegate <NSObject>

- (void)onUploadProgress:(NSString *)msgID progress:(NSInteger)progress;
- (void)onDownloadProgress:(NSString *)msgID progress:(NSInteger)progress;

- (void)onMessageSendingResultChanged:(TDeskMessageSendingResultType)type messageID:(NSString *)msgID;

@end

@interface TDeskMessageProgressManager : NSObject

+ (instancetype)shareManager;

- (void)addDelegate:(id<TDeskMessageProgressManagerDelegate>)delegate;
- (void)removeDelegate:(id<TDeskMessageProgressManagerDelegate>)delegate;

- (NSInteger)uploadProgressForMessage:(NSString *)msgID;
- (NSInteger)downloadProgressForMessage:(NSString *)msgID;
- (void)appendUploadProgress:(NSString *)msgID progress:(NSInteger)progress;
- (void)appendDownloadProgress:(NSString *)msgID progress:(NSInteger)progress;
- (void)notifyMessageSendingResult:(NSString *)msgID result:(TDeskMessageSendingResultType)result;

@end

NS_ASSUME_NONNULL_END
