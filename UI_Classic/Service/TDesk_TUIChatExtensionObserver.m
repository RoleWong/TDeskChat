//
//  TDeskChatExtensionObserver.m
//  TUIChat
//
//  Created by cologne on 2023/3/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIChatExtensionObserver.h"
#import <TDeskCommon/TDesk_TIMCommonModel.h>
#import <TDeskCore/TDesk_TUICore.h>
#import "TDesk_TUIC2CChatViewController.h"

@interface TDeskChatExtensionObserver () <TUIExtensionProtocol>

@end

@implementation TDeskChatExtensionObserver

+ (void)load {
    [self registerFriendProfileActionMenuExtension];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
      instance = [[self alloc] init];
    });
    return instance;
}

+ (void)registerFriendProfileActionMenuExtension {
    [TDeskCore registerExtension:TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID object:TDeskChatExtensionObserver.shareInstance];
}

#pragma mark - TUIExtensionProtocol
- (NSArray<TUIExtensionInfo *> *)onGetExtension:(NSString *)extensionID param:(NSDictionary *)param {
    if (![extensionID isKindOfClass:NSString.class]) {
        return nil;
    }

    if ([extensionID isEqualToString:TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID]) {
        return [self getFriendProfileActionMenuExtensionForClassicContact:param];
    } else {
        return nil;
    }
}

- (NSArray<TUIExtensionInfo *> *)getFriendProfileActionMenuExtensionForClassicContact:(NSDictionary *)param {
    TUIExtensionInfo *info = [[TUIExtensionInfo alloc] init];
    info.weight = 300;
    info.text = TIMCommonLocalizableString(ProfileSendMessages);
    info.onClicked = ^(NSDictionary *_Nonnull actionParam) {
      NSString *userID = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_UserID asClass:NSString.class];
      UINavigationController *pushVC = [actionParam tui_objectForKey:TUICore_TUIContactExtension_FriendProfileActionMenu_PushVC
                                                             asClass:UINavigationController.class];
      if (userID.length > 0 && pushVC) {
          TDeskChatConversationModel *conversationModel = [[TDeskChatConversationModel alloc] init];
          conversationModel.userID = userID;
          conversationModel.conversationID = [NSString stringWithFormat:@"c2c_%@", userID];
          TDeskBaseChatViewController *chatVC = [[TDeskC2CChatViewController alloc] init];
          chatVC.conversationData = conversationModel;
          chatVC.title = conversationModel.title;
          for (UIViewController *vc in pushVC.childViewControllers) {
              if ([vc isKindOfClass:chatVC.class]) {
                  [pushVC popToViewController:vc animated:YES];
                  return;
              }
          }
          [pushVC pushViewController:chatVC animated:YES];
      }
    };
    return @[ info ];
}
@end
