//
//  TUIReplyQuoteView_Minimalist.h
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TDeskReplyQuoteViewData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReplyQuoteView_Minimalist : UIView

@property(nonatomic, strong) TDeskReplyQuoteViewData *data;

- (void)fillWithData:(TDeskReplyQuoteViewData *)data;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
