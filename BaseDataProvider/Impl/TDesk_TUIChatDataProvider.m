
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

@import ImSDK_Plus;
#import <objc/runtime.h>

#import <TDeskCore/TDesk_NSDictionary+TUISafe.h>
#import <TDeskCore/TDesk_TUICore.h>
#import <TDeskCore/TDesk_TUIThemeManager.h>
#import "TDesk_UIAlertController+TUICustomStyle.h"
#import "TDesk_TUIChatConfig.h"
#import "TDesk_TUIChatDataProvider.h"
#import "TDesk_TUIMessageDataProvider.h"
#import "TDesk_TUIVideoMessageCellData.h"
#import "TDesk_TUIChatConversationModel.h"
#import <TDeskCommon/TDesk_TIMCommonMediator.h>
#import <TDeskCommon/TDesk_TUIEmojiMeditorProtocol.h>

#define Input_SendBtn_Key @"Input_SendBtn_Key"
#define Input_SendBtn_Title @"Input_SendBtn_Title"
#define Input_SendBtn_ImageName @"Input_SendBtn_ImageName"
@interface TUISplitEmojiData : NSObject
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;
@end
@implementation TUISplitEmojiData
@end
@interface TDeskChatDataProvider ()
@property(nonatomic, strong) TDeskInputMoreCellData *welcomeInputMoreMenu;

@property(nonatomic, strong) NSMutableArray<TDeskInputMoreCellData *> *customInputMoreMenus;
@property(nonatomic, strong) NSArray<TDeskInputMoreCellData *> *builtInInputMoreMenus;

@property(nonatomic, strong) NSArray<TDeskCustomActionSheetItem *> *customInputMoreActionItemList;
@property(nonatomic, strong) NSArray<TDeskCustomActionSheetItem *> *builtInInputMoreActionItemList;
@end

@implementation TDeskChatDataProvider

- (instancetype)init {
    if (self = [super init]) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeLanguage) name:TUIChangeLanguageNotification object:nil];
    }
    return self;
}

- (void)onChangeLanguage {
    self.customInputMoreActionItemList = nil;
    self.builtInInputMoreActionItemList = nil;
}

- (TDeskInputMoreCellData *)welcomeInputMoreMenu {
    if (!_welcomeInputMoreMenu) {
        __weak typeof(self) weakSelf = self;
        _welcomeInputMoreMenu = [[TDeskInputMoreCellData alloc] init];
        _welcomeInputMoreMenu.priority = 0;
        _welcomeInputMoreMenu.title = TIMCommonLocalizableString(TUIKitMoreLink);
        _welcomeInputMoreMenu.image = TUIChatBundleThemeImage(@"chat_more_link_img", @"chat_more_link_img");
        _welcomeInputMoreMenu.onClicked = ^(NSDictionary *actionParam) {
          NSString *text = TIMCommonLocalizableString(TUIKitWelcome);
          NSString *link = TUITencentCloudHomePageEN;
          NSString *language = [TDeskGlobalization tk_localizableLanguageKey];
          if ([language tui_containsString:@"zh-"]) {
              link = TUITencentCloudHomePageCN;
          }
          NSError *error = nil;
          NSDictionary *param = @{BussinessID : BussinessID_TextLink, @"text" : text, @"link" : link};
          NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
          if (error) {
              NSLog(@"[%@] Post Json Error", [weakSelf class]);
              return;
          }
          V2TIMMessage *message = [TDeskMessageDataProvider getCustomMessageWithJsonData:data desc:text extension:text];
          if ([weakSelf.delegate respondsToSelector:@selector(dataProvider:sendMessage:)]) {
              [weakSelf.delegate dataProvider:weakSelf sendMessage:message];
          }
        };
    }
    return _welcomeInputMoreMenu;
}

- (NSMutableArray<TDeskInputMoreCellData *> *)customInputMoreMenus {
    if (!_customInputMoreMenus) {
        _customInputMoreMenus = [NSMutableArray array];
    }
    return _customInputMoreMenus;
}

