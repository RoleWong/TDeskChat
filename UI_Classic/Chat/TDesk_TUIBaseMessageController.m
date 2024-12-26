//
//  TDeskBaseMessageController.m
//  UIKit
//
//  Created by annidyfeng on 2019/7/1.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TDesk_TUIBaseMessageController.h"
#import <TDeskCommon/TDesk_TIMConfig.h>
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCommon/TDesk_TIMPopActionProtocol.h>
#import <TDeskCommon/TDesk_TUISystemMessageCell.h>
#import <TDeskCore/TDesk_TUICore.h>
#import <TDeskCore/TDesk_TUIThemeManager.h>
#import <TDeskCore/TDesk_TUITool.h>
#import <UIKit/UIWindow.h>
#import "TDesk_TUIChatCallingDataProvider.h"
#import "TDesk_TUIChatConversationModel.h"
#import "TDesk_TUIChatDataProvider.h"
#import "TDesk_TUIChatPopMenu.h"
#import "TDesk_TUIFaceMessageCell.h"
#import "TDesk_TUIFaceView.h"
#import "TDesk_TUIFileMessageCell.h"
#import "TDesk_TUIFileViewController.h"
#import "TDesk_TUIImageMessageCell.h"
#import "TDesk_TUIJoinGroupMessageCell.h"
#import "TDesk_TUILinkCell.h"
#import "TDesk_TUIMediaView.h"
#import "TDesk_TUIMergeMessageCell.h"
#import "TDesk_TUIMergeMessageListController.h"
#import "TDesk_TUIMessageDataProvider.h"
#import "TDesk_TUIMessageProgressManager.h"
#import "TDesk_TUIMessageReadViewController.h"
#import "TDesk_TUIOrderCell.h"
#import "TDesk_TUIReferenceMessageCell.h"
#import "TDesk_TUIRepliesDetailViewController.h"
#import "TDesk_TUIReplyMessageCell.h"
#import "TDesk_TUIReplyMessageCellData.h"
#import "TDesk_TUITextMessageCell.h"
#import "TDesk_TUIVideoMessageCell.h"
#import "TDesk_TUIVoiceMessageCell.h"
#import "TDesk_TUIMessageCellConfig.h"

@interface TDeskBaseMessageController () <TDeskMessageCellDelegate,
                                        TUIJoinGroupMessageCellDelegate,
                                        TDeskMessageProgressManagerDelegate,
                                        TDeskMessageDataProviderDataSource,
                                        TUINotificationProtocol,
                                        TDeskPopActionProtocol>

@property(nonatomic, strong) TDeskMessageDataProvider *messageDataProvider;
@property(nonatomic, strong) TDeskMessageCellData *menuUIMsg;
@property(nonatomic, strong) TDeskMessageCellData *reSendUIMsg;
@property(nonatomic, strong) TDeskChatConversationModel *conversationData;
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property(nonatomic, assign) BOOL isActive;
@property(nonatomic, assign) BOOL showCheckBox;
@property(nonatomic, assign) BOOL scrollingTriggeredByUser;
@property(nonatomic, assign) BOOL isAutoScrolledToBottom;
@property(nonatomic, assign) BOOL hasCoverPage;
@property(nonatomic, strong) TDeskMessageCellConfig *messageCellConfig;
@property(nonatomic, strong) TDeskVoiceMessageCellData *currentVoiceMsg;
@end

@implementation TDeskBaseMessageController
+ (void)initialize {
    [TDeskMessageDataProvider setDataSourceClass:self];
}

+ (void)asyncGetDisplayString:(NSArray<V2TIMMessage *> *)messageList callback:(void(^)(NSDictionary<NSString *, NSString *> *))callback {
  [TDeskMessageDataProvider asyncGetDisplayString:messageList callback:callback];
}

+ (nullable NSString *)getDisplayString:(V2TIMMessage *)message {
    return [TDeskMessageDataProvider getDisplayString:message];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self registerEvents];
    self.isActive = YES;
    [TDeskTool addUnsupportNotificationInVC:self];
    [TDeskMessageProgressManager.shareManager addDelegate:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TDeskMessageProgressManager.shareManager removeDelegate:self];
    [TDeskCore unRegisterEventByObject:self];
    NSLog(@"%s dealloc", __FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated {
    self.isInVC = YES;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self sendVisibleReadGroupMessages];
    [self limitReadReport];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isInVC = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_currentVoiceMsg) {
        [_currentVoiceMsg stopVoiceMessage];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TUIChatSendMessageNotification object:nil];
}

- (void)applicationBecomeActive {
    self.isActive = YES;
    [self sendVisibleReadGroupMessages];
}

- (void)applicationEnterBackground {
    self.isActive = NO;
}

- (void)setupViews {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapViewController)];
    /**
     * Solve the problem that the touch event is not passed down, causing the gesture to conflict with the collectionView didselect
     */
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    self.tableView.scrollsToTop = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, TMessageController_Header_Height)];
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.tableView.tableHeaderView = self.indicatorView;
    if (!self.indicatorView.isAnimating) {
        [self.indicatorView startAnimating];
    }
    [self.messageCellConfig bindTableView:self.tableView];
}

- (void)registerEvents {
    [TDeskCore registerEvent:TUICore_TUIPluginNotify
                    subKey:TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey
                    object:self];
    [TDeskCore registerEvent:TUICore_TUIPluginNotify
                    subKey:TUICore_TUIPluginNotify_WillForwardTextSubKey
                    object:self];
    [TDeskCore registerEvent:TUICore_TUIPluginNotify
                    subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                    object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBecomeActive)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedSendMessageRequest:) name:TUIChatSendMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedSendMessageWithoutUpdateUIRequest:) name:TUIChatSendMessageWithoutUpdateUINotification object:nil];
}

- (TDeskMessageCellConfig *)messageCellConfig {
    if (_messageCellConfig == nil) {
        _messageCellConfig = [[TDeskMessageCellConfig alloc] init];
    }
    return _messageCellConfig;
}

#pragma mark - Data Provider
- (void)setConversation:(TDeskChatConversationModel *)conversationData {
    self.conversationData = conversationData;
    if (!self.messageDataProvider) {
        self.messageDataProvider = [[TDeskMessageDataProvider alloc] initWithConversationModel:conversationData];
        self.messageDataProvider.dataSource = self;
    }
    [self loadMessage];
    [self loadGroupInfo];
}

- (void)loadMessage {
    if (self.messageDataProvider.isLoadingData || self.messageDataProvider.isNoMoreMsg) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.messageDataProvider
     loadMessageSucceedBlock:^(BOOL isFirstLoad, BOOL isNoMoreMsg, NSArray<TDeskMessageCellData *> *_Nonnull newMsgs) {
        if (isNoMoreMsg) {
            weakSelf.indicatorView.mm_h = 0;
        }
        if (newMsgs.count != 0) {
            [weakSelf.tableView reloadData];
            [weakSelf.tableView layoutIfNeeded];
            
            if (isFirstLoad) {
                [weakSelf scrollToBottom:NO];
            } else {
                CGFloat visibleHeight = 0;
                for (NSInteger i = 0; i < newMsgs.count; ++i) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    visibleHeight += [weakSelf tableView:weakSelf.tableView heightForRowAtIndexPath:indexPath];
                }
                if (isNoMoreMsg) {
                    visibleHeight -= TMessageController_Header_Height;
                }
                [weakSelf.tableView scrollRectToVisible:CGRectMake(0, weakSelf.tableView.contentOffset.y + visibleHeight, weakSelf.tableView.frame.size.width,
                                                                   weakSelf.tableView.frame.size.height)
                                               animated:NO];
            }
        }
    }
     FailBlock:^(int code, NSString *desc) {
        [TDeskTool makeToastError:code msg:desc];
    }];
}

- (void)loadGroupInfo {
    if (self.conversationData.groupID.length > 0) {
        [self.messageDataProvider getPinMessageList];
        [self.messageDataProvider getSelfInfoInGroup:^{
            
        }];
        __weak typeof(self) weakSelf = self;
        self.messageDataProvider.groupRoleChanged = ^(V2TIMGroupMemberRole role) {
            if (weakSelf.groupRoleChanged) {
                weakSelf.groupRoleChanged(role);
            }
        };
        self.messageDataProvider.pinGroupMessageChanged = ^(NSArray * _Nonnull groupPinList) {
            if (weakSelf.pinGroupMessageChanged) {
                weakSelf.pinGroupMessageChanged(groupPinList);
            }
        };
    }
}
- (void)clearUImsg {
    [self.messageDataProvider clearUIMsgList];
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
}

- (void)reloadAndScrollToBottomOfMessage:(NSString *)messageID needScroll:(BOOL)isNeedScroll {
    // Dispatch the task to RunLoop to ensure that they are executed after the UITableView refresh is complete.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadCellOfMessage:messageID];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isNeedScroll) {
                [self scrollCellToBottomOfMessage:messageID];
            }
        });
    });
}
- (void)reloadAndScrollToBottomOfMessage:(NSString *)messageID {
    [self reloadAndScrollToBottomOfMessage:messageID needScroll:YES];
}

