//
//  TResponderTextView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/25.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TDeskResponderTextView;

@protocol TDeskResponderTextViewDelegate <UITextViewDelegate>

- (void)onDeleteBackward:(TDeskResponderTextView *)textView;

@end

@interface TDeskResponderTextView : UITextView
@property(nonatomic, weak) UIResponder *overrideNextResponder;
@end