- (NSArray<TDeskInputMoreCellData *> *)builtInInputMoreMenus {
    if (_builtInInputMoreMenus == nil) {
        return  [self configBuiltInInputMoreMenusWithConversationModel:nil];
    }
    return _builtInInputMoreMenus;
}
- (NSArray<TDeskInputMoreCellData *> *)configBuiltInInputMoreMenusWithConversationModel:(TDeskChatConversationModel *)conversationModel {
    __weak typeof(self) weakSelf = self;
    TDeskInputMoreCellData *albumData = [[TDeskInputMoreCellData alloc] init];
    albumData.priority = 1000;
    albumData.title = TIMCommonLocalizableString(TUIKitMorePhoto);
    albumData.image = TUIChatBundleThemeImage(@"chat_more_picture_img", @"more_picture");
    albumData.onClicked = ^(NSDictionary *actionParam) {
      if ([weakSelf.delegate respondsToSelector:@selector(onSelectPhotoMoreCellData)]) {
          [weakSelf.delegate onSelectPhotoMoreCellData];
      }
    };

    TDeskInputMoreCellData *takePictureData = [[TDeskInputMoreCellData alloc] init];
    takePictureData.priority = 900;
    takePictureData.title = TIMCommonLocalizableString(TUIKitMoreCamera);
    takePictureData.image = TUIChatBundleThemeImage(@"chat_more_camera_img", @"more_camera");
    takePictureData.onClicked = ^(NSDictionary *actionParam) {
      if ([weakSelf.delegate respondsToSelector:@selector(onTakePictureMoreCellData)]) {
          [weakSelf.delegate onTakePictureMoreCellData];
      }
    };

    TDeskInputMoreCellData *videoData = [[TDeskInputMoreCellData alloc] init];
    videoData.priority = 800;
    videoData.title = TIMCommonLocalizableString(TUIKitMoreVideo);
    videoData.image = TUIChatBundleThemeImage(@"chat_more_video_img", @"more_video");
    videoData.onClicked = ^(NSDictionary *actionParam) {
      if ([weakSelf.delegate respondsToSelector:@selector(onTakeVideoMoreCellData)]) {
          [weakSelf.delegate onTakeVideoMoreCellData];
      }
    };

    TDeskInputMoreCellData *fileData = [[TDeskInputMoreCellData alloc] init];
    fileData.priority = 700;
    fileData.title = TIMCommonLocalizableString(TUIKitMoreFile);
    fileData.image = TUIChatBundleThemeImage(@"chat_more_file_img", @"more_file");
    fileData.onClicked = ^(NSDictionary *actionParam) {
      if ([weakSelf.delegate respondsToSelector:@selector(onSelectFileMoreCellData)]) {
          [weakSelf.delegate onSelectFileMoreCellData];
      }
    };
    
    if (!conversationModel) {
        _builtInInputMoreMenus = @[ albumData, takePictureData, videoData, fileData ];
    }
    else {
        NSMutableArray *formatArray = [NSMutableArray array];
        if (conversationModel.enableAlbum) {
            [formatArray addObject:albumData];
        }
        
        if (conversationModel.enableTakePhoto) {
            [formatArray addObject:takePictureData];
        }
        
        if (conversationModel.enableRecordVideo) {
            [formatArray addObject:videoData];
        }
        if (conversationModel.enableFile) {
            [formatArray addObject:fileData];
        }
        _builtInInputMoreMenus = [NSArray arrayWithArray:formatArray];
    }
    return _builtInInputMoreMenus;
}

- (NSArray<TDeskCustomActionSheetItem *> *)customInputMoreActionItemList {
    if (_customInputMoreActionItemList == nil) {
        NSMutableArray *arrayM = [NSMutableArray array];
        if (TDeskChatConfig.defaultConfig.enableWelcomeCustomMessage) {
            __weak typeof(self) weakSelf = self;
            TDeskCustomActionSheetItem *link =
                [[TDeskCustomActionSheetItem alloc] initWithTitle:TIMCommonLocalizableString(TUIKitMoreLink)
                                                       leftMark:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_custom")]
                                              withActionHandler:^(UIAlertAction *_Nonnull action) {
                                                link.priority = 100;
                                                NSString *text = TIMCommonLocalizableString(TUIKitWelcome);
                                                NSString *link = TUITencentCloudHomePageEN;
                                                NSString *language = [TDeskGlobalization tk_localizableLanguageKey];
                                                if ([language tui_containsString:@"zh-"]) {
                                                    link = TUITencentCloudHomePageCN;
                                                }
                                                NSError *error = nil;
                                                NSDictionary *param = @{BussinessID : BussinessID_TextLink, @"text" : text, @"link" : link};
                                                NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
                                                if (error) {
                                                    NSLog(@"[%@] Post Json Error", [self class]);
                                                    return;
                                                }
                                                   V2TIMMessage *message = [TDeskMessageDataProvider getCustomMessageWithJsonData:data desc:text extension:text];
                                                if ([weakSelf.delegate respondsToSelector:@selector(dataProvider:sendMessage:)]) {
                                                    [weakSelf.delegate dataProvider:weakSelf sendMessage:message];
                                                }
                                              }];
            [arrayM addObject:link];
        }
        _customInputMoreActionItemList = [NSArray arrayWithArray:arrayM];
    }
    return _customInputMoreActionItemList;
}