- (void)reloadCellOfMessage:(NSString *)messageID {
    NSIndexPath *indexPath = [self indexPathOfMessage:messageID];
    
    // Disable animation when loading to avoid cell jumping.
    if (indexPath == nil) {
        return;
    }
    [UIView performWithoutAnimation:^{
        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)scrollCellToBottomOfMessage:(NSString *)messageID {
    if (self.hasCoverPage) {
        return;
    }
    NSIndexPath *indexPath = [self indexPathOfMessage:messageID];
    
    // Scroll the tableView only if the bottom of the cell is invisible.
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    CGRect tableViewRect = self.tableView.bounds;
    BOOL isBottomInvisible = (cellRect.origin.y < CGRectGetMaxY(tableViewRect) && CGRectGetMaxY(cellRect) > CGRectGetMaxY(tableViewRect)) ||
    (cellRect.origin.y >= CGRectGetMaxY(tableViewRect));
    if (isBottomInvisible) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (self.isAutoScrolledToBottom) {
        [self scrollToBottom:YES];
    }
}

- (NSIndexPath *)indexPathOfMessage:(NSString *)messageID {
    for (int i = 0; i < self.messageDataProvider.uiMsgs.count; i++) {
        TDeskMessageCellData *data = self.messageDataProvider.uiMsgs[i];
        if ([data.innerMessage.msgID isEqualToString:messageID]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

#pragma mark - Event Response
- (void)scrollToBottom:(BOOL)animate {
    // Do not call this interface frequently in a short period of time, as it will affect the UI experience.
    if (self.messageDataProvider.uiMsgs.count > 0) {
        NSIndexPath *bottom = [NSIndexPath indexPathForRow:self.messageDataProvider.uiMsgs.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:bottom atScrollPosition:UITableViewScrollPositionBottom animated:animate];
        self.isAutoScrolledToBottom = YES;
    }
}

- (void)didTapViewController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapInMessageController:)]) {
        [self.delegate didTapInMessageController:self];
    }
}

- (void)sendPlaceHolderUIMessage:(TDeskMessageCellData *)cellData {
    [self.messageDataProvider sendPlaceHolderUIMessage:cellData];
    [self scrollToBottom:YES];
}

- (void)sendUIMessage:(TDeskMessageCellData *)cellData {
    @weakify(self);
    cellData.innerMessage.needReadReceipt = self.isMsgNeedReadReceipt;
    [self.messageDataProvider sendUIMsg:cellData
                         toConversation:self.conversationData
                          willSendBlock:^(BOOL isReSend, TDeskMessageCellData *_Nonnull dateUIMsg) {
        @strongify(self);
        if ([cellData isKindOfClass:[TDeskVideoMessageCellData class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToBottom:YES];
            });
        } else {
            [self scrollToBottom:YES];
        }
        [self setUIMessageStatus:cellData status:Msg_Status_Sending_2];
    }
                              SuccBlock:^{
        @strongify(self);
        [self reloadUIMessage:cellData];
        [self setUIMessageStatus:cellData status:Msg_Status_Succ];

        NSDictionary *param = @{
            TUICore_TUIChatNotify_SendMessageSubKey_Code : @0,
            TUICore_TUIChatNotify_SendMessageSubKey_Desc : @"",
            TUICore_TUIChatNotify_SendMessageSubKey_Message : cellData.innerMessage
        };
        [TDeskCore notifyEvent:TUICore_TUIChatNotify subKey:TUICore_TUIChatNotify_SendMessageSubKey object:self param:param];
    }
                              FailBlock:^(int code, NSString *desc) {
        @strongify(self);
        [self reloadUIMessage:cellData];
        [self setUIMessageStatus:cellData status:Msg_Status_Fail];
        [self makeSendErrorHud:code desc:desc];
        
        NSDictionary *param = @{TUICore_TUIChatNotify_SendMessageSubKey_Code : @(code),
                                TUICore_TUIChatNotify_SendMessageSubKey_Desc : desc};
        [TDeskCore notifyEvent:TUICore_TUIChatNotify subKey:TUICore_TUIChatNotify_SendMessageSubKey object:self param:param];
    }];
}

- (void)setUIMessageStatus:(TDeskMessageCellData *)cellData status:(TDeskMsgStatus)status {
    switch (status) {
        case Msg_Status_Init:
        case Msg_Status_Succ:
        case Msg_Status_Fail:
            {
                [self changeMsg:cellData status:status];
            }
            break;
        case Msg_Status_Sending:
        case Msg_Status_Sending_2:
            {
                int delay = 1;
                if ([cellData isKindOfClass:[TDeskImageMessageCellData class]] ||
                    [cellData isKindOfClass:[TDeskVideoMessageCellData class]]) {
                    delay = 0;
                }
                if (0 == delay) {
                    [self changeMsg:cellData status:Msg_Status_Sending_2];
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (cellData.innerMessage.status == V2TIM_MSG_STATUS_SENDING) {
                            [self changeMsg:cellData status:Msg_Status_Sending_2];
                        }
                    });
                }
            }
            break;
            
        default:
            break;
    }
}

- (void)makeSendErrorHud:(int)code desc:(NSString *)desc  {
    // The text or image msg is sensitive, the cell height may change.
    if (code == 80001 || code == 80004) {
        [self scrollToBottom:YES];
        return;
    }
    
    NSString *errorMsg = @"";
    if (self.isMsgNeedReadReceipt && code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
        errorMsg = [NSString stringWithFormat:@"%@%@", TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceMessageRead),
                                         TUIKitLocalizableString(TUIKitErrorUnsupporInterfaceSuffix)];
    } else {
        errorMsg = [TDeskTool convertIMError:code msg:desc];
    }
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:errorMsg message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)sendMessage:(V2TIMMessage *)message {
    [self sendMessage:message placeHolderCellData:nil];
}

- (void)sendMessage:(V2TIMMessage *)message placeHolderCellData:(TDeskMessageCellData *)placeHolderCellData {
    TDeskMessageCellData *cellData = nil;
    if (message.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        cellData = [self.delegate messageController:self onNewMessage:message];
        cellData.innerMessage = message;
    }
    if (!cellData) {
        cellData = [TDeskMessageDataProvider getCellData:message];
    }
    if (cellData) {
        cellData.placeHolderCellData = placeHolderCellData;
        [self sendUIMessage:cellData];
    }
}

- (void)reloadUIMessage:(TDeskMessageCellData *)msg {
    // innerMessage maybe changed, reload it
    NSInteger index = [self.messageDataProvider.uiMsgs indexOfObject:msg];
    NSMutableArray *newUIMsgs = [self.messageDataProvider transUIMsgFromIMMsg:@[ msg.innerMessage ]];
    if (newUIMsgs.count == 0) {
        return;
    }
    TDeskMessageCellData *newUIMsg = newUIMsgs.firstObject;
    @weakify(self)
    [self.messageDataProvider preProcessMessage:@[ newUIMsg ]
                                       callback:^{
        @strongify(self)
        [self.messageDataProvider replaceUIMsg:newUIMsg atIndex:index];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] 
                              withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)changeMsg:(TDeskMessageCellData *)msg status:(TDeskMsgStatus)status {
    msg.status = status;
    NSInteger index = [self.messageDataProvider.uiMsgs indexOfObject:msg];
    if ([self.tableView numberOfRowsInSection:0] > index) {
        TDeskMessageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell fillWithData:msg];
    } else {
        NSLog(@"lack of cell");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTUINotifyMessageStatusChanged"
                                                        object:nil
                                                      userInfo:@{
        @"msg" : msg,
        @"status" : [NSNumber numberWithUnsignedInteger:status],
        @"msgSender" : self,
    }];
}

- (void)onReceivedSendMessageRequest:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo == nil) {
        return;
    }
    V2TIMMessage *message = [userInfo objectForKey:TUICore_TUIChatService_SendMessageMethod_MsgKey];
    if (message == nil) {
        return;
    }
    [self sendMessage:message];
}

- (void)onReceivedSendMessageWithoutUpdateUIRequest:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo == nil) {
        return;
    }
    V2TIMMessage *message = [userInfo objectForKey:TUICore_TUIChatService_SendMessageMethodWithoutUpdateUI_MsgKey];
    if (message == nil) {
        return;
    }
    TDeskSendMessageAppendParams *param = [TDeskSendMessageAppendParams new];
    param.isOnlineUserOnly = YES;
    [TDeskMessageDataProvider sendMessage:message
                         toConversation:self.conversationData
                           appendParams:param
                               Progress:nil
                              SuccBlock:^{
        NSLog(@"send message without updating UI succeed");
    }
                              FailBlock:^(int code, NSString *desc) {
        NSLog(@"send message without updating UI failed, code: %d, desc: %@", code, desc);
    }];
}

