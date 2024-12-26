
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TDeskCommon/TDesk_TUIBubbleMessageCell_Minimalist.h>
#import "TDesk_TUIFaceMessageCellData.h"

@interface TUIFaceMessageCell_Minimalist : TDeskBubbleMessageCell_Minimalist
/**
 *  Image view for the resource of emticon
 */
@property(nonatomic, strong) UIImageView *face;

@property TDeskFaceMessageCellData *faceData;

- (void)fillWithData:(TDeskFaceMessageCellData *)data;
@end