- (NSArray<TDeskCustomActionSheetItem *> *)builtInInputMoreActionItemList {
    if (_builtInInputMoreActionItemList == nil) {
        __weak typeof(self) weakSelf = self;
        TDeskCustomActionSheetItem *photo =
            [[TDeskCustomActionSheetItem alloc] initWithTitle:TIMCommonLocalizableString(TUIKitMorePhoto)
                                                   leftMark:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_photo")]
                                          withActionHandler:^(UIAlertAction *_Nonnull action) {
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onSelectPhotoMoreCellData)]) {
                                                [weakSelf.delegate onSelectPhotoMoreCellData];
                                            }
                                          }];
        photo.priority = 1000;

        TDeskCustomActionSheetItem *camera =
            [[TDeskCustomActionSheetItem alloc] initWithTitle:TIMCommonLocalizableString(TUIKitMoreCamera)
                                                   leftMark:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_camera")]
                                          withActionHandler:^(UIAlertAction *_Nonnull action) {
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onTakePictureMoreCellData)]) {
                                                [weakSelf.delegate onTakePictureMoreCellData];
                                            }
                                          }];
        camera.priority = 900;

        TDeskCustomActionSheetItem *video =
            [[TDeskCustomActionSheetItem alloc] initWithTitle:TIMCommonLocalizableString(TUIKitMoreVideo)
                                                   leftMark:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_video")]
                                          withActionHandler:^(UIAlertAction *_Nonnull action) {
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onTakeVideoMoreCellData)]) {
                                                [weakSelf.delegate onTakeVideoMoreCellData];
                                            }
                                          }];
        video.priority = 800;

        TDeskCustomActionSheetItem *file =
            [[TDeskCustomActionSheetItem alloc] initWithTitle:TIMCommonLocalizableString(TUIKitMoreFile)
                                                   leftMark:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_document")]
                                          withActionHandler:^(UIAlertAction *_Nonnull action) {
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onSelectFileMoreCellData)]) {
                                                [weakSelf.delegate onSelectFileMoreCellData];
                                            }
                                          }];
        file.priority = 700;
        _builtInInputMoreActionItemList = @[ photo, camera, video, file ];
    }
    return _builtInInputMoreActionItemList;
}


- (NSString *)abstractDisplayWithMessage:(V2TIMMessage *)msg {
    NSString *desc = @"";
    if (msg.nickName.length > 0) {
        desc = msg.nickName;
    } else if (msg.sender.length > 0) {
        desc = msg.sender;
    }
    NSString *display = [self.delegate dataProvider:self mergeForwardMsgAbstactForMessage:msg];

    if (display.length == 0) {
        display = [self.class parseAbstractDisplayWStringFromMessageElement:msg];
    }
    NSString * splitStr = @":";
    splitStr = @"\u202C:";
    
    NSString *nameFormat = [desc stringByAppendingFormat:@"%@", splitStr];
    return  [self.class alignEmojiStringWithUserName:nameFormat
                                                text:display];
}

+ (nullable NSString *)parseAbstractDisplayWStringFromMessageElement:(V2TIMMessage *)message {
    NSString *str = nil;
    if (message.elemType == V2TIM_ELEM_TYPE_TEXT) {
        NSString *content = message.textElem.text;
        str = content;
    }
    else {
        str =  [TDeskMessageDataProvider getDisplayString:message];
    }
    return str;
}