#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIPluginNotify] && [subKey isEqualToString:TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey]) {
        V2TIMMessage *message = param[TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey_Message];
        for (TDeskMessageCellData *data in self.messageDataProvider.uiMsgs) {
            if (data.innerMessage == message) {
                [self.messageCellConfig removeHeightCacheOfMessageCellData:data];
                [self reloadAndScrollToBottomOfMessage:data.innerMessage.msgID];
                NSIndexPath *indexPath = [self indexPathOfMessage:data.innerMessage.msgID];
                [self.tableView beginUpdates];
                [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                [self.tableView endUpdates];
                break;
            }
        }
    } else if ([key isEqualToString: TUICore_TUIPluginNotify] && [subKey isEqualToString:TUICore_TUIPluginNotify_DidChangePluginViewSubKey]) {
        // Plugin View is Shown or content changed.
        TDeskMessageCellData *data = param[TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data];
        BOOL isAllowScroll2Bottom = YES;
        if ([param[TUICore_TUIPluginNotify_DidChangePluginViewSubKey_isAllowScroll2Bottom] isEqualToString:@"0"] ) {
            isAllowScroll2Bottom = NO ;
            TDeskMessageCellData *lasData = [self.messageDataProvider.uiMsgs lastObject];
            if ([lasData.msgID isEqualToString:data.msgID] ) {
                isAllowScroll2Bottom = YES;
            }
        }
        [self.messageCellConfig removeHeightCacheOfMessageCellData:data];
        [self reloadAndScrollToBottomOfMessage:data.innerMessage.msgID needScroll:isAllowScroll2Bottom];
    } else if ([key isEqualToString:TUICore_TUIPluginNotify] && [subKey isEqualToString:TUICore_TUIPluginNotify_WillForwardTextSubKey]) {
        // Text will be forwarded.
        NSString *text = param[TUICore_TUIPluginNotify_WillForwardTextSubKey_Text];
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageController:onForwardText:)]) {
            [self.delegate messageController:self onForwardText:text];
        }
    }
}

#pragma mark - TDeskMessageProgressManagerDelegate
- (void)onMessageSendingResultChanged:(TDeskMessageSendingResultType)type messageID:(NSString *)msgID {
    // async
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (TDeskMessageCellData *cellData in weakSelf.messageDataProvider.uiMsgs) {
            if ([cellData.msgID isEqual:msgID]) {
                [weakSelf changeMsg:cellData status:(type == TUIMessageSendingResultTypeSucc) ? Msg_Status_Succ : Msg_Status_Fail];
            }
        }
    });
}

#pragma mark - TDeskMessageBaseDataProviderDataSource
+ (Class)onGetCustomMessageCellDataClass:(NSString *)businessID {
    return [TDeskMessageCellConfig getCustomMessageCellDataClass:businessID];
}

- (void)dataProviderDataSourceWillChange:(TDeskMessageDataProvider *)dataProvider {
    [self.tableView beginUpdates];
}

- (void)dataProviderDataSourceChange:(TDeskMessageDataProvider *)dataProvider
                            withType:(TDeskMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation {
    switch (type) {
        case TDeskMessageBaseDataProviderDataSourceChangeTypeInsert:
            [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                                  withRowAnimation:animation ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
            break;
        case TDeskMessageBaseDataProviderDataSourceChangeTypeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                                  withRowAnimation:animation ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
            break;
        case TDeskMessageBaseDataProviderDataSourceChangeTypeReload:
            [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                                  withRowAnimation:animation ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
            break;
        default:
            break;
    }
}

- (void)dataProviderDataSourceDidChange:(TDeskMessageDataProvider *)dataProvider {
    [self.tableView endUpdates];
}

- (void)dataProvider:(TDeskMessageBaseDataProvider *)dataProvider onRemoveHeightCache:(TDeskMessageCellData *)cellData {
    if (cellData) {
        [self.messageCellConfig removeHeightCacheOfMessageCellData:cellData];
    }
}

- (nullable TDeskMessageCellData *)dataProvider:(TDeskMessageDataProvider *)dataProvider CustomCellDataFromNewIMMessage:(V2TIMMessage *)msg {
    if (![msg.userID isEqualToString:self.conversationData.userID] && ![msg.groupID isEqualToString:self.conversationData.groupID]) {
        return nil;
    }
    
    if (msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        return nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(messageController:onNewMessage:)]) {
        TDeskMessageCellData *customCellData = [self.delegate messageController:self onNewMessage:msg];
        if (customCellData) {
            customCellData.innerMessage = msg;
            return customCellData;
        }
    }
    return nil;
}

- (void)dataProvider:(TDeskMessageDataProvider *)dataProvider ReceiveReadMsgWithUserID:(NSString *)userId Time:(time_t)timestamp {
    if (userId.length > 0 && [userId isEqualToString:self.conversationData.userID]) {
        for (int i = 0; i < self.messageDataProvider.uiMsgs.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageDataProvider.uiMsgs.count - 1 - i inSection:0];
            TDeskMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            /**
             * 
             * Determine whether the current unread needs to be changed to read by the callback timestamp
             */
            time_t msgTime = [cell.messageData.innerMessage.timestamp timeIntervalSince1970];
            if (msgTime <= timestamp && ![cell.readReceiptLabel.text isEqualToString:TIMCommonLocalizableString(Read)]) {
                cell.readReceiptLabel.text = TIMCommonLocalizableString(Read);
            }
        }
    }
}

- (void)dataProvider:(TDeskMessageDataProvider *)dataProvider
ReceiveReadMsgWithGroupID:(NSString *)groupID
               msgID:(NSString *)msgID
           readCount:(NSUInteger)readCount
         unreadCount:(NSUInteger)unreadCount {
    if (groupID != nil && ![groupID isEqualToString:self.conversationData.groupID]) {
        return;
    }
    NSInteger row = [self.messageDataProvider getIndexOfMessage:msgID];
    if (row < 0 || row >= self.messageDataProvider.uiMsgs.count) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    TDeskMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell updateReadLabelText];
}

- (void)dataProvider:(TDeskMessageDataProvider *)dataProvider ReceiveNewUIMsg:(TDeskMessageCellData *)uiMsg {
    /**
     * When viewing historical messages, judge whether you need to slide to the bottom according to the current contentOffset
     */
    if (self.tableView.contentSize.height - self.tableView.contentOffset.y < Screen_Height * 1.5) {
        [self scrollToBottom:YES];
        if (self.isInVC && self.isActive) {
            [self.messageDataProvider sendLatestMessageReadReceipt];
        }
    }
    
    [self limitReadReport];
}

- (void)dataProvider:(TDeskMessageDataProvider *)dataProvider ReceiveRevokeUIMsg:(TDeskMessageCellData *)uiMsg {
    return;
}

#pragma mark - Private
- (void)limitReadReport {
    static uint64_t lastTs = 0;
    uint64_t curTs = [[NSDate date] timeIntervalSince1970];
    /**
     * More than 1s && Not the first time, report immediately
     */
    if (curTs - lastTs >= 1 && lastTs) {
        lastTs = curTs;
        [self readReport];
    } else {
        /**
         * Less than 1s || First time, delay 1s and merge report
         */
        static BOOL delayReport = NO;
        if (delayReport) {
            return;
        }
        delayReport = YES;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf readReport];
            delayReport = NO;
        });
    }
}

- (void)readReport {
    if (self.isInVC && self.isActive) {
        NSString *userID = self.conversationData.userID;
        if (userID.length > 0) {
            [TDeskMessageDataProvider markC2CMessageAsRead:userID succ:nil fail:nil];
        }
        NSString *groupID = self.conversationData.groupID;
        if (groupID.length > 0) {
            [TDeskMessageDataProvider markGroupMessageAsRead:groupID succ:nil fail:nil];
        }
        
        NSString *conversationID = @"";
        
        if (IS_NOT_EMPTY_NSSTRING(userID)) {
            conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
        }
        
        if (IS_NOT_EMPTY_NSSTRING(groupID)) {
            conversationID = [NSString stringWithFormat:@"group_%@", groupID];
        }
        
        if (IS_NOT_EMPTY_NSSTRING(self.conversationData.conversationID)) {
            conversationID = self.conversationData.conversationID;
        }
        if (conversationID.length > 0) {
            [TDeskMessageDataProvider markConversationAsUndead:@[ conversationID ] enableMark:NO];
        }
    }
}

/**
 * When the receiver sends a visible message read receipt:
 * 1. The time when messageVC is visible.  You will be notified when [self viewDidAppear:] is invoked
 * 2. The time when scrollview scrolled to bottom by called [self scrollToBottom:] (For example, click the "x new message" tips in the lower right corner). You
 * will be notified when  [UIScrollViewDelegate scrollViewDidEndScrollingAnimation:]  is invoked.
 *   + Note that you need to use the state of the scrollView to accurately determine whether the scrollView has really stopped sliding.
 * 3. The time when the user drags the scrollView continuously to view the message. You will be notified when [UIScrollViewDelegate scrollViewDidScroll:]  is
 * invoked.
 *   + Note here to determine whether the scrolling of the scrollView is triggered by user gestures (rather than automatic code triggers). So use the
 * self.scrollingTriggeredByUser flag to distinguish.
 *   + The update logic of self.scrollingTriggeredByUser is as follows:
 *     - Set YES when the user's finger touches the screen and starts to drag (scrollViewWillBeginDragging:);
 *     - When the user's finger drags at a certain acceleration and leaves the screen, when the screen automatically stops sliding
 * (scrollViewDidEndDecelerating:), set to NO;
 *     - No acceleration is applied after the user's finger slides, and when the user lifts the finger directly (scrollViewDidEndDragging:), set NO.
 * 4. When the user stays in the latest message interface and receives a new message at this time. Get notified in [self dataProvider:ReceiveNewUIMsg:] .
 */
