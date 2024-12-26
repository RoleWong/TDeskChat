
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

@import UIKit;
#import "TDesk_TUICameraMacro.h"

@class TDeskCameraViewController;
@protocol TUICameraViewControllerDelegate <NSObject>

- (void)cameraViewController:(TDeskCameraViewController *)controller didFinishPickingMediaWithVideoURL:(NSURL *)url;
- (void)cameraViewController:(TDeskCameraViewController *)controller didFinishPickingMediaWithImageData:(NSData *)data;
- (void)cameraViewControllerDidCancel:(TDeskCameraViewController *)controller;
- (void)cameraViewControllerDidPictureLib:(TDeskCameraViewController *)controller finishCallback:(void (^)(void))callback;
@end

@interface TDeskCameraViewController : UIViewController

@property(nonatomic, weak) id<TUICameraViewControllerDelegate> delegate;

/// default TUICameraMediaTypePhoto
@property(nonatomic) TDeskCameraMediaType type;

/// default TUICameraViewAspectRatio16x9
@property(nonatomic) TDeskCameraViewAspectRatio aspectRatio;

/// default 15s
@property(nonatomic) NSTimeInterval videoMaximumDuration;
/// default 3s
@property(nonatomic) NSTimeInterval videoMinimumDuration;

@end
