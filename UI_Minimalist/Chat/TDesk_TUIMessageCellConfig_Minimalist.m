//  Created by Tencent on 2023/07/20.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TDesk_TUIMessageCellConfig_Minimalist.h"

#import <TDeskCore/TDesk_TUIThemeManager.h>
#import <TDeskCommon/TDesk_TUIMessageCell.h>
#import <TDeskCommon/TDesk_TUIMessageCellData.h>
#import <TDeskCommon/TDesk_TUISystemMessageCell.h>
#import <TDeskCommon/TDesk_TUISystemMessageCellData.h>

#import "TDesk_TUIMessageDataProvider.h"

#import "TDesk_TUIFaceMessageCell_Minimalist.h"
#import "TDesk_TUIFaceMessageCellData.h"
#import "TDesk_TUIFileMessageCell_Minimalist.h"
#import "TDesk_TUIFileMessageCellData.h"
#import "TDesk_TUIImageMessageCell_Minimalist.h"
#import "TDesk_TUIImageMessageCellData.h"
#import "TDesk_TUIJoinGroupMessageCell_Minimalist.h"
#import "TDesk_TUIJoinGroupMessageCellData.h"
#import "TDesk_TUIMergeMessageCell_Minimalist.h"
#import "TDesk_TUIMergeMessageCellData.h"
#import "TDesk_TUIReferenceMessageCell_Minimalist.h"
#import "TDesk_TUIReplyMessageCell_Minimalist.h"
#import "TDesk_TUIReplyMessageCellData.h"
#import "TDesk_TUITextMessageCell_Minimalist.h"
#import "TDesk_TUITextMessageCellData.h"
#import "TDesk_TUIVideoMessageCell_Minimalist.h"
#import "TDesk_TUIVideoMessageCellData.h"
#import "TDesk_TUIVoiceMessageCell_Minimalist.h"
#import "TDesk_TUIVoiceMessageCellData.h"

#define kIsCustomMessageFromPlugin @"kIsCustomMessageFromPlugin"

typedef Class<TDeskMessageCellProtocol> CellClass;
typedef NSString * MessageID;
typedef NSNumber * HeightNumber;

static NSMutableDictionary *gCustomMessageInfoMap = nil;

@interface TUIMessageCellConfig_Minimalist ()

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, strong) NSMutableDictionary<TUICellDataClassName, CellClass> *cellClassMaps;
@property(nonatomic, strong) NSMutableDictionary<MessageID, HeightNumber> *heightCacheMaps;

@end

#pragma mark -  Custom Message Register
@implementation TUIMessageCellConfig_Minimalist (CustomMessageRegister)

+ (NSMutableDictionary *)getCustomMessageInfoMap {
    if (gCustomMessageInfoMap == nil) {
        gCustomMessageInfoMap = [NSMutableDictionary dictionary];
    }
    return gCustomMessageInfoMap;
}

+ (void)registerBuiltInCustomMessageInfo {
    [self registerCustomMessageCell:@"TUILinkCell_Minimalist" messageCellData:@"TDeskLinkCellData" forBusinessID:BussinessID_TextLink];
    [self registerCustomMessageCell:@"TUIGroupCreatedCell_Minimalist" messageCellData:@"TDeskGroupCreatedCellData" forBusinessID:BussinessID_GroupCreate];
    [self registerCustomMessageCell:@"TUIEvaluationCell_Minimalist" messageCellData:@"TDeskEvaluationCellData" forBusinessID:BussinessID_Evaluation];
    [self registerCustomMessageCell:@"TUIOrderCell_Minimalist" messageCellData:@"TDeskOrderCellData" forBusinessID:BussinessID_Order];
    [self registerCustomMessageCell:@"TDeskMessageCell_Minimalist" messageCellData:@"TDeskTypingStatusCellData" forBusinessID:BussinessID_Typing];
}

+ (void)registerExternalCustomMessageInfo {
    // Insert your own custom message UI here, your businessID can not be same with built-in
    //
    // Example:
    // [self registerCustomMessageCell:#your message cell# messageCellData:#your message cell data# forBusinessID:#your id#];
    //
    // ...
}

+ (void)registerCustomMessageCell:(TUICellClassName)messageCellName
                  messageCellData:(TUICellDataClassName)messageCellDataName
                    forBusinessID:(TUIBusinessID)businessID {
    [self registerCustomMessageCell:messageCellName messageCellData:messageCellDataName forBusinessID:businessID isPlugin:NO];
}