- (void)sendVisibleReadGroupMessages {
    if (self.isInVC && self.isActive) {
        NSRange range = [self calcVisibleCellRange];
        [self.messageDataProvider sendMessageReadReceiptAtIndexes:[self transferIndexFromRange:range]];
    }
}

- (NSRange)calcVisibleCellRange {
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    if (indexPaths.count == 0) {
        return NSMakeRange(0, 0);
    }
    NSIndexPath *topmost = indexPaths.firstObject;
    NSIndexPath *downmost = indexPaths.lastObject;
    return NSMakeRange(topmost.row, downmost.row - topmost.row + 1);
}

- (NSArray *)transferIndexFromRange:(NSRange)range {
    NSMutableArray *index = [NSMutableArray array];
    NSInteger start = range.location;
    for (int i = 0; i < range.length; i++) {
        [index addObject:@(start + i)];
    }
    return index;
}

- (void)hideKeyboardIfNeeded {
    [self.view endEditing:YES];
    [TDeskTool.applicationKeywindow endEditing:YES];
}

- (CGFloat)getHeightFromMessageCellData:(TDeskMessageCellData *)cellData {
    return [self.messageCellConfig getHeightFromMessageCellData:cellData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageDataProvider.uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageDataProvider.uiMsgs.count) {
        TDeskMessageCellData *cellData = self.messageDataProvider.uiMsgs[indexPath.row];
        return [self.messageCellConfig getHeightFromMessageCellData:cellData];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageDataProvider.uiMsgs.count) {
        TDeskMessageCellData *cellData = self.messageDataProvider.uiMsgs[indexPath.row];
        return [self.messageCellConfig getEstimatedHeightFromMessageCellData:cellData];
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TDeskMessageCellData *data = self.messageDataProvider.uiMsgs[indexPath.row];
    data.showCheckBox = self.showCheckBox && [self supportCheckBox:data];
    TDeskMessageCell *cell = nil;
    if ([self.delegate respondsToSelector:@selector(messageController:onShowMessageData:)]) {
        cell = [self.delegate messageController:self onShowMessageData:data];
        if (cell) {
            cell.delegate = self;
            return cell;
        }
    }
    
    if (!data.reuseId) {
        NSAssert(NO, @"Unknow cell");
        return nil;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    TDeskMessageCellData *oldData = cell.messageData;
    cell.delegate = self;
    [cell fillWithData:data];
    [cell notifyBottomContainerReadyOfData:oldData];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    TDeskMessageCell *uiMsg = (TDeskMessageCell *)cell;
    if ([uiMsg isKindOfClass:TDeskMessageCell.class] && [self.delegate respondsToSelector:@selector(messageController:willDisplayCell:withData:)]) {
        [self.delegate messageController:self willDisplayCell:uiMsg withData:uiMsg.messageData];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageDataProvider.uiMsgs.count) {
        TDeskTextMessageCellData *cellData = (TDeskTextMessageCellData *)self.messageDataProvider.uiMsgs[indexPath.row];
        // It will be deleted after TUICallKit intervenes according to the standard process.
        if ([cellData isKindOfClass:TDeskTextMessageCellData.class]) {
            if ((cellData.isAudioCall || cellData.isVideoCall) && cellData.showUnreadPoint) {
                cellData.innerMessage.localCustomInt = 1;
                cellData.showUnreadPoint = NO;
            }
        }
        [TDeskCore notifyEvent:TUICore_TUIChatNotify
                              subKey:TUICore_TUIChatNotify_MessageDisplayedSubKey
                              object:cellData
                               param:nil];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollingTriggeredByUser) {
        // only if the scrollView is dragged by user's finger to scroll, we need to send read receipts.
        [self sendVisibleReadGroupMessages];
        self.isAutoScrolledToBottom = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrollingTriggeredByUser = YES;
    [self didTapViewController];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self isScrollViewEndDragging:scrollView]) {
        // user presses on the scrolling scrollView and forces it to stop scrolling immediately.
        self.scrollingTriggeredByUser = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self isScrollViewEndDecelerating:scrollView]) {
        // user drags the scrollView with a certain acceleration and makes a flick gesture, and scrollView will stop scrolling after decelerating.
        self.scrollingTriggeredByUser = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self isScrollViewEndDecelerating:scrollView]) {
        // UIScrollView automatically stops scrolling, for example triggered after calling scrollToBottom
        [self sendVisibleReadGroupMessages];
    }
}

- (BOOL)isScrollViewEndDecelerating:(UIScrollView *)scrollView {
    return scrollView.tracking == 0 && scrollView.dragging == 0 && scrollView.decelerating == 0;
}

- (BOOL)isScrollViewEndDragging:(UIScrollView *)scrollView {
    return scrollView.tracking == 1 && scrollView.dragging == 0 && scrollView.decelerating == 0;
}

#pragma mark - TDeskMessageCellDelegate

- (void)onSelectMessage:(TDeskMessageCell *)cell {
    
    if (TDeskChatConfig.defaultConfig.eventConfig.chatEventListener &&
        [TDeskChatConfig.defaultConfig.eventConfig.chatEventListener respondsToSelector:@selector(onMessageClicked:messageCellData:)]) {
        BOOL result = [TDeskChatConfig.defaultConfig.eventConfig.chatEventListener onMessageClicked:cell messageCellData:cell.messageData];
        if (result) {
            return;
        }
    }

    if (cell.messageData.innerMessage.hasRiskContent) {
        if (![cell isKindOfClass:[TDeskReferenceMessageCell class]]) {
            return;
        }
    }
    if (self.showCheckBox && [self supportCheckBox:(TDeskMessageCellData *)cell.data]) {
        TDeskMessageCellData *data = (TDeskMessageCellData *)cell.data;
        data.selected = !data.selected;
        [self.tableView reloadData];
        return;
    }
    
    if ([TDeskMessageCellConfig isPluginCustomMessageCellData:cell.messageData]) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        if (cell) {
            param[TUICore_TUIPluginNotify_PluginCustomCellClick_Cell] = cell;
        }
        if (self.navigationController) {
            param[TUICore_TUIPluginNotify_PluginCustomCellClick_PushVC] = self.navigationController;
        }
        if (cell.pluginMsgSelectCallback) {
            cell.pluginMsgSelectCallback(param);
        }
    } else if ([cell isKindOfClass:[TDeskTextMessageCell class]]) {
        [self clickTextMessage:(TDeskTextMessageCell *)cell];
    } else if ([cell isKindOfClass:[TDeskSystemMessageCell class]]) {
        [self clickSystemMessage:(TDeskSystemMessageCell *)cell];
    } else if ([cell isKindOfClass:[TDeskVoiceMessageCell class]]) {
        [self playVoiceMessage:(TDeskVoiceMessageCell *)cell];
    } else if ([cell isKindOfClass:[TDeskImageMessageCell class]]) {
        [self showImageMessage:(TDeskImageMessageCell *)cell];
    } else if ([cell isKindOfClass:[TDeskVideoMessageCell class]]) {
        [self showVideoMessage:(TDeskVideoMessageCell *)cell];
    } else if ([cell isKindOfClass:[TDeskIFileMessageCell class]]) {
        [self showFileMessage:(TDeskIFileMessageCell *)cell];
    } else if ([cell isKindOfClass:[TDeskMergeMessageCell class]]) {
        [self showRelayMessage:(TDeskMergeMessageCell *)cell];
    } else if ([cell isKindOfClass:[TDeskLinkCell class]]) {
        [self showLinkMessage:(TDeskLinkCell *)cell];
    } else if ([cell isKindOfClass:TDeskReplyMessageCell.class]) {
        [self showReplyMessage:(TDeskReplyMessageCell *)cell];
    } else if ([cell isKindOfClass:TDeskReferenceMessageCell.class]) {
        [self showReplyMessage:(TDeskReplyMessageCell *)cell];
    } else if ([cell isKindOfClass:TDeskOrderCell.class]) {
        [self showOrderMessage:(TDeskOrderCell *)cell];
    }
    
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:self onSelectMessageContent:cell];
    }
}

