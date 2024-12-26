//
//  TUIInputPreviewBar.h
//  TUIChat
//
//  Created by harvy on 2021/11/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDesk_TUIReplyPreviewData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIReplyPreviewBar_Minimalist : UIView

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *closeButton;
@property(nonatomic, copy) TUIInputPreviewBarCallback onClose;

@property(nonatomic, strong) TDeskReplyPreviewData *previewData;
@property(nonatomic, strong) TDeskReferencePreviewData *previewReferenceData;

@end

@interface TUIReferencePreviewBar_Minimalist : TUIReplyPreviewBar_Minimalist
@end
NS_ASSUME_NONNULL_END
