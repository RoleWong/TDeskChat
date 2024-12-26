
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TDeskCameraMediaType) {
    TUICameraMediaTypePhoto = 1,
    TUICameraMediaTypeVideo = 2,
};

typedef NS_ENUM(NSUInteger, TDeskCameraViewAspectRatio) {
    TUICameraViewAspectRatio1x1,
    TUICameraViewAspectRatio16x9,
    TUICameraViewAspectRatio5x4,
};

NS_ASSUME_NONNULL_END
