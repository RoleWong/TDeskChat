//
//  TDeskVideoReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIVideoReplyQuoteViewData.h"
#import "TDesk_TUIVideoMessageCellData.h"

@implementation TDeskVideoReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TDeskMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TDeskVideoMessageCellData.class]) {
        return nil;
    }

    TDeskVideoReplyQuoteViewData *myData = [[TDeskVideoReplyQuoteViewData alloc] init];
    CGSize snapSize = CGSizeMake(originCellData.innerMessage.videoElem ? originCellData.innerMessage.videoElem.snapshotWidth : 0,
                                 originCellData.innerMessage.videoElem ? originCellData.innerMessage.videoElem.snapshotHeight : 0);
    myData.imageSize = [TDeskVideoReplyQuoteViewData displaySizeWithOriginSize:snapSize];
    myData.originCellData = originCellData;
    return myData;
}

- (void)downloadImage {
    [super downloadImage];

    @weakify(self);
    if ([self.originCellData isKindOfClass:TDeskVideoMessageCellData.class]) {
        TDeskVideoMessageCellData *videoData = (TDeskVideoMessageCellData *)self.originCellData;
        [videoData downloadThumb:^{
          @strongify(self);
          self.image = videoData.thumbImage;
          if (self.onFinish) {
              self.onFinish();
          }
        }];
    }
}

@end