- (void)onLongPressMessage:(TDeskMessageCell *)cell {
    if (TDeskChatConfig.defaultConfig.eventConfig.chatEventListener &&
        [TDeskChatConfig.defaultConfig.eventConfig.chatEventListener respondsToSelector:@selector(onMessageLongClicked:messageCellData:)]) {
        BOOL result = [TDeskChatConfig.defaultConfig.eventConfig.chatEventListener onMessageLongClicked:cell messageCellData:cell.messageData];
        if (result) {
            return;
        }
    }
    
    [UIApplication.sharedApplication.keyWindow endEditing:NO];
    TDeskMessageCellData *data = cell.messageData;
    if (![data canLongPress]) {
        return;
    }
    if ([data isKindOfClass:[TDeskSystemMessageCellData class]]) {
        return;
    }
    
    self.menuUIMsg = data;
    
    __weak typeof(self) weakSelf = self;
    TDeskChatPopMenu *menu = [[TDeskChatPopMenu alloc] initWithEmojiView:YES frame:CGRectZero];
    menu.targetCellData = data;
    __weak typeof(menu) weakMenu = menu;
    BOOL isPluginCustomMessage = [TDeskMessageCellConfig isPluginCustomMessageCellData:data];
    BOOL isChatNoramlMessageOrCustomMessage = !isPluginCustomMessage;
    
    // Insert Action
    if (isChatNoramlMessageOrCustomMessage) {
        // Chat common Action
        [self addChatCommonActionToCell:cell ofMenu:menu];
    } else {
        // Plugin common Action
        // （multiAction） （quoteAction） （referenceAction） (deleteAction) (recallAction)
        [self addChatPluginCommonActionToCell:cell ofMenu:menu];
    }
    
    // Actions from extension
    [self addExtensionActionToCell:cell ofMenu:menu];
    
    if ([data isKindOfClass:[TDeskTextMessageCellData class]]) {
        /**
         *  becomeFirstResponder ，，。
         * When the text message is selected, it will becomeFirstResponder by default, causing the keyboard to disappear and the interface to be chaotic. Here,
         * the keyboard that has popped up is put away first.
         */
        TDeskTextMessageCell *textCell = (TDeskTextMessageCell *)cell;
        [textCell.textView becomeFirstResponder];
    } else if ([data isKindOfClass:[TDeskReferenceMessageCellData class]]) {
        TDeskReferenceMessageCell *referenceCell = (TDeskReferenceMessageCell *)cell;
        [referenceCell.textView becomeFirstResponder];
    }
    
    BOOL isFirstResponder = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:willShowMenuInCell:)]) {
        isFirstResponder = [_delegate messageController:self willShowMenuInCell:cell];
    }
    if (isFirstResponder) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    } else {
        [self becomeFirstResponder];
    }
    
    CGRect frame = [UIApplication.sharedApplication.keyWindow convertRect:cell.container.frame fromView:cell];
    
    CGFloat topMarginiByCustomView = 0;
    
//    if (_delegate && [_delegate respondsToSelector:@selector(getTopMarginByCustomView)]) {
//        topMarginiByCustomView = [_delegate getTopMarginByCustomView];
//    }
    
    [menu setArrawPosition:CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y - 5 - topMarginiByCustomView)
              adjustHeight:frame.size.height + 5];
    [menu showInView:self.tableView];
    
    [self configSelectActionToCell:cell ofMenu:menu];
}

- (void)addChatCommonActionToCell:(TDeskMessageCell *)cell ofMenu:(TDeskChatPopMenu *)menu {
    // Setup popAction
    TDeskChatPopMenuAction *copyAction = [self setupCopyAction:cell];
    TDeskChatPopMenuAction *deleteAction = [self setupDeleteAction:cell];
    TDeskChatPopMenuAction *recallAction = [self setupRecallAction:cell];
    TDeskChatPopMenuAction *multiAction = [self setupMulitSelectAction:cell];
    TDeskChatPopMenuAction *forwardAction = [self setupForwardAction:cell];
    TDeskChatPopMenuAction *quoteAction = [self setupQuoteAction:cell];
    TDeskChatPopMenuAction *referenceAction = [self setupReferenceAction:cell];
    TDeskChatPopMenuAction *audioPlaybackStyleAction = [self setupAudioPlaybackStyleAction:cell];
    TDeskChatPopMenuAction *groupPinAction = [self setupGroupPinAction:cell];
    
    TDeskMessageCellData *data = cell.messageData;
    V2TIMMessage *imMsg = data.innerMessage;
    
    if (imMsg.soundElem) {
        [menu addAction:audioPlaybackStyleAction];
    }
    if ([data isKindOfClass:[TDeskTextMessageCellData class]] || [data isKindOfClass:TDeskReplyMessageCellData.class] ||
        [data isKindOfClass:TDeskReferenceMessageCellData.class]) {
        [menu addAction:copyAction];
    }
    [menu addAction:deleteAction];
//    [menu addAction:multiAction];
    if (imMsg) {
        if ([imMsg isSelf] && [[NSDate date] timeIntervalSinceDate:imMsg.timestamp] < TDeskChatConfig.defaultConfig.timeIntervalForMessageRecall &&
            (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC)) {
            [menu addAction:recallAction];
        }
    }
//    if ([self canForward:data] && imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC && !imMsg.hasRiskContent) {
//        [menu addAction:forwardAction];
//    }
    if (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC && [TDeskChatConfig defaultConfig].enablePopMenuReplyAction) {
        [menu addAction:quoteAction];
    }
    if (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC && [TDeskChatConfig defaultConfig].enablePopMenuReferenceAction) {
        [menu addAction:referenceAction];
    }
    BOOL isGroup = (data.innerMessage.groupID.length > 0);
    if (isGroup && [self.messageDataProvider isCurrentUserRoleSuperAdminInGroup] && 
        (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC) ) {
        [menu addAction:groupPinAction];
    }
}

- (void)addChatPluginCommonActionToCell:(TDeskMessageCell *)cell ofMenu:(TDeskChatPopMenu *)menu {
    // Setup popAction
    TDeskChatPopMenuAction *deleteAction = [self setupDeleteAction:cell];
    TDeskChatPopMenuAction *recallAction = [self setupRecallAction:cell];
    TDeskChatPopMenuAction *multiAction = [self setupMulitSelectAction:cell];
    TDeskChatPopMenuAction *quoteAction = [self setupQuoteAction:cell];
    TDeskChatPopMenuAction *referenceAction = [self setupReferenceAction:cell];

    TDeskMessageCellData *data = cell.messageData;
    V2TIMMessage *imMsg = data.innerMessage;

//    [menu addAction:multiAction];

    if (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC && [TDeskChatConfig defaultConfig].enablePopMenuReplyAction) {
        [menu addAction:quoteAction];
    }
    if (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC && [TDeskChatConfig defaultConfig].enablePopMenuReferenceAction) {
        [menu addAction:referenceAction];
    }

//    [menu addAction:deleteAction];

//    if (imMsg && [imMsg isSelf] && [[NSDate date] timeIntervalSinceDate:imMsg.timestamp] < TDeskChatConfig.defaultConfig.timeIntervalForMessageRecall &&
//        (imMsg.status == V2TIM_MSG_STATUS_SEND_SUCC)) {
//        [menu addAction:recallAction];
//    }
}
- (void)addExtensionActionToCell:(TDeskMessageCell *)cell ofMenu:(TDeskChatPopMenu *)menu {
    // extra
    NSArray<TUIExtensionInfo *> *infoArray =
        [TDeskCore getExtensionList:TUICore_TUIChatExtension_PopMenuActionItem_ClassicExtensionID
                            param:@{TUICore_TUIChatExtension_PopMenuActionItem_TargetVC : self, TUICore_TUIChatExtension_PopMenuActionItem_ClickCell : cell}];
    for (TUIExtensionInfo *info in infoArray) {
        if (info.text && info.icon && info.onClicked) {
            TDeskChatPopMenuAction *extension = [[TDeskChatPopMenuAction alloc] initWithTitle:info.text
                                                                                    image:info.icon
                                                                                   weight:info.weight
                                                                                 callback:^{
                                                                                   info.onClicked(@{});
                                                                                 }];
            [menu addAction:extension];
        }
    }
}

