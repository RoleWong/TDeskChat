//
//  TDeskRepliesDetailViewController.h
//  TUIChat
//
//  Created by wyl on 2022/4/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TDesk_TUIBaseMessageControllerDelegate.h"
#import "TDesk_TUIChatConversationModel.h"
#import "TDesk_TUIInputController.h"

@class TDeskMessageDataProvider;

NS_ASSUME_NONNULL_BEGIN

@interface TDeskRepliesDetailViewController : UIViewController

- (instancetype)initWithCellData:(TDeskMessageCellData *)data conversationData:(TDeskChatConversationModel *)conversationData;

@property(nonatomic, weak) id<TDeskBaseMessageControllerDelegate> delegate;
@property(nonatomic, strong) V2TIMMergerElem *mergerElem;
@property(nonatomic, copy) dispatch_block_t willCloseCallback;
@property(nonatomic, strong) TDeskInputController *inputController;
@property(nonatomic, strong) TDeskMessageDataProvider *parentPageDataProvider;

@end

NS_ASSUME_NONNULL_END
