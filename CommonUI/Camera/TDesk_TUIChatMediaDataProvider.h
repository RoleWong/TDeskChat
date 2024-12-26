//
//  TDeskChatMediaDataProvider.h
//  TUIChat
//
//  Created by harvy on 2022/12/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TDeskCommon/TDesk_TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDeskChatMediaDataProviderResultCallback)(BOOL success, NSString *__nullable message, NSString *__nullable path);

@protocol TDeskChatMediaDataProtocol <NSObject>

- (void)selectPhoto;
- (void)takePicture;
- (void)takeVideo;
- (void)selectFile;

@end

@protocol TDeskChatMediaDataListener <NSObject>

- (void)onProvideImage:(NSString *)imageUrl;
- (void)onProvideImageError:(NSString *)errorMessage;

- (void)onProvideVideo:(NSString *)videoUrl
               snapshot:(NSString *)snapshotUrl
               duration:(NSInteger)duration
    placeHolderCellData:(TDeskMessageCellData *)placeHolderCellData;
- (void)onProvidePlaceholderVideoSnapshot:(NSString *)snapshotUrl
                                SnapImage:(UIImage *)img
                               Completion:(void (^__nullable)(BOOL finished, TDeskMessageCellData *placeHolderCellData))completion;
- (void)onProvideVideoError:(NSString *)errorMessage;
- (void)onProvideFile:(NSString *)fileUrl filename:(NSString *)filename fileSize:(NSInteger)fileSize;
- (void)onProvideFileError:(NSString *)errorMessage;

@end

@interface TDeskChatMediaDataProvider : NSObject <TDeskChatMediaDataProtocol>

@property(nonatomic, weak) UIViewController *presentViewController;
@property(nonatomic, weak) id<TDeskChatMediaDataListener> listener;

@end

NS_ASSUME_NONNULL_END