- (void)configSelectActionToCell:(TDeskMessageCell *)cell ofMenu:(TDeskChatPopMenu *)menu {
    
    // Setup popAction
    TDeskChatPopMenuAction *copyAction = [self setupCopyAction:cell];
    TDeskChatPopMenuAction *deleteAction = [self setupDeleteAction:cell];
    TDeskChatPopMenuAction *multiAction = [self setupMulitSelectAction:cell];
    TDeskChatPopMenuAction *forwardAction = [self setupForwardAction:cell];
    TDeskChatPopMenuAction *quoteAction = [self setupQuoteAction:cell];
    TDeskChatPopMenuAction *referenceAction = [self setupReferenceAction:cell];
    TDeskChatPopMenuAction *groupPinAction = [self setupGroupPinAction:cell];
    
    TDeskMessageCellData *data = cell.messageData;
    BOOL isGroup = (data.innerMessage.groupID.length > 0);
    //Chat common Action special operator
    @weakify(self);
    @weakify(cell);
    @weakify(menu);
    __block BOOL isSelectAll = YES;
    void (^selectAllContentCallback)(BOOL) = ^(BOOL selectAll) {
      @strongify(self);
      @strongify(cell);
      @strongify(menu);
      if (isSelectAll == selectAll) {
          return;
      }
      isSelectAll = selectAll;
      [menu removeAllAction];
      if (isSelectAll) {
          [menu addAction:copyAction];
          [menu addAction:deleteAction];
//          [menu addAction:multiAction];
          if ([self canForward:data]) {
              [menu addAction:forwardAction];
          }
          if ([TDeskChatConfig defaultConfig].enablePopMenuReplyAction) {
              [menu addAction:quoteAction];
          }
          if ([TDeskChatConfig defaultConfig].enablePopMenuReferenceAction) {
              [menu addAction:referenceAction];
          }
          if (isGroup && [self.messageDataProvider isCurrentUserRoleSuperAdminInGroup]) {
              [menu addAction:groupPinAction];
          }
          
      } else {
          [menu addAction:copyAction];
          if ([self canForward:data]) {
              [menu addAction:forwardAction];
          }
      }
      // Select all or not may affect the action menu
      [self addExtensionActionToCell:cell ofMenu:menu];
      [menu layoutSubview];
    };
    /**
     * If it is a text type message, set the text message cursor selected state, if the text is not all selected state, only keep copy and forward
     */
    if ([data isKindOfClass:[TDeskTextMessageCellData class]]) {
        TDeskTextMessageCell *textCell = (TDeskTextMessageCell *)cell;
        [textCell.textView selectAll:self];
        textCell.selectAllContentContent = selectAllContentCallback;
        menu.hideCallback = ^{
          [textCell.textView setSelectedTextRange:nil];
        };
    }
    if ([data isKindOfClass:[TDeskReferenceMessageCellData class]] || [data isKindOfClass:[TDeskReplyMessageCellData class]]) {
        TDeskReplyMessageCell *textCell = (TDeskReplyMessageCell *)cell;
        [textCell.textView selectAll:self];
        textCell.selectAllContentContent = selectAllContentCallback;
        menu.hideCallback = ^{
          [textCell.textView setSelectedTextRange:nil];
        };
    };
}
- (TDeskChatPopMenuAction *)setupCopyAction:(TDeskMessageCell *)cell {
    TDeskChatPopMenuAction *copyAction = nil;
    @weakify(self);
    @weakify(cell);
    copyAction = [[TDeskChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Copy)
                                                       image:TUIChatBundleThemeImage(@"chat_icon_copy_img", @"icon_copy")
                                                      weight:10000
                                                    callback:^{
                                                      @strongify(self);
                                                      @strongify(cell);
                                                      [self onCopyMsg:cell];
                                                    }];
    return copyAction;
}
- (TDeskChatPopMenuAction *)setupDeleteAction:(TDeskMessageCell *)cell {
    @weakify(self);
    TDeskChatPopMenuAction *deleteAction = [[TDeskChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Delete)
                                                                               image:TUIChatBundleThemeImage(@"chat_icon_delete_img", @"icon_delete")
                                                                              weight:3000
                                                                            callback:^{
                                                                              @strongify(self);
                                                                              [self onDelete:nil];
                                                                            }];
    return deleteAction;
}

- (TDeskChatPopMenuAction *)setupRecallAction:(TDeskMessageCell *)cell {
    TDeskChatPopMenuAction *recallAction = nil;
    TDeskMessageCellData *data = cell.messageData;
    V2TIMMessage *imMsg = data.innerMessage;
    @weakify(self);
    recallAction = [[TDeskChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Revoke)
                                                         image:TUIChatBundleThemeImage(@"chat_icon_recall_img", @"icon_recall")
                                                        weight:4000
                                                      callback:^{
                                                        @strongify(self);
                                                        [self onRevoke:nil];
                                                      }];

    return recallAction;
}
- (TDeskChatPopMenuAction *)setupMulitSelectAction:(TDeskMessageCell *)cell {
    @weakify(self);
    TDeskChatPopMenuAction *multiAction = nil;
    multiAction = [[TDeskChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Multiple)
                                                        image:TUIChatBundleThemeImage(@"chat_icon_multi_img", @"icon_multi")
                                                       weight:8000
                                                     callback:^{
                                                       @strongify(self);
                                                       [self onMulitSelect:nil];
                                                     }];

    return multiAction;
}

- (TDeskChatPopMenuAction *)setupForwardAction:(TDeskMessageCell *)cell {
    @weakify(self);
    TDeskChatPopMenuAction *forwardAction = nil;
    forwardAction = [[TDeskChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Forward)
                                                          image:TUIChatBundleThemeImage(@"chat_icon_forward_img", @"icon_forward")
                                                         weight:9000
                                                       callback:^{
                                                         @strongify(self);
                                                         [self onForward:nil];
                                                       }];
    return forwardAction;
}

- (TDeskChatPopMenuAction *)setupQuoteAction:(TDeskMessageCell *)cell {
    @weakify(self);
    TDeskChatPopMenuAction *quoteAction = nil;
    quoteAction = [[TDeskChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(Reply)
                                                        image:TUIChatBundleThemeImage(@"chat_icon_reply_img", @"icon_reply")
                                                       weight:5000
                                                     callback:^{
                                                       @strongify(self);
                                                       [self onReply:nil];
                                                     }];
    return quoteAction;
}

- (TDeskChatPopMenuAction *)setupReferenceAction:(TDeskMessageCell *)cell {
    @weakify(self);
    TDeskChatPopMenuAction *referenceAction = nil;
    referenceAction = [[TDeskChatPopMenuAction alloc] initWithTitle:TIMCommonLocalizableString(TUIKitReference)
                                                            image:TUIChatBundleThemeImage(@"chat_icon_reference_img", @"icon_reference")
                                                           weight:7000
                                                         callback:^{
                                                           @strongify(self);
                                                           [self onReference:nil];
                                                         }];
    return referenceAction;
}

- (TDeskChatPopMenuAction *)setupAudioPlaybackStyleAction:(TDeskMessageCell *)cell {
    @weakify(self);
    TDeskChatPopMenuAction *audioPlaybackStyleAction = nil;
    __weak typeof(audioPlaybackStyleAction)  weakAction = audioPlaybackStyleAction;
    TUIVoiceAudioPlaybackStyle originStyle = [TDeskVoiceMessageCellData getAudioplaybackStyle];
    NSString *title = @"";
    UIImage *img = nil;
    if (originStyle == TUIVoiceAudioPlaybackStyleLoudspeaker) {
        title = TIMCommonLocalizableString(TUIKitAudioPlaybackStyleHandset);
        img   = TUIChatBundleThemeImage(@"chat_icon_audio_handset_img", @"icon_handset");
    }
    else {
        title = TIMCommonLocalizableString(TUIKitAudioPlaybackStyleLoudspeaker);
        img   = TUIChatBundleThemeImage(@"chat_icon_audio_loudspeaker_img", @"icon_loudspeaker");
    }
    
    audioPlaybackStyleAction = [[TDeskChatPopMenuAction alloc] initWithTitle:title
                                                            image:img
                                                           weight:11000
                                                         callback:^{
        if (originStyle == TUIVoiceAudioPlaybackStyleLoudspeaker) {
            //Change To Handset
            weakAction.title = TIMCommonLocalizableString(TUIKitAudioPlaybackStyleLoudspeaker);
            [TDeskTool hideToast];
            [TDeskTool makeToast:TIMCommonLocalizableString(TUIKitAudioPlaybackStyleChange2Handset) duration:2];
        }
        else {
            weakAction.title = TIMCommonLocalizableString(TUIKitAudioPlaybackStyleHandset);
            [TDeskTool hideToast];
            [TDeskTool makeToast:TIMCommonLocalizableString(TUIKitAudioPlaybackStyleChange2Loudspeaker) duration:2];
        }
        [TDeskVoiceMessageCellData changeAudioPlaybackStyle];

    }];
    return audioPlaybackStyleAction;
}
- (TDeskChatPopMenuAction *)setupGroupPinAction:(TDeskMessageCell *)cell {
    @weakify(self);
    BOOL isPinned = [self.messageDataProvider isCurrentMessagePin:self.menuUIMsg.innerMessage.msgID];
    TDeskChatPopMenuAction *groupPinAction = nil;
    UIImage* img =
    isPinned ? TUIChatBundleThemeImage(@"chat_icon_group_unpin_img", @"icon_unpin") : TUIChatBundleThemeImage(@"chat_icon_group_pin_img", @"icon_pin");
    groupPinAction = [[TDeskChatPopMenuAction alloc] initWithTitle:isPinned?
                      TIMCommonLocalizableString(TUIKitGroupMessageUnPin) : TIMCommonLocalizableString(TUIKitGroupMessagePin)
                                                            image:img
                                                           weight:2900
                                                         callback:^{
                                                           @strongify(self);
                                                           [self onGroupPin:nil currentStatus:isPinned];
                                                         }];
    return groupPinAction;
}
- (BOOL)canForward:(TDeskMessageCellData *)data {
    return ![TDeskMessageCellConfig isPluginCustomMessageCellData:data];
}

- (void)onLongSelectMessageAvatar:(TDeskMessageCell *)cell {    
    if (TDeskChatConfig.defaultConfig.eventConfig.chatEventListener &&
    [TDeskChatConfig.defaultConfig.eventConfig.chatEventListener respondsToSelector:@selector(onUserIconLongClicked:messageCellData:)]) {
        BOOL result = [TDeskChatConfig.defaultConfig.eventConfig.chatEventListener onUserIconLongClicked:cell messageCellData:cell.messageData];
        if (result) {
            return;
        }
    }

    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onLongSelectMessageAvatar:)]) {
        [_delegate messageController:self onLongSelectMessageAvatar:cell];
    }
}

