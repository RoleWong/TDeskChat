//
//  TDeskMessageDataProvider+MessageDeal.m
//  TUIChat
//
//  Created by wyl on 2022/3/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TUIMessageCellData.h>
#import "TDesk_TUIChatDataProvider.h"
#import "TDesk_TUIImageMessageCellData.h"
#import "TDesk_TUIMessageDataProvider+MessageDeal.h"
#import "TDesk_TUIMessageDataProvider.h"
@implementation TDeskMessageDataProvider (MessageDeal)

- (void)loadOriginMessageFromReplyData:(TDeskReplyMessageCellData *)replycellData dealCallback:(void (^)(void))callback {
    if (replycellData.originMsgID.length == 0) {
        if (callback) {
            callback();
        }
        return;
    }

    @weakify(replycellData)[TDeskChatDataProvider findMessages:@[ replycellData.originMsgID ]
                                                    callback:^(BOOL succ, NSString *_Nonnull error_message, NSArray *_Nonnull msgs) {
                                                      @strongify(replycellData) if (!succ) {
                                                          replycellData.quoteData = [replycellData getQuoteData:nil];
                                                          replycellData.originMessage = nil;
                                                          if (callback) {
                                                              callback();
                                                          }
                                                          return;
                                                      }
                                                      V2TIMMessage *originMessage = msgs.firstObject;
                                                      if (originMessage == nil) {
                                                          replycellData.quoteData = [replycellData getQuoteData:nil];
                                                          if (callback) {
                                                              callback();
                                                          }
                                                          return;
                                                      }
                                                      TDeskMessageCellData *cellData = [TDeskMessageDataProvider getCellData:originMessage];
                                                      replycellData.originCellData = cellData;
                                                      if ([cellData isKindOfClass:TDeskImageMessageCellData.class]) {
                                                          TDeskImageMessageCellData *imageData = (TDeskImageMessageCellData *)cellData;
                                                          [imageData downloadImage:TImage_Type_Thumb];
                                                          replycellData.quoteData = [replycellData getQuoteData:imageData];
                                                          replycellData.originMessage = originMessage;
                                                          if (callback) {
                                                              callback();
                                                          }
                                                      } else if ([cellData isKindOfClass:TDeskVideoMessageCellData.class]) {
                                                          TDeskVideoMessageCellData *videoData = (TDeskVideoMessageCellData *)cellData;
                                                          [videoData downloadThumb];
                                                          replycellData.quoteData = [replycellData getQuoteData:videoData];
                                                          replycellData.originMessage = originMessage;
                                                          if (callback) {
                                                              callback();
                                                          }
                                                      } else {
                                                          replycellData.quoteData = [replycellData getQuoteData:cellData];
                                                          replycellData.originMessage = originMessage;
                                                          if (callback) {
                                                              callback();
                                                          }
                                                      }
                                                    }];
}
@end
