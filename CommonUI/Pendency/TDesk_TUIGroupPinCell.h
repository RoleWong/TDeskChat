//
//  TDeskGroupPinCell.h
//  TUIChat
//
//  Created by Tencent on 2024/05/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TDeskCommon/TDesk_NSString+TUIEmoji.h>
#import <TDeskCommon/TDesk_TIMCommonModel.h>
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCore/TDesk_NSDictionary+TUISafe.h>
#import <TDeskCore/TDesk_TUICore.h>
#import <TDeskCore/TDesk_TUILogin.h>
#import <TDeskCommon/TDesk_TUIBubbleMessageCellData.h>
#import <TDeskCommon/TDesk_TUIMessageCellData.h>
NS_ASSUME_NONNULL_BEGIN

@interface TDeskGroupPinCellView : UIView
@property (nonatomic, copy) void(^onClickRemove)(V2TIMMessage *originMessage);
@property (nonatomic, copy) void(^onClickCellView)(V2TIMMessage *originMessage);
@property (nonatomic, strong) TDeskMessageCellData *cellData;
@property (nonatomic, strong) UIImageView *leftIcon;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * content;
@property (nonatomic, strong) UIButton * removeButton;
@property (nonatomic, strong) UIView * multiAnimationView;
@property (nonatomic, strong) UIView * bottomLine;
@property (nonatomic, assign) BOOL isFirstPage;
- (void)fillWithData:(TDeskMessageCellData *)cellData;
- (void)hiddenMultiAnimation;
- (void)showMultiAnimation;
@end

@interface TDeskGroupPinCell : UITableViewCell
@property (nonatomic,strong) TDeskGroupPinCellView* cellView;
- (void)fillWithData:(TDeskMessageCellData *)cellData;
@end

NS_ASSUME_NONNULL_END