- (void)onRetryMessage:(TDeskMessageCell *)cell {
    BOOL hasRiskContent = cell.messageData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        return;
    }
    _reSendUIMsg = cell.messageData;
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitTipsConfirmResendMessage)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Re_send)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *_Nonnull action) {
                                                       [weakSelf sendUIMessage:weakSelf.reSendUIMsg];
                                                     }]];
    [alert tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel)
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction *_Nonnull action){

                                                     }]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)onSelectMessageAvatar:(TDeskMessageCell *)cell {
    if (TDeskChatConfig.defaultConfig.eventConfig.chatEventListener &&
        [TDeskChatConfig.defaultConfig.eventConfig.chatEventListener respondsToSelector:@selector(onUserIconClicked:messageCellData:)]) {
       BOOL result = [TDeskChatConfig.defaultConfig.eventConfig.chatEventListener onUserIconClicked:cell messageCellData:cell.messageData];
        if (result) {
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageAvatar:)]) {
        [self.delegate messageController:self onSelectMessageAvatar:cell];
    }
}

- (void)onSelectReadReceipt:(TDeskMessageCellData *)data {
    @weakify(self);
    if (data.innerMessage.groupID.length > 0) {
        // Navigate to group message read VC. Should get members first.
        [TDeskMessageDataProvider getMessageReadReceipt:@[ data.innerMessage ]
            succ:^(NSArray<V2TIMMessageReceipt *> *receiptList) {
              @strongify(self);
              if (receiptList.count == 0) {
                  return;
              }
              // To avoid the labels in messageReadVC displaying all 0 which is not accurate, try to get message read count before navigation.
              V2TIMMessageReceipt *receipt = receiptList.firstObject;
              data.messageReceipt = receipt;
              [self pushMessageReadViewController:data];
            }
            fail:^(int code, NSString *desc) {
              @strongify(self);
              [self pushMessageReadViewController:data];
            }];
    } else {
        // navigate to c2c message read VC. No need to get member.
        [self pushMessageReadViewController:data];
    }
}

- (void)pushMessageReadViewController:(TDeskMessageCellData *)data {
    self.hasCoverPage = YES;
    TDeskMessageReadViewController *controller = [[TDeskMessageReadViewController alloc] initWithCellData:data
                                                                                         dataProvider:self.messageDataProvider
                                                                                showReadStatusDisable:NO
                                                                                      c2cReceiverName:self.conversationData.title
                                                                                    c2cReceiverAvatar:self.conversationData.faceUrl];
    [self.navigationController pushViewController:controller animated:YES];
    __weak typeof(self) weakSelf = self;
    controller.viewWillDismissHandler = ^{
        weakSelf.hasCoverPage = NO;
    };
}

- (void)onJumpToRepliesDetailPage:(TDeskMessageCellData *)data {
    self.hasCoverPage = YES;
    TDeskRepliesDetailViewController *repliesDetailVC = [[TDeskRepliesDetailViewController alloc] initWithCellData:data conversationData:self.conversationData];
    repliesDetailVC.delegate = self.delegate;
    [self.navigationController pushViewController:repliesDetailVC animated:YES];
    repliesDetailVC.parentPageDataProvider = self.messageDataProvider;
    __weak typeof(self) weakSelf = self;
    repliesDetailVC.willCloseCallback = ^() {
      [weakSelf.tableView reloadData];
      weakSelf.hasCoverPage = NO;
    };
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(onDelete:) || action == @selector(onRevoke:) || action == @selector(onReSend:) || action == @selector(onCopyMsg:) ||
        action == @selector(onMulitSelect:) || action == @selector(onForward:) || action == @selector(onReply:)) {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)buildMenuWithBuilder:(id<UIMenuBuilder>)builder API_AVAILABLE(ios(13.0)) {
    if (@available(iOS 16.0, *)) {
        [builder removeMenuForIdentifier:UIMenuLookup];
    }
    [super buildMenuWithBuilder:builder];
}

- (void)onDelete:(id)sender {
    @weakify(self);
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil
                                                                message:TIMCommonLocalizableString(ConfirmDeleteMessage)
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Delete)
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                    @strongify(self);
                                                    [self.messageDataProvider deleteUIMsgs:@[ self.menuUIMsg ]
                                                                                 SuccBlock:nil
                                                                                 FailBlock:^(int code, NSString *desc) {
                                                                                   NSLog(@"remove msg failed!");
                                                                                   NSAssert(NO, desc);
                                                                                 }];
                                                  }]];
    [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)menuDidHide:(NSNotification *)notification {
    if (_delegate && [_delegate respondsToSelector:@selector(didHideMenuInMessageController:)]) {
        [_delegate didHideMenuInMessageController:self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)onCopyMsg:(id)sender {
    NSString *content = @"";
    /**
     * 
     * The text message should be based on the content of the message actually selected by the cursor
     */
    if ([sender isKindOfClass:[TDeskTextMessageCell class]]) {
        TDeskTextMessageCell *txtCell = (TDeskTextMessageCell *)sender;
        content = txtCell.selectContent;
    }
    if ([sender isKindOfClass:TDeskReplyMessageCell.class] || [sender isKindOfClass:TDeskReferenceMessageCell.class]) {
        TDeskReplyMessageCellData *replyMsg = (TDeskReplyMessageCellData *)sender;
        content = replyMsg.selectContent;
    }
    if (content.length > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = content;
        [TDeskTool makeToast:TIMCommonLocalizableString(Copied)];
    }
}

- (void)onRevoke:(id)sender {
    @weakify(self);
    [self.messageDataProvider revokeUIMsg:self.menuUIMsg
        SuccBlock:^{
          @strongify(self);
          if (self.delegate && [self.delegate respondsToSelector:@selector(didHideMenuInMessageController:)]) {
              [self.delegate didHideMenuInMessageController:self];
          }
        }
        FailBlock:^(int code, NSString *desc) {
          NSAssert(NO, desc);
        }];
}

- (void)onReSend:(id)sender {
    [self sendUIMessage:_menuUIMsg];
}

- (void)onMulitSelect:(id)sender {
    [self enableMultiSelectedMode:YES];
    if (self.menuUIMsg.innerMessage.hasRiskContent) {
        if (_delegate && [_delegate respondsToSelector:@selector(messageController:onSelectMessageMenu:withData:)]) {
            [_delegate messageController:self onSelectMessageMenu:0 withData:nil];
        }
        return;
    }
    self.menuUIMsg.selected = YES;
    [self.tableView beginUpdates];
    NSInteger index = [self.messageDataProvider.uiMsgs indexOfObject:self.menuUIMsg];
    [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];

    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onSelectMessageMenu:withData:)]) {
        [_delegate messageController:self onSelectMessageMenu:0 withData:_menuUIMsg];
    }
}

- (void)onForward:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onSelectMessageMenu:withData:)]) {
        [_delegate messageController:self onSelectMessageMenu:1 withData:_menuUIMsg];
    }
}

- (void)onReply:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onRelyMessage:)]) {
        [_delegate messageController:self onRelyMessage:self.menuUIMsg];
    }
}

- (void)onReference:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(messageController:onReferenceMessage:)]) {
        [_delegate messageController:self onReferenceMessage:self.menuUIMsg];
    }
}

- (void)onGroupPin:(id)sender currentStatus:(BOOL)currentStatus {
    NSString *groupId =  self.conversationData.groupID;
    BOOL isPinned = currentStatus;
    BOOL pinOrUnpin = !isPinned;
    
    [self.messageDataProvider pinGroupMessage:groupId message:self.menuUIMsg.innerMessage isPinned:pinOrUnpin succ:^{

    } fail:^(int code, NSString *desc) {
        if (code == 10070) {
            [TDeskTool makeToast:TIMCommonLocalizableString(TUIKitGroupMessagePinOverLimit)];
        }
        else if (code == 10004) {
            if (pinOrUnpin) {
                [TDeskTool makeToast:TIMCommonLocalizableString(TUIKitGroupMessagePinRepeatedly)];
            }
            else {
                [TDeskTool makeToast:TIMCommonLocalizableString(TUIKitGroupMessageUnPinRepeatedly)];
            }
        }
    }];
}



- (BOOL)supportCheckBox:(TDeskMessageCellData *)data {
    if ([data isKindOfClass:TDeskSystemMessageCellData.class]) {
        return NO;
    }
    return YES;
}

