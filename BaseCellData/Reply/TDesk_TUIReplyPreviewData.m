//
//  TDeskReplyPreviewData.m
//  TUIChat
//
//  Created by wyl on 2022/3/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TDesk_TUIReplyPreviewData.h"
#import <TDeskCommon/TDesk_TIMDefine.h>

@implementation TDeskReplyPreviewData

+ (NSString *)displayAbstract:(NSInteger)type abstract:(NSString *)abstract withFileName:(BOOL)withFilename isRisk:(BOOL)isRisk {
    NSString *text = abstract;
    if (type == V2TIM_ELEM_TYPE_IMAGE) {
        text = isRisk? TIMCommonLocalizableString(TUIkitMessageTypeRiskImage):TIMCommonLocalizableString(TUIkitMessageTypeImage);
    } else if (type == V2TIM_ELEM_TYPE_VIDEO) {
        text = isRisk? TIMCommonLocalizableString(TUIkitMessageTypeRiskVideo):TIMCommonLocalizableString(TUIkitMessageTypeVideo);
    } else if (type == V2TIM_ELEM_TYPE_SOUND) {
        text = isRisk? TIMCommonLocalizableString(TUIkitMessageTypeRiskVoice):TIMCommonLocalizableString(TUIKitMessageTypeVoice);
    } else if (type == V2TIM_ELEM_TYPE_FACE) {
        text = TIMCommonLocalizableString(TUIKitMessageTypeAnimateEmoji);
    } else if (type == V2TIM_ELEM_TYPE_FILE) {
        if (withFilename) {
            text = [NSString stringWithFormat:@"%@%@", TIMCommonLocalizableString(TUIkitMessageTypeFile), abstract];
            ;
        } else {
            text = TIMCommonLocalizableString(TUIkitMessageTypeFile);
        }
    }
    return text;
}

@end

@implementation TDeskReferencePreviewData

@end
