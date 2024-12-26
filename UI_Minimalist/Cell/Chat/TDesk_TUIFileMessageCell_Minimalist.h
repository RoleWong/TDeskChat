
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TDeskCommon/TDesk_TUIBubbleMessageCell_Minimalist.h>
#import "TDesk_TUIFileMessageCellData.h"

@interface TUIFileMessageCell_Minimalist : TDeskBubbleMessageCell_Minimalist

/**
 *  File bubble view, used to wrap messages on the UI
 */
@property(nonatomic, strong) UIImageView *bubble;

/**
 *  Label for displaying filename
 *  As the main label of the file message, it displays the file information (including the suffix).
 */
@property(nonatomic, strong) UILabel *fileName;

/**
 *  Label for displaying file size
 *  As the secondary label of the file message, it further displays the secondary information of the file.
 */
@property(nonatomic, strong) UILabel *length;

/**
 *  File icon
 */
@property(nonatomic, strong) UIImageView *fileImage;

/**
 *  Download icon
 */
@property(nonatomic, strong) UIImageView *downloadImage;

@property TDeskFileMessageCellData *fileData;

- (void)fillWithData:(TDeskFileMessageCellData *)data;
@end
