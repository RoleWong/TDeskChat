//
//  TDeskMergeMessageListController.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIMergeMessageListController_Minimalist.h"
#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCommon/TDesk_TUIMessageCellLayout.h>
#import <TDeskCommon/TDesk_TUISystemMessageCell.h>
#import <TDeskCore/TDesk_TUICore.h>
#import <TDeskCore/TDesk_TUIDarkModel.h>
#import <TDeskCore/TDesk_TUIGlobalization.h>
#import <TDeskCore/TDesk_TUIThemeManager.h>
#import "TDesk_TUIFaceMessageCell_Minimalist.h"
#import "TDesk_TUIFileMessageCell_Minimalist.h"
#import "TDesk_TUIFileViewController_Minimalist.h"
#import "TDesk_TUIImageMessageCell_Minimalist.h"
#import "TDesk_TUIJoinGroupMessageCell_Minimalist.h"
#import "TDesk_TUILinkCell_Minimalist.h"
#import "TDesk_TUIMediaView_Minimalist.h"
#import "TDesk_TUIMergeMessageCell_Minimalist.h"
#import "TDesk_TUIMessageDataProvider.h"
#import "TDesk_TUIMessageSearchDataProvider.h"
#import "TDesk_TUIReferenceMessageCell_Minimalist.h"
#import "TDesk_TUIRepliesDetailViewController_Minimalist.h"
#import "TDesk_TUIReplyMessageCellData.h"
#import "TDesk_TUIReplyMessageCell_Minimalist.h"
#import "TDesk_TUITextMessageCell_Minimalist.h"
#import "TDesk_TUIVideoMessageCell_Minimalist.h"
#import "TDesk_TUIVoiceMessageCell_Minimalist.h"
#import "TDesk_TUIMessageCellConfig_Minimalist.h"
#import "TDesk_TUIChatConfig.h"

#define STR(x) @ #x

@interface TUIMergeMessageListController_Minimalist () <TDeskMessageCellDelegate, TDeskMessageBaseDataProviderDataSource,TUINotificationProtocol>
@property(nonatomic, strong) NSArray<V2TIMMessage *> *imMsgs;
@property(nonatomic, strong) NSMutableArray<TDeskMessageCellData *> *uiMsgs;
@property(nonatomic, strong) NSMutableDictionary *stylesCache;
@property(nonatomic, strong) TDeskMessageSearchDataProvider *msgDataProvider;
@property(nonatomic, strong) TUIMessageCellConfig_Minimalist *messageCellConfig;
@end

@implementation TUIMergeMessageListController_Minimalist

- (instancetype)init {
    self = [super init];
    if (self) {
        [TDeskCore registerEvent:TUICore_TUIPluginNotify
                        subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                        object:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _uiMsgs = [[NSMutableArray alloc] init];
    [self loadMessages];
    [self setupViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.willCloseCallback) {
        self.willCloseCallback();
    }
}

- (void)loadMessages {
    @weakify(self);
    [self.mergerElem
        downloadMergerMessage:^(NSArray<V2TIMMessage *> *msgs) {
          @strongify(self);
          self.imMsgs = msgs;
          [self getMessages:self.imMsgs];
        }
                         fail:^(int code, NSString *desc){
                             // to do
                         }];
}

- (void)getMessages:(NSArray *)msgs {
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:msgs];
    @weakify(self);
    [self.msgDataProvider preProcessMessage:uiMsgs
                                   callback:^{
                                     @strongify(self);
                                     @weakify(self);
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                       @strongify(self);
                                       if (uiMsgs.count != 0) {
                                           NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, uiMsgs.count)];
                                           [self.uiMsgs insertObjects:uiMsgs atIndexes:indexSet];
                                           [self.tableView reloadData];
                                           [self.tableView layoutIfNeeded];
                                       }
                                     });
                                   }];
}

