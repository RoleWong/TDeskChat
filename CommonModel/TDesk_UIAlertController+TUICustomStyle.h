//
//  UIAlertController+TUICustomStyle.h
//  TUIChat
//
//  Created by wyl on 2022/10/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDeskCustomActionSheetItem : NSObject

@property(nonatomic, assign) NSInteger priority;

@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong) UIImage *leftMark;

@property(nonatomic, assign) UIAlertActionStyle actionStyle;

@property(nonatomic, copy) void (^actionHandler)(UIAlertAction *action);

- (instancetype)initWithTitle:(NSString *)title leftMark:(UIImage *)leftMark withActionHandler:(void (^)(UIAlertAction *action))actionHandler;
@end

@interface UIAlertController (TUICustomStyle)

- (void)configItems:(NSArray<TDeskCustomActionSheetItem *> *)items;

@end

NS_ASSUME_NONNULL_END