+ (NSString *)alignEmojiStringWithUserName:(NSString *)userName text:(NSString *)text {
    NSArray *textList = [self.class splitEmojiText:text];
    NSInteger forwardMsgLength = 98;
    NSMutableString *sb = [NSMutableString string];
    [sb appendString:userName];
    NSInteger length = userName.length;
    for (NSString *textItem in textList) {
        BOOL isFaceChar = [self.class isFaceStrKey:textItem];
        if (isFaceChar) {
            if (length + textItem.length < forwardMsgLength) {
                [sb appendString:textItem];
                length += textItem.length;
            } else {
                [sb appendString:@"..."];
                break;
            }
        } else {
            if (length + textItem.length < forwardMsgLength) {
                [sb appendString:textItem];
                length += textItem.length;
            } else {
                [sb appendString:textItem];
                break;
            }
        }
    }
    return sb;
}

+ (BOOL)isFaceStrKey:(NSString*) strkey {
    id<TDeskEmojiMeditorProtocol> service = [[TDeskCommonMediator share] getObject:@protocol(TDeskEmojiMeditorProtocol)];
    NSArray <TDeskFaceGroup *> * groups = service.getFaceGroup;
    if ([groups.firstObject.facesMap objectForKey:strkey] != nil) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSArray<NSString *> *)splitEmojiText:(NSString *)text {
    NSString *regex = @"\\[(\\S+?)\\]";
    NSRegularExpression *regexExp = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regexExp matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    NSMutableArray<TUISplitEmojiData *> *emojiDataList = [NSMutableArray array];
    NSInteger lastMentionIndex = -1;
    for (NSTextCheckingResult *match in matches) {
        NSString *emojiKey = [text substringWithRange:match.range];
        NSInteger start;
        if (lastMentionIndex != -1) {
            start = [text rangeOfString:emojiKey options:0 range:NSMakeRange(lastMentionIndex, text.length - lastMentionIndex)].location;
        } else {
            start = [text rangeOfString:emojiKey].location;
        }
        NSInteger end = start + emojiKey.length;
        lastMentionIndex = end;

        
        if (![self.class isFaceStrKey:emojiKey]) {
            continue;
        }
        TUISplitEmojiData *emojiData = [[TUISplitEmojiData alloc] init];
        emojiData.start = start;
        emojiData.end = end;
        [emojiDataList addObject:emojiData];
    }
    NSMutableArray<NSString *> *stringList = [NSMutableArray array];
    NSInteger offset = 0;
    for (TUISplitEmojiData *emojiData in emojiDataList) {
        NSInteger start = emojiData.start - offset;
        NSInteger end = emojiData.end - offset;
        NSString *startStr = [text substringToIndex:start];
        NSString *middleStr = [text substringWithRange:NSMakeRange(start, end - start)];
        text = [text substringFromIndex:end];
        if (startStr.length > 0) {
            [stringList addObject:startStr];
        }
        [stringList addObject:middleStr];
        offset += startStr.length + middleStr.length;
    }
    if (text.length > 0) {
        [stringList addObject:text];
    }
    return stringList;
}

#pragma mark - CellData