- (NSMutableArray *)transUIMsgFromIMMsg:(NSArray *)msgs {
    NSMutableArray *uiMsgs = [NSMutableArray array];
    for (NSInteger k = 0; k < msgs.count; k++) {
        V2TIMMessage *msg = msgs[k];
        if ([self.delegate respondsToSelector:@selector(messageController:onNewMessage:)]) {
            TDeskMessageCellData *data = [self.delegate messageController:nil onNewMessage:msg];
            if (data) {
                TDeskMessageCellLayout *layout = TDeskMessageCellLayout.incommingMessageLayout;
                if ([data isKindOfClass:TDeskTextMessageCellData.class] || [data isKindOfClass:TDeskReferenceMessageCellData.class]) {
                    layout = TDeskMessageCellLayout.incommingTextMessageLayout;
                } else if ([data isKindOfClass:TDeskVoiceMessageCellData.class]) {
                    layout = TDeskMessageCellLayout.incommingVoiceMessageLayout;
                }
                data.cellLayout = layout;
                data.direction = MsgDirectionIncoming;
                data.innerMessage = msg;
                [uiMsgs addObject:data];
                continue;
            }
        }

        TDeskMessageCellData *data = [TDeskMessageDataProvider getCellData:msg];
        if (!data) {
            continue;
        }
        TDeskMessageCellLayout *layout = TDeskMessageCellLayout.incommingMessageLayout;
        if ([data isKindOfClass:TDeskTextMessageCellData.class]) {
            layout = TDeskMessageCellLayout.incommingTextMessageLayout;
        } else if ([data isKindOfClass:TDeskReplyMessageCellData.class] || [data isKindOfClass:TDeskReferenceMessageCellData.class]) {
            layout = TDeskMessageCellLayout.incommingTextMessageLayout;
            TDeskReferenceMessageCellData *textData = (TDeskReferenceMessageCellData *)data;
            textData.textColor = TUIChatDynamicColor(@"chat_text_message_receive_text_color", @"#000000");
            textData.showRevokedOriginMessage = YES;
        } else if ([data isKindOfClass:TDeskVoiceMessageCellData.class]) {
            TDeskVoiceMessageCellData *voiceData = (TDeskVoiceMessageCellData *)data;
            voiceData.cellLayout = [TDeskMessageCellLayout incommingVoiceMessageLayout];
            voiceData.voiceTop = 10;
            msg.localCustomInt = 1;
            layout = TDeskMessageCellLayout.incommingVoiceMessageLayout;
        }
        data.cellLayout = layout;
        data.direction = MsgDirectionIncoming;
        data.innerMessage = msg;
        data.showName = NO;
        [uiMsgs addObject:data];
    }
    for (TDeskMessageCellData *cellData in uiMsgs) {
        [TDeskMessageDataProvider updateUIMsgStatus:cellData uiMsgs:uiMsgs];
    }
    return uiMsgs;
}

