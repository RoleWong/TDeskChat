//
//  TDeskChatPopContextExtionView.m
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/12/1.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIChatPopContextExtionView.h"
#import <TDeskCommon/TDesk_NSString+TUIEmoji.h>
#import <TDeskCommon/TDesk_TIMCommonModel.h>
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCommon/TDesk_TUIFitButton.h>
#import <TDeskCommon/TDesk_TIMCommonMediator.h>
#import <TDeskCommon/TDesk_TUIEmojiMeditorProtocol.h>

@implementation TDeskChatPopContextExtionItem

- (instancetype)initWithTitle:(NSString *)title markIcon:(UIImage *)markIcon weight:(NSInteger)weight withActionHandler:(void (^)(id action))actionHandler {
    self = [super init];
    if (self) {
        _title = title;
        _markIcon = markIcon;
        _weight = weight;
        _actionHandler = actionHandler;
    }
    return self;
}

@end

@interface TDeskChatPopContextExtionItemView : UIView
@property(nonatomic, strong) TDeskChatPopContextExtionItem *item;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UILabel *l;
- (void)configBaseUIWithItem:(TDeskChatPopContextExtionItem *)item;
@end

@implementation TDeskChatPopContextExtionItemView

- (void)configBaseUIWithItem:(TDeskChatPopContextExtionItem *)item {
    self.item = item;
    CGFloat itemWidth = self.frame.size.width;
    CGFloat padding = kScale390(16);
    CGFloat itemHeight = self.frame.size.height;

    UIImageView *icon = [[UIImageView alloc] init];
    [self addSubview:icon];
    icon.frame = CGRectMake(itemWidth - padding - kScale390(18), itemHeight * 0.5 - kScale390(18) * 0.5, kScale390(18), kScale390(18));
    icon.image = self.item.markIcon;

    UILabel *l = [[UILabel alloc] init];
    l.frame = CGRectMake(padding, 0, itemWidth * 0.5, itemHeight);
    l.text = self.item.title;
    l.font = item.titleFont ?: [UIFont systemFontOfSize:kScale390(16)];
    l.textAlignment = isRTL()? NSTextAlignmentRight:NSTextAlignmentLeft;
    l.textColor = item.titleColor ?: [UIColor blackColor];
    l.userInteractionEnabled = false;
    [self addSubview:l];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton addTarget:self action:@selector(buttonclick) forControlEvents:UIControlEventTouchUpInside];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backButton.frame = CGRectMake(0, 0, itemWidth, itemHeight);

    [self addSubview:backButton];

    if (item.needBottomLine) {
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor tdesk_colorWithHex:@"DDDDDD"];
        line.frame = CGRectMake(0, itemHeight - kScale390(0.5), itemWidth, kScale390(0.5));
        [self addSubview:line];
    }
    self.layer.masksToBounds = YES;
    if (isRTL()) {
        for (UIView *subview in self.subviews) {
            [subview resetFrameToFitRTL];
        }
    }
}

- (void)buttonclick {
    if (self.item.actionHandler) {
        self.item.actionHandler(self.item);
    }
}

@end

@interface TDeskChatPopContextExtionView ()

@property(nonatomic, strong) NSMutableArray<TDeskChatPopContextExtionItem *> *items;

@end

@implementation TDeskChatPopContextExtionView
- (void)configUIWithItems:(NSMutableArray<TDeskChatPopContextExtionItem *> *)items topBottomMargin:(CGFloat)topBottomMargin {
    if (self.subviews.count > 0) {
        for (UIView *subview in self.subviews) {
            if (subview) {
                [subview removeFromSuperview];
            }
        }
    }
    int i = 0;
    for (TDeskChatPopContextExtionItem *item in items) {
        TDeskChatPopContextExtionItemView *itemView = [[TDeskChatPopContextExtionItemView alloc] init];
        itemView.frame = CGRectMake(0, (kScale390(40)) * i + topBottomMargin, kScale390(180), kScale390(40));
        [itemView configBaseUIWithItem:item];
        [self addSubview:itemView];
        i++;
    }
}
@end
