//
//  TDeskRepliesDetailViewController.h
//  TUIChat
//
//  Created by wyl on 2022/4/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TDesk_TUIBaseMessageControllerDelegate_Minimalist.h"
#import "TDesk_TUIChatConversationModel.h"
#import "TDesk_TUIChatFlexViewController.h"
#import "TDesk_TUIInputController_Minimalist.h"
#import "TDesk_TUIMessageDataProvider.h"

@class TDeskMessageDataProvider;

NS_ASSUME_NONNULL_BEGIN

@interface TUIRepliesDetailViewController_Minimalist : TDeskChatFlexViewController

- (instancetype)initWithCellData:(TDeskMessageCellData *)data conversationData:(TDeskChatConversationModel *)conversationData;

@property(nonatomic, weak) id<TUIBaseMessageControllerDelegate_Minimalist> delegate;
@property(nonatomic, strong) V2TIMMergerElem *mergerElem;
@property(nonatomic, copy) dispatch_block_t willCloseCallback;
@property(nonatomic, strong) TUIInputController_Minimalist *inputController;
@property(nonatomic, strong) TDeskMessageDataProvider *parentPageDataProvider;

@end

NS_ASSUME_NONNULL_END
