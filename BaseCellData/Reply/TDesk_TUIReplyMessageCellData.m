//
//  TDeskReplyMessageCellData.m
//  TUIChat
//
//  Created by harvy on 2021/11/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

/**
    The protocol format of the custom field cloudMessageData of the message

     {
     "messageReply":{
         "messageID": "xxxx0xxx=xx",
         "messageAbstract":"origin message abstract..."
         "messageSender":"NickName/99618",
         "messageType": "1/2/..",
         "version":"1",
       }
     }
 */

#import "TDesk_TUIReplyMessageCellData.h"
#import <TDeskCommon/TDesk_NSString+TUIEmoji.h>
#import "TDesk_TUIFileMessageCellData.h"
#import "TDesk_TUIImageMessageCellData.h"
#import "TDesk_TUIMergeMessageCellData.h"
#import "TDesk_TUITextMessageCellData.h"
#import "TDesk_TUIVideoMessageCellData.h"
#import "TDesk_TUIVoiceMessageCellData.h"

#import "TDesk_TUICloudCustomDataTypeCenter.h"
#import "TDesk_TUIFileReplyQuoteViewData.h"
#import "TDesk_TUIImageReplyQuoteViewData.h"
#import "TDesk_TUIMergeReplyQuoteViewData.h"
#import "TDesk_TUIReplyPreviewData.h"
#import "TDesk_TUITextReplyQuoteViewData.h"
#import "TDesk_TUIVideoReplyQuoteViewData.h"
#import "TDesk_TUIVoiceReplyQuoteViewData.h"

@implementation TDeskReplyMessageCellData
{
    NSString *_sender;
}

- (void)setSender:(NSString *)sender {
    _sender = sender;
}

- (NSString *__nullable)sender {
    if (self.originMessage) {
        return self.originMessage.nameCard ? : (self.originMessage.friendRemark ? : (self.originMessage.nickName ? : self.originMessage.sender));
    }
    return _sender;
}

+ (TDeskMessageCellData *)getCellData:(V2TIMMessage *)message {
    if (message.cloudCustomData == nil) {
        return nil;
    }

    __block TDeskReplyMessageCellData *replyData = nil;
    [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReply
                                            callback:^(BOOL isContains, id obj) {
                                              if (isContains) {
                                                  if (obj && [obj isKindOfClass:NSDictionary.class]) {
                                                      NSDictionary *reply = (NSDictionary *)obj;
                                                      // This message is a "reply message"
                                                      replyData = [[TDeskReplyMessageCellData alloc]
                                                          initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                                                      replyData.reuseId = TReplyMessageCell_ReuseId;
                                                      replyData.originMsgID = reply[@"messageID"];
                                                      replyData.msgAbstract = reply[@"messageAbstract"];
                                                      replyData.sender = reply[@"messageSender"];
                                                      replyData.originMsgType = (V2TIMElemType)[reply[@"messageType"] integerValue];
                                                      replyData.content = message.textElem.text;
                                                      replyData.messageRootID = reply[@"messageRootID"];
                                                  }
                                              }
                                            }];

    return replyData;
}

- (instancetype)initWithDirection:(TDeskMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            self.cellLayout = [TDeskMessageCellLayout incommingTextMessageLayout];
        } else {
            self.cellLayout = [TDeskMessageCellLayout outgoingTextMessageLayout];
        }
        _emojiLocations = [NSMutableArray array];
    }
    return self;
}

- (CGSize)quotePlaceholderSizeWithType:(V2TIMElemType)type data:(TDeskReplyQuoteViewData *)data {
    if (data == nil) {
        return CGSizeMake(20, 20);
    }

    return [data contentSize:TReplyQuoteView_Max_Width - 12];
}

- (TDeskReplyQuoteViewData *)getQuoteData:(TDeskMessageCellData *)originCellData {
    TDeskReplyQuoteViewData *quoteData = nil;
    Class class = [originCellData getReplyQuoteViewDataClass];
    BOOL hasRiskContent = originCellData.innerMessage.hasRiskContent;
    if (hasRiskContent && [TDeskIMConfig isClassicEntrance]){
        // Return text reply data in default
        TDeskTextReplyQuoteViewData *myData = [[TDeskTextReplyQuoteViewData alloc] init];
        myData.text = [TDeskReplyPreviewData displayAbstract:self.originMsgType abstract:self.msgAbstract withFileName:NO isRisk:hasRiskContent];
        quoteData = myData;
    }
    else  if (class && [class respondsToSelector:@selector(getReplyQuoteViewData:)]) {
        quoteData = [class getReplyQuoteViewData:originCellData];
    }
    else {

    }
    if (quoteData == nil) {
        // 
        // Return text reply data in default
        TDeskTextReplyQuoteViewData *myData = [[TDeskTextReplyQuoteViewData alloc] init];
        myData.text = [TDeskReplyPreviewData displayAbstract:self.originMsgType abstract:self.msgAbstract withFileName:NO isRisk:hasRiskContent];
        quoteData = myData;
    }

    quoteData.originCellData = originCellData;
    @weakify(self);
    quoteData.onFinish = ^{
      @strongify(self);
      if (self.onFinish) {
          self.onFinish();
      }
    };
    return quoteData;
}

@end

@implementation TDeskReferenceMessageCellData

+ (TDeskMessageCellData *)getCellData:(V2TIMMessage *)message {
    if (message.cloudCustomData == nil) {
        return nil;
    }

    __block TDeskReplyMessageCellData *replyData = nil;
    [message doThingsInContainsCloudCustomOfDataType:TUICloudCustomDataType_MessageReference
                                            callback:^(BOOL isContains, id obj) {
                                              if (isContains) {
                                                  if (obj && [obj isKindOfClass:NSDictionary.class]) {
                                                      NSDictionary *reply = (NSDictionary *)obj;
                                                      if ([reply isKindOfClass:NSDictionary.class]) {
                                                          // This message is 「quote message」which indicating the original message
                                                          replyData = [[TDeskReferenceMessageCellData alloc]
                                                              initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                                                          replyData.reuseId = TUIReferenceMessageCell_ReuseId;
                                                          replyData.originMsgID = reply[@"messageID"];
                                                          replyData.msgAbstract = reply[@"messageAbstract"];
                                                          replyData.sender = reply[@"messageSender"];
                                                          replyData.originMsgType = (V2TIMElemType)[reply[@"messageType"] integerValue];
                                                          replyData.content = message.textElem.text;  // text only
                                                      }
                                                  }
                                              }
                                            }];
    return replyData;
}

@end