- (void)setupViews {
    self.title = TIMCommonLocalizableString(TUIKitRelayChatHistory);
    self.tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    [self.messageCellConfig bindTableView:self.tableView];

    UIImage *image = TIMCommonDynamicImage(@"nav_back_img", [UIImage imageNamed:TIMCommonImagePath(@"nav_back")]);
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    image = [image rtl_imageFlippedForRightToLeftLayoutDirection];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _uiMsgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static CGFloat screenWidth = 0;
    if (screenWidth == 0) {
        screenWidth = Screen_Width;
    }
    if (indexPath.row < self.uiMsgs.count) {
        TDeskMessageCellData *cellData = self.uiMsgs[indexPath.row];
        CGFloat height = [self.messageCellConfig getHeightFromMessageCellData:cellData];
        return height;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TDeskMessageCellData *data = _uiMsgs[indexPath.row];
    data.showCheckBox = NO;
    TDeskMessageCell *cell = nil;
    if ([self.delegate respondsToSelector:@selector(messageController:onShowMessageData:)]) {
        cell = [self.delegate messageController:nil onShowMessageData:data];
        if (cell) {
            cell.delegate = self;
            return cell;
        }
    }
    cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
    cell.delegate = self;
    [cell fillWithData:_uiMsgs[indexPath.row]];
    return cell;
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
    if ([cell isKindOfClass:[TUIImageMessageCell_Minimalist class]]) {
        [self showImageMessage:(TUIImageMessageCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIVoiceMessageCell_Minimalist class]]) {
        [self playVoiceMessage:(TUIVoiceMessageCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIVideoMessageCell_Minimalist class]]) {
        [self showVideoMessage:(TUIVideoMessageCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIFileMessageCell_Minimalist class]]) {
        [self showFileMessage:(TUIFileMessageCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIMergeMessageCell_Minimalist class]]) {
        TUIMergeMessageListController_Minimalist *mergeVc = [[TUIMergeMessageListController_Minimalist alloc] init];
        mergeVc.mergerElem = [(TUIMergeMessageCell_Minimalist *)cell mergeData].mergerElem;
        mergeVc.delegate = self.delegate;
        [self.navigationController pushViewController:mergeVc animated:YES];
    }
    if ([cell isKindOfClass:[TUILinkCell_Minimalist class]]) {
        [self showLinkMessage:(TUILinkCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIReplyMessageCell_Minimalist class]]) {
        [self showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell];
    }
    if ([cell isKindOfClass:[TUIReferenceMessageCell_Minimalist class]]) {
        [self showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell];
    }

    if ([self.delegate respondsToSelector:@selector(messageController:onSelectMessageContent:)]) {
        [self.delegate messageController:nil onSelectMessageContent:cell];
    }
}

- (void)scrollToLocateMessage:(V2TIMMessage *)locateMessage {
    CGFloat offsetY = 0;
    for (TDeskMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.innerMessage.msgID isEqualToString:locateMessage.msgID]) {
            break;
        }
        offsetY += [uiMsg heightOfWidth:Screen_Width];
    }

    offsetY -= self.tableView.frame.size.height / 2.0;
    if (offsetY <= TMessageController_Header_Height) {
        offsetY = TMessageController_Header_Height + 0.1;
    }

    if (offsetY > TMessageController_Header_Height) {
        if (self.tableView.contentOffset.y > offsetY) {
            [self.tableView scrollRectToVisible:CGRectMake(0, offsetY, Screen_Width, self.tableView.bounds.size.height) animated:YES];
        }
    }
}

- (void)highlightKeyword:(NSString *)keyword locateMessage:(V2TIMMessage *)locateMessage {
    TDeskMessageCellData *cellData = nil;
    for (TDeskMessageCellData *tmp in self.uiMsgs) {
        if ([tmp.msgID isEqualToString:locateMessage.msgID]) {
            cellData = tmp;
            break;
        }
    }
    if (cellData == nil) {
        return;
    }

    CGFloat time = 0.5;
    UITableViewRowAnimation animation = UITableViewRowAnimationFade;
    if ([cellData isKindOfClass:TDeskTextMessageCellData.class]) {
        time = 2;
        animation = UITableViewRowAnimationNone;
    }

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
      @strongify(self);
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.uiMsgs indexOfObject:cellData] inSection:0];
      cellData.highlightKeyword = keyword;
      TDeskMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
      [cell fillWithData:cellData];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      @strongify(self);
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.uiMsgs indexOfObject:cellData] inSection:0];
      cellData.highlightKeyword = nil;
      TDeskMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
      [cell fillWithData:cellData];
    });
}
- (void)showReplyMessage:(TUIReplyMessageCell_Minimalist *)cell {
    [UIApplication.sharedApplication.keyWindow endEditing:YES];
    NSString *originMsgID = @"";
    NSString *msgAbstract = @"";
    if ([cell isKindOfClass:TUIReplyMessageCell_Minimalist.class]) {
        TUIReplyMessageCell_Minimalist *acell = (TUIReplyMessageCell_Minimalist *)cell;
        TDeskReplyMessageCellData *cellData = acell.replyData;
        originMsgID = cellData.messageRootID;
        msgAbstract = cellData.msgAbstract;
    } else if ([cell isKindOfClass:TUIReferenceMessageCell_Minimalist.class]) {
        TUIReferenceMessageCell_Minimalist *acell = (TUIReferenceMessageCell_Minimalist *)cell;
        TDeskReferenceMessageCellData *cellData = acell.referenceData;
        originMsgID = cellData.originMsgID;
        msgAbstract = cellData.msgAbstract;
    }
    
    TDeskMessageCellData *originMemoryMessageData = nil;
    for (TDeskMessageCellData *uiMsg in self.uiMsgs) {
        if ([uiMsg.innerMessage.msgID isEqualToString:originMsgID]) {
            originMemoryMessageData = uiMsg;
            break;
        }
    }
    
    if (originMemoryMessageData && [cell isKindOfClass:TUIReplyMessageCell_Minimalist.class]) {
        [self onJumpToRepliesDetailPage:originMemoryMessageData];
    }
    else {
        [(TDeskMessageSearchDataProvider *)self.msgDataProvider
            findMessages:@[ originMsgID ?: @"" ]
                callback:^(BOOL success, NSString *_Nonnull desc, NSArray<V2TIMMessage *> *_Nonnull msgs) {
                  if (!success) {
                      [TDeskTool makeToast:TIMCommonLocalizableString(TUIKitReplyMessageNotFoundOriginMessage)];
                      return;
                  }
                  V2TIMMessage *message = msgs.firstObject;
                  if (message == nil) {
                      [TDeskTool makeToast:TIMCommonLocalizableString(TUIKitReplyMessageNotFoundOriginMessage)];
                      return;
                  }

                  if (message.status == V2TIM_MSG_STATUS_HAS_DELETED || message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
                      [TDeskTool makeToast:TIMCommonLocalizableString(TUIKitReplyMessageNotFoundOriginMessage)];
                      return;
                  }

                  if ([cell isKindOfClass:TUIReplyMessageCell_Minimalist.class]) {
                      [self jumpDetailPageByMessage:message];
                  } else if ([cell isKindOfClass:TUIReferenceMessageCell_Minimalist.class]) {
                      [self scrollToLocateMessage:message];
                  }
                }];

    }
}

