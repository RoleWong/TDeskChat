//
//  TDeskMergeMessageCellData.h
//  Pods
//
//  Created by harvy on 2020/12/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TDeskCommon/TDesk_TIMDefine.h>
#import <TDeskCommon/TDesk_TUIBubbleMessageCellData.h>
#import <TDeskCommon/TDesk_TUIMessageCellData.h>
NS_ASSUME_NONNULL_BEGIN

@interface TDeskMergeMessageCellData : TDeskMessageCellData

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSArray<NSString *> *abstractList;
@property(nonatomic, strong) V2TIMMergerElem *mergerElem;
@property(nonatomic, assign) CGSize abstractSize;
@property(nonatomic, assign) CGSize abstractRow1Size;
@property(nonatomic, assign) CGSize abstractRow2Size;
@property(nonatomic, assign) CGSize abstractRow3Size;
@property(nonatomic, strong) NSArray<NSDictionary *> *abstractSendDetailList;
- (NSAttributedString *)abstractAttributedString;

@end

NS_ASSUME_NONNULL_END