- (BOOL)supportRelay:(TDeskMessageCellData *)data {
    if ([data isKindOfClass:TDeskVoiceMessageCellData.class]) {
        return NO;
    }
    return YES;
}

- (void)enableMultiSelectedMode:(BOOL)enable {
    self.showCheckBox = enable;
    if (!enable) {
        for (TDeskMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
            cellData.selected = NO;
        }
    }
    [self.tableView reloadData];
}

- (NSArray<TDeskMessageCellData *> *)multiSelectedResult:(TUIMultiResultOption)option {
    NSMutableArray *arrayM = [NSMutableArray array];
    if (!self.showCheckBox) {
        return [NSArray arrayWithArray:arrayM];
    }
    BOOL filterUnsupported = option & TUIMultiResultOptionFiterUnsupportRelay;
    for (TDeskMessageCellData *data in self.messageDataProvider.uiMsgs) {
        if (data.selected) {
            if (filterUnsupported && ![self supportRelay:data]) {
                continue;
            }
            [arrayM addObject:data];
        }
    }
    return [NSArray arrayWithArray:arrayM];
}

- (void)deleteMessages:(NSArray<TDeskMessageCellData *> *)uiMsgs {
    if (uiMsgs.count == 0 || uiMsgs.count > 30) {
        NSLog(@"The size of messages must be between 0 and 30");
        return;
    }
    [self.messageDataProvider deleteUIMsgs:uiMsgs
                                 SuccBlock:nil
                                 FailBlock:^(int code, NSString *desc) {
                                   NSLog(@"deleteMessages failed!");
                                   NSAssert(NO, desc);
                                 }];
}

- (void)clickTextMessage:(TDeskTextMessageCell *)cell {
    V2TIMMessage *message = cell.messageData.innerMessage;
    if (0 == message.userID.length) {
        return;
    }
    [TDeskMessageDataProvider.callingDataProvider redialFromMessage:message];
}

- (void)clickSystemMessage:(TDeskSystemMessageCell *)cell {
    TDeskSystemMessageCellData *data = (TDeskSystemMessageCellData *)cell.messageData;
    if (data.supportReEdit) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageController:onReEditMessage:)]) {
            [self.delegate messageController:self onReEditMessage:cell.messageData];
        }
    }
}

- (void)playVoiceMessage:(TDeskVoiceMessageCell *)cell {
    for (TDeskMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
        if (![cellData isKindOfClass:[TDeskVoiceMessageCellData class]]) {
            continue;
        }
        TDeskVoiceMessageCellData *voiceMsg = (TDeskVoiceMessageCellData *)cellData;
        if (voiceMsg == cell.voiceData) {
            [voiceMsg playVoiceMessage];
            self.currentVoiceMsg = voiceMsg;
            cell.voiceReadPoint.hidden = YES;
            NSMutableArray *unPlayVoiceMessageAfterSelectVoiceMessage = [self getCurrentUnPlayVoiceMessageAfterSelectVoiceMessage:voiceMsg];
            @weakify(self);
            voiceMsg.audioPlayerDidFinishPlayingBlock = ^{
              @strongify(self);
              if (unPlayVoiceMessageAfterSelectVoiceMessage.count > 0) {
                  TDeskVoiceMessageCellData *nextVoiceCellData = [unPlayVoiceMessageAfterSelectVoiceMessage firstObject];
                  NSIndexPath *nextIndex = [self indexPathOfMessage:nextVoiceCellData.msgID];
                  [self scrollCellToBottomOfMessage:nextVoiceCellData.msgID];
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    TDeskVoiceMessageCell *nextCell = [self.tableView cellForRowAtIndexPath:nextIndex];
                    if (nextCell) {
                        [self playVoiceMessage:nextCell];
                        [unPlayVoiceMessageAfterSelectVoiceMessage removeObject:nextVoiceCellData];
                    } else {
                        // rerty: avoid nextCell is nil
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                          TDeskVoiceMessageCell *retryNextCell = [self.tableView cellForRowAtIndexPath:nextIndex];
                          if (retryNextCell) {
                              [self playVoiceMessage:retryNextCell];
                              [unPlayVoiceMessageAfterSelectVoiceMessage removeObject:nextVoiceCellData];
                          }
                        });
                    }
                  });
              }
            };
        } else {
            [voiceMsg stopVoiceMessage];
        }
    }
}

- (NSMutableArray *)getCurrentUnPlayVoiceMessageAfterSelectVoiceMessage:(TDeskVoiceMessageCellData *)playingCellData {
    NSMutableArray *neverHitsPlayVoiceQueue = [NSMutableArray array];
    for (TDeskMessageCellData *cellData in self.messageDataProvider.uiMsgs) {
        if ([cellData isKindOfClass:[TDeskVoiceMessageCellData class]]) {
            TDeskVoiceMessageCellData *voiceMsg = (TDeskVoiceMessageCellData *)cellData;
            if ((voiceMsg.innerMessage.localCustomInt == 0 && voiceMsg.direction == MsgDirectionIncoming &&
                 [voiceMsg.innerMessage.timestamp timeIntervalSince1970] >= [playingCellData.innerMessage.timestamp timeIntervalSince1970])) {
                if (voiceMsg != playingCellData) {
                    [neverHitsPlayVoiceQueue addObject:voiceMsg];
                }
            }
        }
    }
    return neverHitsPlayVoiceQueue;
}
- (void)showImageMessage:(TDeskImageMessageCell *)cell {
    [self hideKeyboardIfNeeded];
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TDeskMediaView *mediaView = [[TDeskMediaView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage];
    __weak typeof(self) weakSelf = self;
    mediaView.onClose = ^{
      [weakSelf didCloseMediaMessage:cell];
    };
    [self willShowMediaMessage:cell];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)showVideoMessage:(TDeskVideoMessageCell *)cell {
    if (![cell.videoData isVideoExist]) {
        [cell.videoData downloadVideo];
    } else {
        [self hideKeyboardIfNeeded];
        CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
        TDeskMediaView *mediaView = [[TDeskMediaView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
        [mediaView setThumb:cell.thumb frame:frame];
        [mediaView setCurMessage:cell.messageData.innerMessage];
        __weak typeof(self) weakSelf = self;
        mediaView.onClose = ^{
          [weakSelf didCloseMediaMessage:cell];
        };
        [self willShowMediaMessage:cell];
        [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
    }
}

- (void)showFileMessage:(TDeskIFileMessageCell *)cell {
    [self hideKeyboardIfNeeded];
    TDeskFileMessageCellData *fileData = cell.fileData;
    if (![fileData isLocalExist]) {
        [fileData downloadFile];
        return;
    }
    
    TDeskFileViewController *fileVC = [[TDeskFileViewController alloc] init];
    fileVC.data = [cell fileData];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:fileVC];
    [self presentViewController:nav animated:YES completion:nil];

}

- (void)showRelayMessage:(TDeskMergeMessageCell *)cell {
    TDeskMergeMessageListController *mergeVc = [[TDeskMergeMessageListController alloc] init];
    mergeVc.delegate = self.delegate;
    mergeVc.mergerElem = cell.mergeData.mergerElem;
    mergeVc.conversationData = self.conversationData;
    mergeVc.parentPageDataProvider = self.messageDataProvider;
    __weak typeof(self) weakSelf = self;
    mergeVc.willCloseCallback = ^() {
      [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:mergeVc animated:YES];
}

- (void)showLinkMessage:(TDeskLinkCell *)cell {
    TDeskLinkCellData *cellData = cell.customData;
    if (cellData.link) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellData.link]];
    }
}

- (void)showOrderMessage:(TDeskOrderCell *)cell {
    TDeskOrderCellData *cellData = cell.customData;
    if (cellData.link) {
        [TDeskTool openLinkWithURL:[NSURL URLWithString:cellData.link]];
    }
}

- (void)showReplyMessage:(TDeskReplyMessageCell *)cell {
}

- (void)willShowMediaMessage:(TDeskMessageCell *)cell {
}

- (void)didCloseMediaMessage:(TDeskMessageCell *)cell {
}

- (BOOL)isCurrentUserRoleSuperAdminInGroup {
    return [self.messageDataProvider isCurrentUserRoleSuperAdminInGroup];
}

- (BOOL)isCurrentMessagePin:(NSString *)msgID {
    return [self.messageDataProvider isCurrentMessagePin:msgID];
}

- (void)unPinGroupMessage:(V2TIMMessage *)innerMessage {
    NSString *groupId =  self.conversationData.groupID;
    BOOL isPinned = [self.messageDataProvider isCurrentMessagePin:innerMessage.msgID];
    BOOL pinOrUnpin = !isPinned;

    [self.messageDataProvider pinGroupMessage:groupId message:innerMessage isPinned:pinOrUnpin succ:^{
        
    } fail:^(int code, NSString *desc) {
        
    }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (@available(iOS 16.0, *)) {
        // send reloadview
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIMessageMediaViewDeviceOrientationChangeNotification object:nil];
    } else {
        // Fallback on earlier versions
    }
}

@end
