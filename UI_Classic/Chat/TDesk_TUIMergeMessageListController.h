//
//  TDeskMergeMessageListController.h
//  Pods
//
//  Created by harvy on 2020/12/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TDesk_TUIBaseMessageControllerDelegate.h"
#import "TDesk_TUIChatConversationModel.h"
#import "TDesk_TUIMessageDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDeskMergeMessageListController : UITableViewController

@property(nonatomic, weak) id<TDeskBaseMessageControllerDelegate> delegate;
@property(nonatomic, strong) V2TIMMergerElem *mergerElem;
@property(nonatomic, copy) dispatch_block_t willCloseCallback;
@property(nonatomic, strong) TDeskChatConversationModel *conversationData;
@property(nonatomic, strong) TDeskMessageDataProvider *parentPageDataProvider;

@end

NS_ASSUME_NONNULL_END