+ (void)registerCustomMessageCell:(TUICellClassName)messageCellName
                  messageCellData:(TUICellDataClassName)messageCellDataName
                    forBusinessID:(TUIBusinessID)businessID
                         isPlugin:(BOOL)isPlugin {
    NSAssert(messageCellName.length > 0, @"message cell name can not be nil");
    NSAssert(messageCellDataName.length > 0, @"message cell data name can not be nil");
    NSAssert(businessID.length > 0, @"businessID can not be nil");
    NSAssert([[self getCustomMessageInfoMap] objectForKey:businessID] == nil, @"businessID can not be same with the exists");
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[BussinessID] = businessID;
    info[TMessageCell_Name] = messageCellName;
    info[TMessageCell_Data_Name] = messageCellDataName;
    info[kIsCustomMessageFromPlugin] = @(isPlugin);
    [[self getCustomMessageInfoMap] setObject:info forKey:businessID];
}

+ (void)enumerateCustomMessageInfo:(void(^)(NSString *messageCellName,
                                            NSString *messageCellDataName,
                                            NSString *businessID,
                                            BOOL isPlugin))callback {
    if (callback == nil) {
        return;
    }
    [[self getCustomMessageInfoMap] enumerateKeysAndObjectsUsingBlock:^(TUIBusinessID key, NSDictionary *info, BOOL * _Nonnull stop) {
        NSString *businessID = info[BussinessID];
        NSString *messageCellName = info[TMessageCell_Name];
        NSString *messageCellDataName = info[TMessageCell_Data_Name];
        NSNumber *isPlugin = info[kIsCustomMessageFromPlugin];
        if (businessID && messageCellName && messageCellDataName && isPlugin) {
            callback(messageCellName, messageCellDataName, businessID, isPlugin);
        }
    }];
}

+ (nullable Class)getCustomMessageCellDataClass:(NSString *)businessID {
    NSDictionary *info = [[self getCustomMessageInfoMap] objectForKey:businessID];
    if (info == nil) {
        return nil;
    }
    NSString *messageCellDataName = info[TMessageCell_Data_Name];
    Class messageCellDataClass = NSClassFromString(messageCellDataName);
    return messageCellDataClass;
}

+ (BOOL)isPluginCustomMessageCellData:(TDeskMessageCellData *)data {
    __block BOOL flag = NO;
    [[self getCustomMessageInfoMap] enumerateKeysAndObjectsUsingBlock:^(TUIBusinessID key, NSDictionary *info, BOOL * _Nonnull stop) {
        NSString *businessID = info[BussinessID];
        NSNumber *isPlugin = info[kIsCustomMessageFromPlugin];
        if (businessID && isPlugin && isPlugin.boolValue && [data.reuseId isEqualToString:businessID]) {
            flag = YES;
            *stop = YES;
        }
    }];
    return flag;
}

@end


#pragma mark -  Cell  Message cell height
@implementation TUIMessageCellConfig_Minimalist (MessageCellHeight)

- (NSString *)getHeightCacheKey:(TDeskMessageCellData *)msg {
    return msg.msgID.length == 0 ? [NSString stringWithFormat:@"%p", msg] : msg.msgID;
}

- (CGFloat)getHeightFromMessageCellData:(TDeskMessageCellData *)cellData {
    static CGFloat screenWidth = 0;
    if (screenWidth == 0) {
        screenWidth = Screen_Width;
    }
    NSString *key = [self getHeightCacheKey:cellData];
    CGFloat height = [[self.heightCacheMaps objectForKey:key] floatValue];
    if (height == 0) {
        CellClass cellClass = [self.cellClassMaps objectForKey:NSStringFromClass(cellData.class)];
        if ([cellClass respondsToSelector:@selector(getHeight:withWidth:)]) {
            height = [cellClass getHeight:cellData withWidth:screenWidth];
            [self.heightCacheMaps setObject:@(height) forKey:key];
        }
    }
    return height;
}

- (CGFloat)getEstimatedHeightFromMessageCellData:(TDeskMessageCellData *)cellData {
    NSString *key = [self getHeightCacheKey:cellData];
    CGFloat height = [[self.heightCacheMaps objectForKey:key] floatValue];
    return height > 0 ? height : UITableViewAutomaticDimension;;
}

