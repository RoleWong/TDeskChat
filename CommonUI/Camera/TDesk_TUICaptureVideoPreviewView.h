
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface TDeskCaptureVideoPreviewView : UIView

@property(strong, nonatomic) AVCaptureSession *captureSessionsion;

- (CGPoint)captureDevicePointForPoint:(CGPoint)point;

@end
