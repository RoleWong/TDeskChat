//
//  TDeskDeslObjectFactory.m
//  TUIChat
//
//  Created by wyl on 2023/3/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIChatObjectFactory.h"
#import <TDeskCore/TDesk_NSDictionary+TUISafe.h>
#import "TDesk_TUIC2CChatViewController.h"
#import "TDesk_TUIChatConfig.h"
#import "TDesk_TUIChatDefine.h"
#import "TDesk_TUIGroupChatViewController.h"

@interface TDeskDeslObjectFactory () <TDeskObjectProtocol>

@end

@implementation TDeskDeslObjectFactory
+ (void)load {
    [TDeskCore registerObjectFactory:TDeskCore_TUIChatObjectFactory objectFactory:[TDeskDeslObjectFactory shareInstance]];
}
+ (TDeskDeslObjectFactory *)shareInstance {
    static dispatch_once_t onceToken;
    static TDeskDeslObjectFactory *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
      g_sharedInstance = [[TDeskDeslObjectFactory alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark - TDeskObjectProtocol
- (id)onCreateObject:(NSString *)method param:(nullable NSDictionary *)param {
    if ([method isEqualToString:TDeskCore_TUIChatObjectFactory_ChatViewController_Classic]) {
        return [self createChatViewControllerParam:param];
    }
    return nil;
}

#pragma mark - Private

- (UIViewController *)createChatViewControllerParam:(nullable NSDictionary *)param {
    
    NSString *title = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Title asClass:NSString.class];
    NSString *userID = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_UserID asClass:NSString.class];
    NSString *groupID = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_GroupID asClass:NSString.class];
    NSString *conversationID = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_ConversationID asClass:NSString.class];
    UIImage *avatarImage = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_AvatarImage asClass:UIImage.class];
    NSString *avatarUrl = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_AvatarUrl asClass:NSString.class];
    NSString *highlightKeyword = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_HighlightKeyword asClass:NSString.class];
    V2TIMMessage *locateMessage = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_LocateMessage asClass:V2TIMMessage.class];
    NSString * atTipsStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_AtTipsStr asClass:NSString.class];
    NSArray * atMsgSeqs = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_AtMsgSeqs asClass:NSArray.class];
    NSString *draft = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Draft asClass:NSString.class];
    NSString *isEnableVideoInfoStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Enable_Video_Call asClass:NSString.class];
    NSString *isEnableAudioInfoStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Enable_Audio_Call asClass:NSString.class];
    NSString *isEnableRoomInfoStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Enable_Room asClass:NSString.class];
    NSString *isLimitedPortraitOrientationStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Limit_Portrait_Orientation
                                                                asClass: NSString.class];
    NSString *isEnablePollInfoStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Enable_Poll 
                                                    asClass:NSString.class];
    NSString *isEnableGroupNoteInfoStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Enable_GroupNote asClass:NSString.class];
    NSString *isEnableWelcomeCustomMessage = [param tdesk_objectForKey:
                                              TDeskCore_TUIChatObjectFactory_ChatViewController_Enable_WelcomeCustomMessage 
                                                             asClass:NSString.class];

    NSString *isEnableTakePhotoStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Enable_TakePhoto asClass:NSString.class];

    NSString *isEnableRecordVideoStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Enable_RecordVideo asClass:NSString.class];
    
    NSString *isEnableFileStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Enable_File
                                                asClass:NSString.class];
    NSString *isEnableAlbumStr = [param tdesk_objectForKey:TDeskCore_TUIChatObjectFactory_ChatViewController_Enable_Album 
                                                 asClass:NSString.class];
    
    
    TDeskChatConversationModel *conversationModel = [[TDeskChatConversationModel alloc] init];
    conversationModel.title = title;
    conversationModel.userID = userID;
    conversationModel.groupID = groupID;
    conversationModel.conversationID = conversationID;
    conversationModel.avatarImage = avatarImage;
    conversationModel.faceUrl = avatarUrl;
    conversationModel.atTipsStr = atTipsStr;
    conversationModel.atMsgSeqs = [NSMutableArray arrayWithArray:atMsgSeqs];
    conversationModel.draftText = draft;

    if ([isEnableVideoInfoStr isEqualToString:@"0"]) {
        conversationModel.enableVideoCall = NO;
    }
    
    if ([isEnableAudioInfoStr isEqualToString:@"0"]) {
        conversationModel.enableAudioCall = NO;
    }
    
    if ([isEnableRoomInfoStr isEqualToString:@"0"]) {
        conversationModel.enabelRoom = NO;
    }
    if ([isLimitedPortraitOrientationStr isEqualToString:@"1"]) {
        conversationModel.isLimitedPortraitOrientation = YES;
    }
    
    if ([isEnableWelcomeCustomMessage isEqualToString:@"0"]) {
        conversationModel.enableWelcomeCustomMessage = NO;
    }
    
    if ([isEnablePollInfoStr isEqualToString:@"0"]) {
        conversationModel.enablePoll = NO;
    }
    
    if ([isEnableGroupNoteInfoStr isEqualToString:@"0"]) {
        conversationModel.enableGroupNote = NO;
    }
    
    if ([isEnableTakePhotoStr isEqualToString:@"0"]) {
        conversationModel.enableTakePhoto = NO;
    }

    if ([isEnableRecordVideoStr isEqualToString:@"0"]) {
        conversationModel.enableRecordVideo = NO;
    }
    
    if ([isEnableFileStr isEqualToString:@"0"]) {
        conversationModel.enableFile = NO;
    }
    
    if ([isEnableAlbumStr isEqualToString:@"0"]) {
        conversationModel.enableAlbum = NO;
    }
    
    
    TDeskBaseChatViewController *chatVC = nil;
    if (conversationModel.groupID.length > 0) {
        chatVC = [[TDeskGroupChatViewController alloc] init];
    } else if (conversationModel.userID.length > 0) {
        chatVC = [[TDeskC2CChatViewController alloc] init];
    }
    chatVC.conversationData = conversationModel;
    chatVC.title = conversationModel.title;
    chatVC.highlightKeyword = highlightKeyword;
    chatVC.locateMessage = locateMessage;
    return chatVC;
}

@end
