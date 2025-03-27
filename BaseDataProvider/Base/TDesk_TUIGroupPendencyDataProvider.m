//
//  TUIGroupPendencyViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/18.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIGroupPendencyDataProvider.h"
#import <TDeskCommon/TDesk_TIMDefine.h>

@interface TDeskGroupPendencyDataProvider ()

@property NSArray *dataList;

@property(nonatomic, assign) uint64_t origSeq;

@property(nonatomic, assign) uint64_t seq;

@property(nonatomic, assign) uint64_t timestamp;

@property(nonatomic, assign) uint64_t numPerPage;

@end

@implementation TDeskGroupPendencyDataProvider

- (instancetype)init {
    self = [super init];

    _numPerPage = 100;
    _dataList = @[];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPendencyChanged:) name:TDeskGroupPendencyCellData_onPendencyChanged object:nil];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onPendencyChanged:(NSNotification *)notification {
    int unReadCnt = 0;
    for (TDeskGroupPendencyCellData *data in self.dataList) {
        if (data.isRejectd || data.isAccepted) {
            continue;
        }
        unReadCnt++;
    }
    self.unReadCnt = unReadCnt;
}

- (void)loadData {
    if (self.isLoading) return;

    self.isLoading = YES;
    @weakify(self);
    [[V2TIMManager sharedInstance]
        getGroupApplicationList:^(V2TIMGroupApplicationResult *result) {
          @strongify(self);
          NSMutableArray *list = @[].mutableCopy;
          for (V2TIMGroupApplication *item in result.applicationList) {
              if ([item.groupID isEqualToString:self.groupId] && item.handleStatus == V2TIM_GROUP_APPLICATION_HANDLE_STATUS_UNHANDLED) {
                  TDeskGroupPendencyCellData *data = [[TDeskGroupPendencyCellData alloc] initWithPendency:item];
                  [list addObject:data];
              }
          }
          self.dataList = list;
          self.unReadCnt = (int)list.count;
          self.isLoading = NO;
          self.hasNextData = NO;
          ;
        }
                           fail:nil];
}

- (void)acceptData:(TDeskGroupPendencyCellData *)data {
    [data accept];
    self.unReadCnt--;
}

- (void)removeData:(TDeskGroupPendencyCellData *)data {
    NSMutableArray *dataList = [NSMutableArray arrayWithArray:self.dataList];
    [dataList removeObject:data];
    self.dataList = dataList;
    [data reject];
    self.unReadCnt--;
}

@end
