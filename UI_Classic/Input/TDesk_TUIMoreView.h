
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  This file declares the components used to implement the "more" view.
 *  More view, the window that appears when you click the "+" button in the lower right corner of the chat window.
 *  More view are usually responsible for providing some additional important functions, such as sending pictures, taking pictures and sending, sending videos,
 * sending files, etc. Currently TUIKit implements and provides the above four functions. If the above 4 functions cannot meet your functional requirements, you
 * can also add your custom unit in this view.
 *
 *  TDeskMoreView provides an entry for sending multimedia messages such as videos, pictures, and files based on the existing text messaging.
 *  The TDeskMoreViewDelegate protocol provides callbacks for more views in response to user actions.
 */

#import <UIKit/UIKit.h>
#import "TDesk_TUIInputMoreCell.h"

@class TDeskMoreView;

/////////////////////////////////////////////////////////////////////////////////
//
//                           TDeskMoreViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TDeskMoreViewDelegate <NSObject>

- (void)moreView:(TDeskMoreView *)moreView didSelectMoreCell:(TDeskInputMoreCell *)cell;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TDeskMoreView
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【Module name】 TDeskMoreView
 * 【Function description】More view are displayed after clicking the "+" on the far right of the input box.
 *  This view can provide you with functional extensions on the current page. for example:
 *  1. Camera. Call the system camera to take a photo and send
 *  2. Photo. Select a picture from the system album and send it.
 *  3. Video. Select a video from the system gallery and send it.
 *  4. File. Select file from system files and send.
 */
@interface TDeskMoreView : UIView

@property(nonatomic, strong) UIView *lineView;

@property(nonatomic, strong) UICollectionView *moreCollectionView;

@property(nonatomic, strong) UICollectionViewFlowLayout *moreFlowLayout;

@property(nonatomic, strong) UIPageControl *pageControl;

@property(nonatomic, weak) id<TDeskMoreViewDelegate> delegate;

- (void)setData:(NSArray *)data;

@end
