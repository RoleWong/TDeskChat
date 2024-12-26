
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import "TDesk_TUICameraMacro.h"
#import "TDesk_TUICaptureVideoPreviewView.h"

NS_ASSUME_NONNULL_BEGIN

@class TDeskCameraView;
@protocol TDeskCameraViewDelegate <NSObject>
@optional

/**
 * Flash
 */
- (void)flashLightAction:(TDeskCameraView *)cameraView handle:(void (^)(NSError *error))handle;

/**
 * Fill light
 */
- (void)torchLightAction:(TDeskCameraView *)cameraView handle:(void (^)(NSError *error))handle;

/**
 * 
 * Switch camera
 */
- (void)swicthCameraAction:(TDeskCameraView *)cameraView handle:(void (^)(NSError *error))handle;

/**
 * 
 * Auto focus and exposure
 */
- (void)autoFocusAndExposureAction:(TDeskCameraView *)cameraView handle:(void (^)(NSError *error))handle;

/**
 * 
 * Foucus
 */
- (void)focusAction:(TDeskCameraView *)cameraView point:(CGPoint)point handle:(void (^)(NSError *error))handle;

/**
 * 
 * Expose
 */
- (void)exposAction:(TDeskCameraView *)cameraView point:(CGPoint)point handle:(void (^)(NSError *error))handle;

/**
 * 
 * Zoom
 */
- (void)zoomAction:(TDeskCameraView *)cameraView factor:(CGFloat)factor;

- (void)cancelAction:(TDeskCameraView *)cameraView;

- (void)pictureLibAction:(TDeskCameraView *)cameraView;

- (void)takePhotoAction:(TDeskCameraView *)cameraView;

- (void)stopRecordVideoAction:(TDeskCameraView *)cameraView RecordDuration:(CGFloat)duration;

- (void)startRecordVideoAction:(TDeskCameraView *)cameraView;

- (void)didChangeTypeAction:(TDeskCameraView *)cameraView type:(TDeskCameraMediaType)type;

@end

@interface TDeskCameraView : UIView

@property(nonatomic, weak) id<TDeskCameraViewDelegate> delegate;

@property(nonatomic, readonly) TDeskCaptureVideoPreviewView *previewView;

/// default TUICameraMediaTypePhoto
@property(nonatomic) TDeskCameraMediaType type;

/// default TUICameraViewAspectRatio16x9
@property(nonatomic) TDeskCameraViewAspectRatio aspectRatio;

/// default 15s
@property(nonatomic, assign) CGFloat maxVideoCaptureTimeLimit;

@end

NS_ASSUME_NONNULL_END
