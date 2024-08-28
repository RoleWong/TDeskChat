//
//  TUIGroupPinCell.h
//  TUIChat
//
//  Created by Tencent on 2024/05/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TDeskCommon/NSString+TUIEmoji.h>
#import <TDeskCommon/TIMCommonModel.h>
#import <TDeskCommon/TIMDefine.h>
#import <TDeskCore/NSDictionary+TUISafe.h>
#import <TDeskCore/TUICore.h>
#import <TDeskCore/TUILogin.h>
#import <TDeskCommon/TUIBubbleMessageCellData.h>
#import <TDeskCommon/TUIMessageCellData.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupPinCellView : UIView
@property (nonatomic, copy) void(^onClickRemove)(V2TIMMessage *originMessage);
@property (nonatomic, copy) void(^onClickCellView)(V2TIMMessage *originMessage);
@property (nonatomic, strong) TUIMessageCellData *cellData;
@property (nonatomic, strong) UIImageView *leftIcon;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * content;
@property (nonatomic, strong) UIButton * removeButton;
@property (nonatomic, strong) UIView * multiAnimationView;
@property (nonatomic, strong) UIView * bottomLine;
@property (nonatomic, assign) BOOL isFirstPage;
- (void)fillWithData:(TUIMessageCellData *)cellData;
- (void)hiddenMultiAnimation;
- (void)showMultiAnimation;
@end

@interface TUIGroupPinCell : UITableViewCell
@property (nonatomic,strong) TUIGroupPinCellView* cellView;
- (void)fillWithData:(TUIMessageCellData *)cellData;
@end

NS_ASSUME_NONNULL_END