- (NSMutableArray<TDeskInputMoreCellData *> *)moreMenuCellDataArray:(NSString *)groupID
                                                           userID:(NSString *)userID
                                         conversationModel:(TDeskChatConversationModel *)conversationModel
                                                 actionController:(id<TDeskInputViewMoreActionProtocol>)actionController {
    
    BOOL isNeedVideoCall = [TDeskChatConfig defaultConfig].enableVideoCall && conversationModel.enableVideoCall;
    BOOL isNeedAudioCall = [TDeskChatConfig defaultConfig].enableAudioCall && conversationModel.enableAudioCall;
    BOOL isNeedWelcomeCustomMessage = [TDeskChatConfig defaultConfig].enableWelcomeCustomMessage && conversationModel.enableWelcomeCustomMessage;
    BOOL isNeedRoom = conversationModel.enabelRoom;
    BOOL isNeedPoll = conversationModel.enablePoll;
    BOOL isNeedGroupNote = conversationModel.enableGroupNote;

    self.builtInInputMoreMenus = [self configBuiltInInputMoreMenusWithConversationModel:conversationModel];
    
    NSMutableArray *moreMenus = [NSMutableArray array];
    [moreMenus addObjectsFromArray:self.builtInInputMoreMenus];
    
    if (isNeedWelcomeCustomMessage) {
        if (![self.customInputMoreMenus containsObject:self.welcomeInputMoreMenu]) {
            [self.customInputMoreMenus addObject:self.welcomeInputMoreMenu];
        }
    }
    [moreMenus addObjectsFromArray:self.customInputMoreMenus];

    // Extension menus
    NSMutableDictionary *extensionParam = [NSMutableDictionary dictionary];
    if (userID.length > 0) {
        extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_UserID] = userID;
    } else if (groupID.length > 0) {
        extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_GroupID] = groupID;
    }
    extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_FilterVideoCall] = @(!isNeedVideoCall);
    extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_FilterAudioCall] = @(!isNeedAudioCall);
    extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_FilterRoom]  = @(!isNeedRoom);
    extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_FilterPoll]  = @(!isNeedPoll);
    extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_FilterGroupNote]  = @(!isNeedGroupNote);
    extensionParam[TUICore_TUIChatExtension_InputViewMoreItem_ActionVC] = actionController;
    NSArray *extensionList = [TDeskCore getExtensionList:TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID param:extensionParam];
    for (TDeskExtensionInfo *info in extensionList) {
        NSAssert(info.icon && info.text && info.onClicked, @"extension for input view is invalid, check icon/text/onclick");
        if (info.icon && info.text && info.onClicked) {
            TDeskInputMoreCellData *data = [[TDeskInputMoreCellData alloc] init];
            data.priority = info.weight;
            data.image = info.icon;
            data.title = info.text;
            data.onClicked = info.onClicked;
            [moreMenus addObject:data];
        }
    }

    // Sort with priority
    NSArray *sortedMenus = [moreMenus sortedArrayUsingComparator:^NSComparisonResult(TDeskInputMoreCellData *obj1, TDeskInputMoreCellData *obj2) {
      return obj1.priority > obj2.priority ? NSOrderedAscending : NSOrderedDescending;
    }];
    return [NSMutableArray arrayWithArray:sortedMenus];
}

- (NSArray<TDeskCustomActionSheetItem *> *)getInputMoreActionItemList:(NSString *)userID
                                                            groupID:(NSString *)groupID
                                                  conversationModel:(TDeskChatConversationModel *)conversationModel
                                                             pushVC:(UINavigationController *)pushVC
                                                   actionController:(id<TDeskInputViewMoreActionProtocol>)actionController {
    NSMutableArray *result = [NSMutableArray array];
    [result addObjectsFromArray:self.builtInInputMoreActionItemList];
    [result addObjectsFromArray:self.customInputMoreActionItemList];

    // Extension items
    NSMutableArray<TDeskCustomActionSheetItem *> *items = [NSMutableArray array];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (userID.length > 0) {
        param[TUICore_TUIChatExtension_InputViewMoreItem_UserID] = userID;
    } else if (groupID.length > 0) {
        param[TUICore_TUIChatExtension_InputViewMoreItem_GroupID] = groupID;
    }
    param[TUICore_TUIChatExtension_InputViewMoreItem_FilterVideoCall] = @(!TDeskChatConfig.defaultConfig.enableVideoCall);
    param[TUICore_TUIChatExtension_InputViewMoreItem_FilterAudioCall] = @(!TDeskChatConfig.defaultConfig.enableAudioCall);
    if (pushVC) {
        param[TUICore_TUIChatExtension_InputViewMoreItem_PushVC] = pushVC;
    }
    param[TUICore_TUIChatExtension_InputViewMoreItem_ActionVC] = actionController;
    NSArray *extensionList = [TDeskCore getExtensionList:TUICore_TUIChatExtension_InputViewMoreItem_MinimalistExtensionID param:param];
    for (TDeskExtensionInfo *info in extensionList) {
        if (info.icon && info.text && info.onClicked) {
            TDeskCustomActionSheetItem *item = [[TDeskCustomActionSheetItem alloc] initWithTitle:info.text
                                                                                    leftMark:info.icon
                                                                           withActionHandler:^(UIAlertAction *_Nonnull action) {
                                                                             info.onClicked(param);
                                                                           }];
            item.priority = info.weight;
            [items addObject:item];
        }
    }
    if (items.count > 0) {
        [result addObjectsFromArray:items];
    }

    // Sort with priority
    NSArray *sorted = [result sortedArrayUsingComparator:^NSComparisonResult(TDeskCustomActionSheetItem *obj1, TDeskCustomActionSheetItem *obj2) {
      return obj1.priority > obj2.priority ? NSOrderedAscending : NSOrderedDescending;
    }];
    return sorted;
}

@end
