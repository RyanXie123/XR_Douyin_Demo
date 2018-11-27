//
//  BaseMessageCell.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/27.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "BaseMessageCell.h"





@implementation BaseMessageCell

//cell默认文字样式
+ (NSDictionary *)attributes {
    return @{NSFontAttributeName:SmallFont,NSForegroundColorAttributeName:ColorGray};
}

+ (NSMutableAttributedString *)cellAttributedString:(GroupChat *)chat {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:chat.msg_content];
    [attributedString addAttributes:[self attributes] range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}
//通过NSMutableAttributedString或Image width、height获取contentSize
+ (CGSize)contentSize:(GroupChat *)chat {
    return CGSizeZero;
}

//通过contentSize获取cell height
+ (CGFloat)cellHeight:(GroupChat *)chat {
    return 0;
}

@end
