
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  This document declares the relevant modules for group request management.
 *  You can manage users' group join requests through the TDeskGroupPendencyController in this file.
 *  Including browsing applicant information, processing applicant requests and other related operations.
 */

#import <TDeskCommon/TDesk_TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TDesk_TUIGroupPendencyDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *
 * 【Module name】 TDeskGroupPendencyController
 * 【Function description】Group request controller.
 *  This view is responsible for providing the group administrator with a controller for processing group addition applications when the group is set to
 * "Require Admin Approval" This control is implemented by UITableView by default, and the application for group membership is displayed through tableView. The
 * information for joining a group application includes: user avatar, user nickname, application introduction, and agree button. After clicking a specific
 * tableCell, you can enter the detailed interface corresponding to the application (the detailed page includes a reject button).
 */
@interface TDeskGroupPendencyController : UITableViewController

@property TDeskGroupPendencyDataProvider *viewModel;

@property(nonatomic, copy) void (^cellClickBlock)(TDeskGroupPendencyCell *cell);

@end

NS_ASSUME_NONNULL_END