- (void)jumpDetailPageByMessage:(V2TIMMessage *)message {
    NSMutableArray *uiMsgs = [self transUIMsgFromIMMsg:@[ message ]];
    [self.msgDataProvider preProcessMessage:uiMsgs
                                   callback:^{
                                     for (TDeskMessageCellData *cellData in uiMsgs) {
                                         if ([cellData.innerMessage.msgID isEqual:message.msgID]) {
                                             [self onJumpToRepliesDetailPage:cellData];
                                             return;
                                         }
                                     }
                                   }];
}

- (void)onJumpToRepliesDetailPage:(TDeskMessageCellData *)data {
    TUIRepliesDetailViewController_Minimalist *repliesDetailVC = [[TUIRepliesDetailViewController_Minimalist alloc] initWithCellData:data
                                                                                                                    conversationData:self.conversationData];
    repliesDetailVC.delegate = self.delegate;
    repliesDetailVC.modalPresentationStyle = UIModalPresentationCustom;
    [self.navigationController presentViewController:repliesDetailVC animated:YES completion:nil];
    repliesDetailVC.parentPageDataProvider = self.parentPageDataProvider;
    __weak typeof(self) weakSelf = self;
    repliesDetailVC.willCloseCallback = ^() {
      [weakSelf.tableView reloadData];
    };
}


- (void)showImageMessage:(TUIImageMessageCell_Minimalist *)cell {
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView_Minimalist *mediaView = [[TUIMediaView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:self.imMsgs];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)playVoiceMessage:(TUIVoiceMessageCell_Minimalist *)cell {
    for (NSInteger index = 0; index < _uiMsgs.count; ++index) {
        if (![_uiMsgs[index] isKindOfClass:[TDeskVoiceMessageCellData class]]) {
            continue;
        }
        TDeskVoiceMessageCellData *uiMsg = (TDeskVoiceMessageCellData *)_uiMsgs[index];
        if (uiMsg == cell.voiceData) {
            [uiMsg playVoiceMessage];
            cell.voiceReadPoint.hidden = YES;
        } else {
            [uiMsg stopVoiceMessage];
        }
    }
}

- (void)showVideoMessage:(TUIVideoMessageCell_Minimalist *)cell {
    CGRect frame = [cell.thumb convertRect:cell.thumb.bounds toView:[UIApplication sharedApplication].delegate.window];
    TUIMediaView_Minimalist *mediaView = [[TUIMediaView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [mediaView setThumb:cell.thumb frame:frame];
    [mediaView setCurMessage:cell.messageData.innerMessage allMessages:self.imMsgs];
    [[UIApplication sharedApplication].keyWindow addSubview:mediaView];
}

- (void)showFileMessage:(TUIFileMessageCell_Minimalist *)cell {
    TDeskFileMessageCellData *fileData = cell.fileData;
    if (![fileData isLocalExist]) {
        [fileData downloadFile];
        return;
    }

    TUIFileViewController_Minimalist *file = [[TUIFileViewController_Minimalist alloc] init];
    file.data = [cell fileData];
    [self.navigationController pushViewController:file animated:YES];
}

- (void)showLinkMessage:(TUILinkCell_Minimalist *)cell {
    TDeskLinkCellData *cellData = cell.customData;
    if (cellData.link) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellData.link]];
    }
}

