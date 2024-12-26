
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
//
//  TDeskAudioRecorder.h
//  TUIChat
//

#import <Foundation/Foundation.h>

/// TDeskAudioRecorder is designed for recording audio when sending audio message.

NS_ASSUME_NONNULL_BEGIN

@class TDeskAudioRecorder;
@protocol TDeskAudioRecorderDelegate <NSObject>

- (void)audioRecorder:(TDeskAudioRecorder *)recorder didCheckPermission:(BOOL)isGranted isFirstTime:(BOOL)isFirstTime;
/// Power value can be used to simulate the animation of mic changes when speaking.
- (void)audioRecorder:(TDeskAudioRecorder *)recorder didPowerChanged:(float)power;
- (void)audioRecorder:(TDeskAudioRecorder *)recorder didRecordTimeChanged:(NSTimeInterval)time;

@end

@interface TDeskAudioRecorder : NSObject

@property(nonatomic, weak) id<TDeskAudioRecorderDelegate> delegate;

@property(nonatomic, copy, readonly) NSString *recordedFilePath;

- (void)record;
- (void)stop;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