- (void)removeHeightCacheOfMessageCellData:(TDeskMessageCellData *)cellData {
    NSString *key = [self getHeightCacheKey:cellData];
    [self.heightCacheMaps removeObjectForKey:key];
}

@end


#pragma mark - TUIMessageTable

@implementation TUIMessageCellConfig_Minimalist

#pragma mark - Life Cycle
+ (void)load {
    [self registerBuiltInCustomMessageInfo];
    [self registerExternalCustomMessageInfo];
}

#pragma mark - UI

- (void)bindTableView:(UITableView *)tableView {
    self.tableView = tableView;
    
    [self bindMessageCellClass:TUITextMessageCell_Minimalist.class cellDataClass:TDeskTextMessageCellData.class reuseID:TTextMessageCell_ReuseId];
    [self bindMessageCellClass:TUIVoiceMessageCell_Minimalist.class cellDataClass:TDeskVoiceMessageCellData.class reuseID:TVoiceMessageCell_ReuseId];
    [self bindMessageCellClass:TUIImageMessageCell_Minimalist.class cellDataClass:TDeskImageMessageCellData.class reuseID:TImageMessageCell_ReuseId];
    [self bindMessageCellClass:TDeskSystemMessageCell.class cellDataClass:TDeskSystemMessageCellData.class reuseID:TSystemMessageCell_ReuseId];
    [self bindMessageCellClass:TUIFaceMessageCell_Minimalist.class cellDataClass:TDeskFaceMessageCellData.class reuseID:TFaceMessageCell_ReuseId];
    [self bindMessageCellClass:TUIVideoMessageCell_Minimalist.class cellDataClass:TDeskVideoMessageCellData.class reuseID:TVideoMessageCell_ReuseId];
    [self bindMessageCellClass:TUIFileMessageCell_Minimalist.class cellDataClass:TDeskFileMessageCellData.class reuseID:TFileMessageCell_ReuseId];
    [self bindMessageCellClass:TUIJoinGroupMessageCell_Minimalist.class cellDataClass:TDeskJoinGroupMessageCellData.class reuseID:TJoinGroupMessageCell_ReuseId];
    [self bindMessageCellClass:TUIMergeMessageCell_Minimalist.class cellDataClass:TDeskMergeMessageCellData.class reuseID:TMergeMessageCell_ReuserId];
    [self bindMessageCellClass:TUIReplyMessageCell_Minimalist.class cellDataClass:TDeskReplyMessageCellData.class reuseID:TReplyMessageCell_ReuseId];
    [self bindMessageCellClass:TUIReferenceMessageCell_Minimalist.class
                 cellDataClass:TDeskReferenceMessageCellData.class
                       reuseID:TUIReferenceMessageCell_ReuseId];
    __weak typeof(self) weakSelf = self;
    [self.class enumerateCustomMessageInfo:^(NSString * _Nonnull messageCellName,
                                             NSString * _Nonnull messageCellDataName,
                                             NSString * _Nonnull businessID,
                                             BOOL isPlugin) {
        Class cellClass = NSClassFromString(messageCellName);
        Class cellDataClass = NSClassFromString(messageCellDataName);
        [weakSelf bindMessageCellClass:cellClass cellDataClass:cellDataClass reuseID:businessID];
    }];
}

- (void)bindMessageCellClass:(Class)cellClass cellDataClass:(Class)cellDataClass reuseID:(NSString *)reuseID {
    NSAssert(cellClass != nil, @"The UITableViewCell can not be nil");
    NSAssert(cellDataClass != nil, @"The cell data class can not be nil");
    NSAssert(reuseID.length > 0, @"The reuse identifier can not be nil");
    
    [self.tableView registerClass:cellClass forCellReuseIdentifier:reuseID];
    [self.cellClassMaps setObject:cellClass forKey:NSStringFromClass(cellDataClass)];
}

#pragma mark - Lazy && Read-write operate
- (NSMutableDictionary<TUICellDataClassName,CellClass> *)cellClassMaps {
    if (_cellClassMaps == nil) {
        _cellClassMaps = [NSMutableDictionary dictionary];
    }
    return _cellClassMaps;
}

- (NSMutableDictionary<MessageID,HeightNumber> *)heightCacheMaps {
    if (_heightCacheMaps == nil) {
        _heightCacheMaps = [NSMutableDictionary dictionary];
    }
    return _heightCacheMaps;
}


@end
