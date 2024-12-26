//
//  TDeskBaseMessageController+ProtectedAPI.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/7/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIBaseMessageController_Minimalist.h"
#import "TDesk_TUIChatConversationModel.h"
#import "TDesk_TUIMessageDataProvider.h"

@class TDeskMessageCellData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIBaseMessageController_Minimalist () <TDeskMessageBaseDataProviderDataSource>

@property(nonatomic, strong) TDeskMessageDataProvider *messageDataProvider;
@property(nonatomic, strong) TDeskChatConversationModel *conversationData;
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;

- (void)onNewMessage:(NSNotification *)notification;

- (void)onJumpToRepliesDetailPage:(TDeskMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