- (NSMutableDictionary *)stylesCache {
    if (_stylesCache == nil) {
        _stylesCache = [NSMutableDictionary dictionary];
    }
    return _stylesCache;
}

- (UIImage *)bubbleImage {
    CGRect rect = CGRectMake(0, 0, 100, 40);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (TDeskMessageSearchDataProvider *)msgDataProvider {
    if (_msgDataProvider == nil) {
        _msgDataProvider = [[TDeskMessageSearchDataProvider alloc] init];
        _msgDataProvider.dataSource = self;
    }
    return _msgDataProvider;
}

- (TUIMessageCellConfig_Minimalist *)messageCellConfig {
    if (_messageCellConfig == nil) {
        _messageCellConfig = [[TUIMessageCellConfig_Minimalist alloc] init];
    }
    return _messageCellConfig;
}

#pragma mark - TDeskMessageBaseDataProviderDataSource
- (void)dataProviderDataSourceWillChange:(TDeskMessageDataProvider *)dataProvider {
    // do nothing
}

- (void)dataProviderDataSourceChange:(TDeskMessageDataProvider *)dataProvider
                            withType:(TDeskMessageBaseDataProviderDataSourceChangeType)type
                             atIndex:(NSUInteger)index
                           animation:(BOOL)animation {
    // do nothing
}

- (void)dataProviderDataSourceDidChange:(TDeskMessageDataProvider *)dataProvider {
    [self.tableView reloadData];
}

- (void)dataProvider:(TDeskMessageBaseDataProvider *)dataProvider onRemoveHeightCache:(TDeskMessageCellData *)cellData {
    if (cellData) {
        [self.messageCellConfig removeHeightCacheOfMessageCellData:cellData];
    }
}
#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIPluginNotify] && [subKey isEqualToString:TUICore_TUIPluginNotify_DidChangePluginViewSubKey]) {
        TDeskMessageCellData *data = param[TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data];
        [self.messageCellConfig removeHeightCacheOfMessageCellData:data];
        [self reloadAndScrollToBottomOfMessage:data.innerMessage.msgID section:0];
    }
}

- (void)reloadAndScrollToBottomOfMessage:(NSString *)messageID section:(NSInteger)section {
    // Dispatch the task to RunLoop to ensure that they are executed after the UITableView refresh is complete.
    dispatch_async(dispatch_get_main_queue(), ^{
      [self reloadCellOfMessage:messageID section:section];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollCellToBottomOfMessage:messageID section:section];
      });
    });
}

- (void)reloadCellOfMessage:(NSString *)messageID section:(NSInteger)section {
    NSIndexPath *indexPath = [self indexPathOfMessage:messageID section:section];

    // Disable animation when loading to avoid cell jumping.
    if (indexPath == nil) {
        return;
    }
    [UIView performWithoutAnimation:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
        });
    }];
}

- (void)scrollCellToBottomOfMessage:(NSString *)messageID section:(NSInteger)section {
    NSIndexPath *indexPath = [self indexPathOfMessage:messageID section:section];

    // Scroll the tableView only if the bottom of the cell is invisible.
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    CGRect tableViewRect = self.tableView.bounds;
    BOOL isBottomInvisible = cellRect.origin.y < CGRectGetMaxY(tableViewRect) && CGRectGetMaxY(cellRect) > CGRectGetMaxY(tableViewRect);
    if (isBottomInvisible) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (NSIndexPath *)indexPathOfMessage:(NSString *)messageID section:(NSInteger)section {
    for (int i = 0; i < self.uiMsgs.count; i++) {
        TDeskMessageCellData *data = self.uiMsgs[i];
        if ([data.innerMessage.msgID isEqualToString:messageID]) {
            return [NSIndexPath indexPathForRow:i inSection:section];
        }
    }
    return nil;
}

@end
