
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>
#import "TDesk_TUIMenuCellData.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIMenuCell_Minimalist
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIMenuCell_Minimalist : UICollectionViewCell

@property(nonatomic, strong) UIImageView *menu;

- (void)setData:(TDeskMenuCellData *)data;

@end
