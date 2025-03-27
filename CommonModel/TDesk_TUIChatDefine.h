//
//  TUIChatDefine.h
//  Pods
//
//  Created by xiangzhang on 2022/10/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#ifndef TDesk_COMPONENTS_IOS_TUICHAT_COMMONMODEL_TUICHATDEFINE_H_
#define TDesk_COMPONENTS_IOS_TUICHAT_COMMONMODEL_TUICHATDEFINE_H_

static NSString* const kMemberCellReuseId = @"kMemberCellReuseId";

typedef void (^TUIImageMessageDownloadCallback)(void);

typedef void (^TUIVideoMessageDownloadCallback)(void);

typedef void (^TUIReplyAsyncLoadFinish)(void);

typedef void (^TUIInputPreviewBarCallback)(void);

typedef void (^TUIReplyQuoteAsyncLoadFinish)(void);

typedef void (^TUIChatSelectAllContentCallback)(BOOL);

typedef void (^TUIReferenceSelectAllContentCallback)(BOOL);

typedef void (^TUIReplySelectAllContentCallback)(BOOL);

typedef NS_ENUM(NSInteger, TDeskMultiResultOption) {
    /**
     * 
     * Get all selected results
     */
    TDeskMultiResultOptionAll = 0,
    /**
     * 
     * Filter out data that does not support forwarding
     */
    TDeskMultiResultOptionFiterUnsupportRelay = 1 << 0,
};

typedef NS_ENUM(NSInteger, TUIMessageReadViewTag) {
    TUIMessageReadViewTagUnknown = 0,  // unknown
    TUIMessageReadViewTagRead,         // read group members
    TUIMessageReadViewTagUnread,       // unread group members
    TUIMessageReadViewTagReadDisable,  // disable read group members
    TUIMessageReadViewTagC2C,          // c2c member
};

typedef NS_ENUM(NSUInteger, InputStatus) {
    Input_Status_Input,
    Input_Status_Input_Face,
    Input_Status_Input_More,
    Input_Status_Input_Keyboard,
    Input_Status_Input_Talk,
    Input_Status_Input_Camera,
};

typedef NS_ENUM(NSUInteger, RecordStatus) {
    Record_Status_TooShort,
    Record_Status_TooLong,
    Record_Status_Recording,
    Record_Status_Cancel,
};

typedef NS_ENUM(NSInteger, TDeskChatSmallTongueType) {
    TUIChatSmallTongueType_None,
    TUIChatSmallTongueType_ScrollToBoom,
    TUIChatSmallTongueType_ReceiveNewMsg,
    TUIChatSmallTongueType_SomeoneAt,
};

#define TUITencentCloudHomePageCN @"https://cloud.tencent.com/document/product/269/68228"
#define TUITencentCloudHomePageEN @"https://www.tencentcloud.com/document/product/1047/45913"

#define TUIChatSendMessageNotification @"TUIChatSendMessageNotification"
#define TUIChatSendMessageWithoutUpdateUINotification @"TUIChatSendMessageWithoutUpdateUINotification"

#endif  // TDesk_COMPONENTS_IOS_TUICHAT_COMMONMODEL_TUICHATDEFINE_H_
